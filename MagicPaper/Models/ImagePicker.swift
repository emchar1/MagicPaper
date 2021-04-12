//
//  ImagePicker.swift
//  MagicPaper
//
//  Created by Eddie Char on 1/23/21.
//

import UIKit
import Photos

public protocol ImagePickerDelegate: class {
    func didSelect(image: UIImage?)
}

open class ImagePicker: NSObject {
    
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    
    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()
        
        super.init()
        
        self.presentationController = presentationController
        self.delegate = delegate
        
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }
    
    public func present(from sourceView: UIView) {
        let alertController = UIAlertController(title: "Edit Photo", message: nil, preferredStyle: .actionSheet)
        
        if let action = self.action(for: .camera, title: "Take Photo") {
            alertController.addAction(action)
        }
        
        if let action = self.action(for: .savedPhotosAlbum, title: "Camera Roll") {
            alertController.addAction(action)
        }
        
        if let action = self.action(for: .photoLibrary, title: "Photo Library") {
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.view.tintColor = UIColor(named: "colorBlue")
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        
        self.presentationController?.present(alertController, animated: true) { [weak self] in
            guard let self = self else { return }
            
            self.requestPhotos()
        }
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        
        self.delegate?.didSelect(image: image)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        guard let image = info[.originalImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        
        self.pickerController(picker, didSelect: image)
    }
    
//    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
//        let scale = newWidth / image.size.width
//        let newHeight = image.size.height * scale
//
//        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
//        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
//        let newImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
//        UIGraphicsEndImageContext()
//
//        return newImage
//    }
}

extension ImagePicker: UINavigationControllerDelegate {
    //This extension intentionally left blank.
    
    func requestPhotos() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            return
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { granted in
                if granted == .authorized{
                    print("Photos granted.")
                    return
                } else {
                    //Present message to allow photos...
                }
            }
        case .denied:
            return
        case .restricted:
            return
        default:
            return
        }
    }
}
