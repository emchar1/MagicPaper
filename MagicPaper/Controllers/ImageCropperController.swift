//
//  ImageCropperController.swift
//  MagicPaper
//
//  Created by Eddie Char on 3/24/21.
//

import UIKit

class ImageCropperController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.minimumZoomScale = 1.0
            scrollView.maximumZoomScale = 10.0
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var cropAreaView: CropAreaView!
    
    var cropArea: CGRect {
        get {
            let factor = imageView.image!.size.width / view.frame.width
            let scale = 1 / scrollView.zoomScale
            let imageFrame = imageView.imageFrame()
            let x = (scrollView.contentOffset.x + cropAreaView.frame.origin.x - imageFrame.origin.x) * scale * factor
            let y = (scrollView.contentOffset.y + cropAreaView.frame.origin.y - imageFrame.origin.y) * scale * factor
            let width = cropAreaView.frame.size.width * scale * factor
            let height = cropAreaView.frame.size.height * scale * factor
            
            return CGRect(x: x, y: y, width: width, height: height)
        }
    }
    
    
    @IBAction func crop(_ sender: UIButton) {
        let croppedCGImage = imageView.image?.cgImage?.cropping(to: cropArea)
        let croppedImage = UIImage(cgImage: croppedCGImage!)
        imageView.image = croppedImage
        scrollView.zoomScale = 1
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
