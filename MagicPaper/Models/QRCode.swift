//
//  QRCode.swift
//  MagicPaper
//
//  Created by Eddie Char on 1/2/21.
//

import UIKit

struct QRCode {
    let string: String
    
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
