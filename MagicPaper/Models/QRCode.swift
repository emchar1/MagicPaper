//
//  QRCode.swift
//  MagicPaper
//
//  Created by Eddie Char on 1/2/21.
//

import UIKit

struct QRCode {
    let uid: String
    let docID: String
    let string: String
    

    init(uid: String, docID: String) {
        self.uid = uid
        self.docID = docID
        self.string = K.validQRCodePrefix + String(K.qrDelim) + uid + String(K.qrDelim) + docID
    }
    
    init(string: String) {
        guard QRCode.isValidCode(string: string) else {
            fatalError("Attempt to set an invalid QR Code")
        }
        
        let firstDelim = string.firstIndex(of: K.qrDelim)!
        let lastDelim = string.lastIndex(of: K.qrDelim)!
        let uid = String(string[string.index(firstDelim, offsetBy: 1)..<lastDelim])
        let docID = String(string[string.index(lastDelim, offsetBy: 1)..<string.endIndex])
        
        self.init(uid: uid, docID: docID)
    }
    
    static func isValidCode(string: String) -> Bool {
        if string.hasPrefix(K.validQRCodePrefix),
           let firstDelim = string.firstIndex(of: K.qrDelim),
           let lastDelim = string.lastIndex(of: K.qrDelim),
           firstDelim != lastDelim {
            return true
        }
        else {
            return false
        }
    }
    
    func generate() -> UIImage {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}
