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
            videoView.player?.play()
        }
        else {
            docRef = Firestore.firestore().collection(FIR.collection).document()
            dateLabel.text = dateFormatter.string(from: Date())
        }
        
        let code = QRCode(uid: uid, docID: docRef.documentID)
        qrView.image = code.generate()
        imagePicker = ImagePicker(presentationController: self, delegate: self)
        videoPicker = VideoPicker(presentationController: self, delegate: self)
        headingField.becomeFirstResponder()

        //Debug purposes only
        title = docRef.documentID
    }
    
    
    // MARK: - UIBar Button Items
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        greetingCard = MagicGreetingCard(id: docRef.documentID,
                                         greetingDate: dateFormatter.date(from: dateLabel.text!)!,
                                         greetingCategory: "🎄",
                                         greetingDescription: descriptionField.text!,
                                         greetingHeading: headingField.text!,
                                         greetingUID: uid)
        do {
            try docRef.setData(from: greetingCard)
            print("Document ID: \(docRef.documentID) has been created or updated in Firestore.")
        }
        catch {
            print("Error writing to Firestore: \(error)")
        }
        
                
        //Firebase Cloud Storage
        if imageChanged, let dataFile = imageView.image {
            putInStorage(withData: dataFile.pngData(),
                         inFolder: FIR.storageImage,
                         forFilename: docRef.documentID + ".png",
                         contentType: "image/png")
        }
        
        if videoChanged, let dataFile = videoView.url {
            //Use try if you want to catch the error and investigate. Use try? if you just care about success and failure without the "why". Use try! if you're certain it'll succeed.
            putInStorage(withData: try? Data(contentsOf: dataFile),
                         inFolder: FIR.storageVideo,
                         forFilename: docRef.documentID + ".mov",
                         contentType: "video/quicktime")
        }
        
        if let dataFile = qrView.image {
            putInStorage(withData: dataFile.pngData(),
                         inFolder: FIR.storageQR,
                         forFilename: docRef.documentID + ".png",
                         contentType: "image/png")
        }

        delegate?.greetingCardDetailsController(self,
                                                didUpdateFor: imageView.image,
                                                video: videoView.url,
                                                qrCode: qrView.image)
        
        dismiss(animated: true, completion: nil)
    }
    
    private func putInStorage(withData data: Data?,
                              inFolder storageFolder: String,
                              forFilename filename: String,
                              contentType metadataContentType: String) {
        
        guard let data = data else {
            print("Error creating data file.")
            return
        }
        
        
        let storageRef = Storage.storage().reference().child(uid).child(storageFolder).child(filename)
        let metadata = StorageMetadata()
        metadata.contentType = metadataContentType
        
        let uploadTask = storageRef.putData(data, metadata: metadata) { (storageMetadata, error) in
            guard error == nil else {
                print("   Error uploading data to Firebase Storage: \(error!.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print("   Error with the downloadURL: \(error!.localizedDescription)")
                    return
                }
                
                print("   File uploaded: \(downloadURL)")
            }
        }
        
        //Do I need to capture all these???
//        uploadTask.observe(.resume) { (snapshot) in print("Upload resumed.....") }
//        uploadTask.observe(.pause) { (snapshot) in print("Upload paused.....") }
//        uploadTask.observe(.progress) { (snapshot) in print("Upload progress event.....") }
        uploadTask.observe(.success) { (snapshot) in print("Data upload SUCCESSFUL!") }
        uploadTask.observe(.failure) { (snapshot) in print("Data upload FAILED!") }
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
    
    //Putting this here to silence the stupid constraint warnings.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 || indexPath.section == 1 {
            return 44
        }
        else {
            return 180
        }
    }
}


// MARK: - CUSTOM Image Picker Delegate

extension GreetingCardDetailsController: ImagePickerDelegate, VideoPickerDelegate {
    func didSelect(image: UIImage?) {
        self.imageView.image = image
        self.imageChanged = true
    }
    
    func didSelect(url: URL?) {
        self.videoView.url = url
        self.videoView.player?.play()
        self.videoChanged = true
    }
}
