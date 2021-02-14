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
    static var qrCode: String?
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
