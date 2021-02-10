//
//  MagicGreetingCard.swift
//  MagicPaper
//
//  Created by Eddie Char on 1/10/21.
//

import UIKit
import FirebaseFirestoreSwift

struct MagicGreetingCard {
//    @DocumentID public var id: String?
    var greetingDate: Date
    var greetingCategory: String
    var greetingDescription: String
    var greetingHeading: String
    var greetingIdentifier: String
    var greetingImage: UIImage
    var greetingQRCode: UIImage
    var greetingVideo: UIImage
    
//    enum CodingKeys: String, CodingKey {
//        case greetingDate, greetingCategory, greetingDescription, greetingHeading, greetingIdentifier, greetingImage, greetingQRCode, greetingVideo
//    }
}
