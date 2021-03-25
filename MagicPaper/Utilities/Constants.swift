//
//  Constants.swift
//  MagicPaper
//
//  Created by Eddie Char on 1/6/21.
//

import UIKit
import AVFoundation

var audioManager = AudioManager()

struct K {
    static let validQRCodePrefix = "magicpaper"
    static let qrDelim: Character = "-"
    static let mb: Int64 = 1 * 1024 * 1024
    static let maxImageSize: Int64 = 5
    static let maxVideoSize: Int64 = 18
    static let videoMaximumDuration: TimeInterval = 30
    static var showInstructions = true
    
    /**
     Adds a haptic feedback vibration.
     - parameter style: style of feedback to produce
     */
    static func addHapticFeedback(withStyle style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

struct FIR {
    //Firestore
    static let rootPath = "users"
    static let collection = "greetingcards"
    static let greetingUID = "greetingUID"
    static let greetingDate = "greetingDate"
    static let greetingCategory = "greetingCategory"
    static let greetingHeading = "greetingHeading"
    static let greetingDescription = "greetingDescription"
    static let greetingImage = "greetingImage"
    static let greetingQRCode = "greetingQRCode"
    static let greetingVideo = "greetingVideo"
    
    //Cloud Storage
    static let storageImage = "images"
    static let storageVideo = "videos"
    static let storageQR = "qrCodes"
    static var storageAssets: [GreetingCardAsset] = []
    static var allUsers: String? = nil

}


// MARK: - Comparable

extension Comparable {
    /**
     Imposes a lower and upper limit to a value.
     - parameters:
        - min: lower limit
        - max: upper limit
     */
    func clamp(min minValue: Self, max maxValue: Self) -> Self {
        return max(min(self, maxValue), minValue)
    }
}


// MARK: - CGPoint

extension CGPoint {
    func isOutside(of rect: CGRect) -> Bool {
        return self.x < rect.origin.x || self.x > rect.width || self.y < rect.origin.y || self.y > rect.height
    }
}


// MARK: - UIImageView

extension UIImageView {
    /**
     When the content mode of ImageView is Aspect Fit, the image may not fill all the space of ImageView so, the frame of image inside the ImageView may not be equal to its bounds. Create an extension of UIImageView and  write a function that calculates the frame of image in ImageView.
     - returns: the imageFrame in CGRect
     */
    func imageFrame() -> CGRect {
        guard let imageSize = self.image?.size else { return CGRect.zero }
        
        let imageViewSize = self.frame.size
        let imageRatio = imageSize.width / imageSize.height
        let imageViewRatio = imageViewSize.width / imageViewSize.height
        
        if imageRatio < imageViewRatio {
            let scaleFactor = imageViewSize.height / imageSize.height
            let width = imageSize.width * scaleFactor
            let topLeftX = (imageViewSize.width - width) * 0.5
            
            return CGRect(x: topLeftX, y: 0, width: width, height: imageViewSize.height)
        }
        else {
            let scaleFactor = imageViewSize.width / imageSize.width
            let height = imageSize.height * scaleFactor
            let topLeftY = (imageViewSize.height - height) * 0.5
            
            return CGRect(x: 0, y: topLeftY, width: imageViewSize.width, height: height)
        }
    }
}
