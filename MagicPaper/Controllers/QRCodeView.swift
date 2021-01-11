//
//  QRCodeView.swift
//  MagicPaper
//
//  Created by Eddie Char on 1/5/21.
//

import UIKit

class QRCodeView: UIViewController {
    var qrCode: QRCode!
    
    override func viewDidLoad() {
        qrCode = QRCode(string: "magicpaperdisco")
        
        let qrImageView = UIImageView(image: qrCode.generate())
        let qrImageSize = view.frame.width - 80
        qrImageView.frame = CGRect(x: 40, y: view.frame.height / 2 - qrImageSize / 2, width: qrImageSize, height: qrImageSize)
        view.addSubview(qrImageView)
    }
}
