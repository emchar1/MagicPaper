//
//  GreetingCardDetailsController.swift
//  MagicPaper
//
//  Created by Eddie Char on 1/11/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import AVFoundation

protocol GreetingCardDetailsControllerDelegate: class {
    func greetingCardDetailsController(_ controller: GreetingCardDetailsController,
                                       didUpdateFor image: UIImage?,
                                       video: URL?,
                                       qrCode: UIImage?)
}


class GreetingCardDetailsController: UITableViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var headingField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var videoView: VideoView!
    @IBOutlet weak var qrView: UIImageView!
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter
    }()
    
    var uid: String!
    var docRef: DocumentReference!
    var greetingCard: MagicGreetingCard?
    var image: UIImage?
    var videoURL: URL?
    var imageChanged: Bool!
    var videoChanged: Bool!
    var delegate: GreetingCardDetailsControllerDelegate?
    
    var imagePicker: ImagePicker!
    var videoPicker: VideoPicker!
    

    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageChanged = false
        videoChanged = false
        
        if let greetingCard = greetingCard {
            dateLabel.text = dateFormatter.string(from: greetingCard.greetingDate)
            headingField.text = greetingCard.greetingHeading
            descriptionField.text = greetingCard.greetingDescription
            imageView.image = image
            videoView.url = videoURL
        }
        else {
            docRef = Firestore.firestore().collection(FIR.collection).document()

            dateLabel.text = dateFormatter.string(from: Date())
        }
        
        let code = QRCode(string: K.validQRCodePrefix + K.qrDelim + uid + K.qrDelim + docRef.documentID)
        qrView.image = code.generate()
        
        title = docRef.documentID
        
        
        //Do I need all these?
        imagePicker = ImagePicker(presentationController: self, delegate: self)
        videoPicker = VideoPicker(presentationController: self, delegate: self)
        headingField.becomeFirstResponder()
        
    }
    
    
    // MARK: - UIBar Button Items
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        greetingCard = MagicGreetingCard(id: docRef.documentID,
                                         greetingDate: dateFormatter.date(from: dateLabel.text!)!,
                                         greetingCategory: "🎄",
                                         greetingDescription: descriptionField.text!,
                                         greetingHeading: headingField.text!,
                                         greetingUID: uid,
                                         greetingImage: "image",
                                         greetingQRCode: "qr",
                                         greetingVideo: "video")
        do {
            try docRef.setData(from: greetingCard)
            print("Document ID: \(docRef.documentID) has been created or updated in Firestore.")
        }
        catch {
            print("Error writing to Firestore: \(error)")
        }
        
        let storageRef = Storage.storage().reference().child(uid)
        
        //Firebase Cloud Storage
        if imageChanged && imageView.image != nil {
            var data = Data()
            data = imageView.image!.pngData()!
            let imageRef = storageRef
                .child(FIR.storageImage)
                .child("\(docRef.documentID).png")
            let metadata = StorageMetadata()
            metadata.contentType = "image/png"
            
            imageRef.putData(data, metadata: metadata) { (metadata, error) in
                guard error == nil else {
                    print("Localized error: \(error!.localizedDescription)")
                    return
                }
                
                imageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else { return }
                    
                    print("Image created: \(downloadURL)")
                }
            }
        }
        
        if videoChanged && videoView.url != nil {
            let videoRef = storageRef
                .child(FIR.storageVideo)
                .child("\(docRef.documentID).mov")
//            let metadata = StorageMetadata()
//            metadata.contentType = ""
            videoRef.putFile(from: videoView.url!, metadata: nil) { (metadata, error ) in
                guard error == nil else {
                    print("Localized error: \(error!.localizedDescription)")
                    return
                }
                
                videoRef.downloadURL { (url, error) in
                    guard let downloadURL = url else { return }
                    
                    print("Video created: \(downloadURL)")
                }
            }
        }
        
        if qrView.image != nil {
            var data = Data()
            data = qrView.image!.pngData()!
            let qrRef = storageRef
                .child(FIR.storageQR)
                .child("\(docRef.documentID).png")
            let metadata = StorageMetadata()
            metadata.contentType = "image/png"
            
            qrRef.putData(data, metadata: metadata) { (metadata, error) in
                guard error == nil else {
                    print("Localized error: \(error!.localizedDescription)")
                    return
                }
                
                qrRef.downloadURL { (url, error) in
                    guard let downloadURL = url else { return }
                    
                    print("QRCode created: \(downloadURL)")
                }
            }
        }

        delegate?.greetingCardDetailsController(self,
                                                didUpdateFor: imageView.image,
                                                video: videoView.url,
                                                qrCode: qrView.image)
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source

    //So gross. Improve this!
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            headingField.becomeFirstResponder()
        }
        else if indexPath.section == 2 {
            descriptionField.becomeFirstResponder()
        }
        else if indexPath.section == 3 {
            self.imagePicker.present(from: self.view)
        }
        else if indexPath.section == 4 {
            self.videoPicker.present(from: self.view)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}


// MARK: - CUSTOM Image Picker Delegate

extension GreetingCardDetailsController: ImagePickerDelegate, VideoPickerDelegate {
    func didSelect(image: UIImage?) {
//        self.image = image
        self.imageView.image = image
        self.imageChanged = true
    }
    
    func didSelect(url: URL?) {
//        self.videoURL = url
        self.videoView.url = url
        self.videoView.player?.play()
        self.videoChanged = true
    }
}
