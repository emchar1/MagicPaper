//
//  ImagePanController.swift
//  MagicPaper
//
//  Created by Eddie Char on 4/3/21.
//

import UIKit

class ImagePanController: UIViewController, ImagePickerDelegate {
    enum Orientation {
        case portrait, landscape
    }
    
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var rotateButton: UIButton!
    var imagePicker: ImagePicker!
    var orientation: Orientation = .portrait
    var aspectConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        imagePicker = ImagePicker(presentationController: self, delegate: self)

        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        scrollView.backgroundColor = UIColor(named: "colorGreen")
        imageView = UIImageView(frame: .zero)
        imageView.backgroundColor = UIColor(named: "colorBlue")
        imageView.isUserInteractionEnabled = true

        //
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapImageView(_ :))))
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)

        //
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     scrollView.topAnchor.constraint(equalTo: view.topAnchor),
                                     view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                                     view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)])

        imageView.translatesAutoresizingMaskIntoConstraints = false
        aspectConstraint = imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 16/9)
        NSLayoutConstraint.activate([imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
                                     imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
                                     imageView.widthAnchor.constraint(equalToConstant: 350),
                                     aspectConstraint])
                
        rotateButton = UIButton(frame: .zero)
        rotateButton.setImage(UIImage(systemName: "rotate.right.fill"), for: .normal)
        rotateButton.tintColor = UIColor(named: "colorRed")
        rotateButton.addTarget(self, action: #selector(rotateView(_:)), for: .touchUpInside)
        view.addSubview(rotateButton)
        rotateButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([rotateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     rotateButton.widthAnchor.constraint(equalToConstant: 50),
                                     rotateButton.heightAnchor.constraint(equalToConstant: 50),
                                     view.bottomAnchor.constraint(equalTo: rotateButton.bottomAnchor, constant: 100)])
    }
    
    @objc func rotateView(_ sender: UIButton) {
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
