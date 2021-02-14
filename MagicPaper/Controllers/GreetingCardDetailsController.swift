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
                                       image: UIImage?,
                                       video: UIImage?,
                                       qrCode: UIImage?)
}


class GreetingCardDetailsController: UITableViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var headingField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var videoView: UIImageView!
    @IBOutlet weak var qrView: UIImageView!
    
    var uid: String!
    var docRef: DocumentReference!
    var greetingCard: MagicGreetingCard?
    var image: UIImage?
    var video: UIImage?
    var qrCode: UIImage?
    var delegate: GreetingCardDetailsControllerDelegate?
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter
    }()
    
    var imagePicker: ImagePicker!
    var videoPicker2: VideoPicker!
    var videoURL: URL?
    
    let videoPicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) ?? []
        picker.mediaTypes = ["public.movie"]
        picker.videoQuality = .typeHigh
        picker.videoExportPreset = AVAssetExportPresetHEVC1920x1080
        picker.allowsEditing = true
        return picker
    }()


    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Elaborate - involve all fields
        if let greetingCard = greetingCard {
            dateLabel.text = dateFormatter.string(from: greetingCard.greetingDate)
            headingField.text = greetingCard.greetingHeading
            descriptionField.text = greetingCard.greetingDescription
            imageView.image = image
            videoView.image = video
            qrView.image = qrCode
        }
        else {
            dateLabel.text = dateFormatter.string(from: Date())
            docRef = Firestore.firestore().collection(FIR.collection).document()
        }
        
        title = docRef.documentID
        
        
        //Do I need all these?
        imagePicker = ImagePicker(presentationController: self, delegate: self)
        videoPicker2 = VideoPicker(presentationController: self, delegate: self)
        videoPicker.delegate = self
        headingField.becomeFirstResponder()
        
    }
    
    
    // MARK: - UIBar Button Items
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        let greetingCard = MagicGreetingCard(id: docRef.documentID,
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
            print("Document ID: \(docRef.documentID) has been set in Firestore.")
        }
        catch {
            print("Error writing to Firestore: \(error)")
        }
        
        //Firebase Cloud Storage
        if imageView.image != nil {
            var data = Data()
            data = imageView.image!.pngData()!
            let imageRef = Storage.storage().reference().child(FIR.storageImage).child("\(docRef.documentID).png")
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
        
        delegate?.greetingCardDetailsController(self,
                                                image: imageView.image,
                                                video: videoView.image,
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
            present(videoPicker, animated: true, completion: nil)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}


// MARK: - Image Picker Delegate

extension GreetingCardDetailsController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        //Figure how to add the video to the detail view, and prepare to upload to Cloud Storage (Firebase)
        
        
//        guard let movieURL = info[.mediaURL] as? URL else { return }
        
//        videoData = NSData(contentsOf: movieURL)
        
        
//        do {
//            let videoData = try NSData(contentsOf: movieURL, options: NSData.ReadingOptions.alwaysMapped)
//            greetingCardMO.greetingVideo = videoData as Data
//        }
//        catch {
//            fatalError("Video no load!")
//        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    class func getVideoURL() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory.appendingPathComponent("video.mov")
    }
}


// MARK: - CUSTOM Image Picker Delegate

extension GreetingCardDetailsController: ImagePickerDelegate, VideoPickerDelegate {
    func didSelect(image: UIImage?) {
        self.imageView.image = image
    }
    
    func didSelect(url: URL?) {
        self.videoURL = url
    }
}
