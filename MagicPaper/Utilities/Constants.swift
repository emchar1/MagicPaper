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


// MARK: - UIView

extension UIView {
    func animate(keyPath: String, fromValue: Float, toValue: Float, duration: TimeInterval, delay: TimeInterval) {
        let animation: CABasicAnimation = CABasicAnimation(keyPath: keyPath)
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.beginTime = CACurrentMediaTime() + delay
        animation.duration = duration
//        animation.isCumulative = true
//        animation.repeatCount = Float.greatestFiniteMagnitude
        self.layer.add(animation, forKey: keyPath + "Animation")
    }
}


// MARK: - UIButton

extension UIButton {
    func gentleFade(withDuration: TimeInterval, delay: TimeInterval) {
        self.alpha = 0.8
        UIView.animate(withDuration: withDuration, delay: delay, options: [.curveLinear, .allowUserInteraction], animations: {
            self.alpha = 0.1
        }, completion: nil)
    }
}
