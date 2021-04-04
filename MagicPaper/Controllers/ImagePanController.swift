//
//  ImagePanController.swift
//  MagicPaper
//
//  Created by Eddie Char on 4/3/21.
//

import UIKit

class ImagePanController: UIViewController, ImagePickerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    
    enum Orientation {
        case portrait, landscape
    }
    
    var imagePicker: ImagePicker!
    var orientation: Orientation = .portrait
    var aspectConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapImageView(_ :))))
        aspectConstraint = imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 16/9)
        imagePicker = ImagePicker(presentationController: self, delegate: self)

    }
    
    @IBAction func rotateView(_ sender: UIButton) {
        orientation = orientation == .landscape ? .portrait : .landscape
        aspectConstraint.isActive = false
        
        switch orientation {
        case .portrait:
            aspectConstraint = imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 16/9)
        case .landscape:
            aspectConstraint = imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 9/16)
        }
        
        aspectConstraint.isActive = true
        print("\(orientation), height: \(imageView.frame.height)")
    }
    
    @objc func didTapImageView(_ sender: UITapGestureRecognizer) {
        imagePicker.present(from: self.view)
    }
    
    func didSelect(image: UIImage?) {
        imageView.image = image
    }
}
