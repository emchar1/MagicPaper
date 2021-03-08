//
//  GreetingCardDetailsController2.swift
//  MagicPaper
//
//  Created by Eddie Char on 3/7/21.
//

import UIKit

class GreetingCardDetailsController2: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var qrCodeView: UIImageView!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    
    var image: UIImage?
    var qrCode: UIImage?
    var heading: String?
    var details: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let image = image {
            imageView.image = image
        }
        
        if let qrCode = qrCode {
            qrCodeView.image = qrCode
        }
        
        if let heading = heading {
            headingLabel.text = heading
        }
        
        if let details = details {
            detailsLabel.text = details
        }
    }
}
