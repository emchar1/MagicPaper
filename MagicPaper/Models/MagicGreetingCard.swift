//
//  MagicGreetingCard.swift
//  MagicPaper
//
//  Created by Eddie Char on 1/10/21.
//

import UIKit
import FirebaseFirestoreSwift

struct MagicGreetingCard: Identifiable, Codable {
    @DocumentID public var id: String?
    let greetingDate: Date
    let greetingCategory: String    //Is this needed??
    let greetingDescription: String
    let greetingHeading: String
    let greetingUID: String
    
    //Use CodingKeys enum if Firestore object has different field names compared to Swift struct. In this case, it doesn't so don't really need the enum CodingKeys: String, CodingKey
//    enum CodingKeys: String, CodingKey {
//        case greetingDate
//        case greetingCategory
//        case greetingDescription
//        case greetingHeading
//        case greetingUID
//        case greetingImage
//        case greetingQRCode
//        case greetingVideo
//    }
}
