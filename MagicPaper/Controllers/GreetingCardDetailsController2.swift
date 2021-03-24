//
//  GreetingCardDetailsController2.swift
//  MagicPaper
//
//  Created by Eddie Char on 3/7/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import AVFoundation

protocol GreetingCardDetailsController2Delegate: class {
    func greetingCardDetailsController2(_ controller: GreetingCardDetailsController2,
                                        didUpdateFor image: UIImage?,
//                                        video: URL?,
                                        qrCode: UIImage?)
}


class GreetingCardDetailsController2: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
//    @IBOutlet weak var imageView: UIImageView!
    var imageView = UIImageView()
    @IBOutlet weak var photoScrollView: UIScrollView!
    @IBOutlet weak var qrView: UIImageView!
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter
    }()
    
    private var imagePicker: ImagePicker!
    private var videoPicker: VideoPicker!
    private var imageChanged: Bool!
    private var videoChanged: Bool!
    private var isNewDoc: Bool!

    var uid: String!
    var docRef: DocumentReference!
    var greetingCard: MagicGreetingCard?
    var delegate: GreetingCardDetailsController2Delegate?
    var image: UIImage?
    var videoURL: URL?

    
    var minZoomScale: CGFloat!
//    var qrCode: UIImage?
//    var heading: String?
//    var details: String?
    

    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageChanged = false
        videoChanged = false


//        if let image = image {
//            imageView.image = image
//        }
//        
//        if let qrCode = qrCode {
//            qrView.image = qrCode
//        }
//        
//        if let heading = heading {
//            headingLabel.text = heading
//        }
//        
//        if let details = details {
//            descriptionLabel.text = details
//        }
                
        
        
        
        
        if let greetingCard = greetingCard {
            dateLabel.text = dateFormatter.string(from: greetingCard.greetingDate)
            headingLabel.text = greetingCard.greetingHeading
            descriptionLabel.text = greetingCard.greetingDescription
            imageView.image = image
//            videoView.url = videoURL
            photoScrollView.addSubview(imageView)
            isNewDoc = false
        }
        else {
            docRef = Firestore.firestore().collection(FIR.collection).document()
            dateLabel.text = dateFormatter.string(from: Date())
            isNewDoc = true
        }
        
        let code = QRCode(uid: uid, docID: docRef.documentID)
        qrView.image = code.generate()
        imagePicker = ImagePicker(presentationController: self, delegate: self)
        videoPicker = VideoPicker(presentationController: self, delegate: self)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(setImage(_:)))
        photoScrollView.addGestureRecognizer(tapGestureRecognizer)
        photoScrollView.isUserInteractionEnabled = true

        //Debug purposes only
        title = docRef.documentID
        
        
        
        photoScrollView.delegate = self
    }
    
    @objc func setImage(_ sender: UITapGestureRecognizer) {
        imagePicker.present(from: view)
    }


    // MARK: - UIBar Button Items

    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        greetingCard = MagicGreetingCard(id: docRef.documentID,
                                         greetingDate: dateFormatter.date(from: dateLabel.text!)!,
                                         greetingCategory: "🎄",
                                         greetingDescription: descriptionLabel.text!,
                                         greetingHeading: headingLabel.text!,
                                         greetingUID: uid)
        
        do {
            try docRef.setData(from: greetingCard)
            
            
            //Save image, video and QR code to Firebase Cloud Storage
            if imageChanged, let dataFile = imageView.image {
                putInStorage(withData: dataFile.pngData(),
                             inFolder: FIR.storageImage,
                             forFilename: docRef.documentID + ".png",
                             contentType: "image/png")
            }
            
//            if videoChanged, let dataFile = videoView.url {
//                //Use try if you want to catch the error and investigate. Use try? if you just care about success and failure without the "why". Use try! if you're certain it'll succeed.
//                putInStorage(withData: try? Data(contentsOf: dataFile),
//                             inFolder: FIR.storageVideo,
//                             forFilename: docRef.documentID + ".mp4",
//                             contentType: "video/mp4")
//            }
            
            if isNewDoc, let dataFile = qrView.image {
                putInStorage(withData: dataFile.pngData(),
                             inFolder: FIR.storageQR,
                             forFilename: docRef.documentID + ".png",
                             contentType: "image/png")
            }
            
            delegate?.greetingCardDetailsController2(self,
                                                    didUpdateFor: imageView.image,
//                                                    video: videoView.url,
                                                    qrCode: qrView.image)
            
            print("Document ID: \(docRef.documentID) has been created or updated in Firestore.")
        }
        catch {
            print("Error writing to Firestore: \(error)")
        }
        
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
                guard let uploadURL = url else {
                    print("   Error with the uploadURL: \(error!.localizedDescription)")
                    return
                }
                
                print("   File uploaded: \(uploadURL)")
            }
        }
        
        //Do I need to capture all these???
//        uploadTask.observe(.resume) { (snapshot) in print("Upload resumed.....") }
//        uploadTask.observe(.pause) { (snapshot) in print("Upload paused.....") }
//        uploadTask.observe(.progress) { (snapshot) in print("Upload progress event.....") }
        uploadTask.observe(.success) { (snapshot) in print("Data upload SUCCESSFUL!") }
        uploadTask.observe(.failure) { (snapshot) in print("Data upload FAILED!") }
    }
}


// MARK: - CUSTOM Image Picker Delegate

extension GreetingCardDetailsController2: ImagePickerDelegate, VideoPickerDelegate {
    func didSelect(image: UIImage?, imageView: UIImageView, scrollView: UIScrollView) {
        self.image = image
        self.imageView = imageView
        imageView.image = image

        self.photoScrollView = scrollView
        photoScrollView.addSubview(imageView)

        imageChanged = true
    }
    
    func didSelect(url: URL?) {
        self.videoURL = url
        videoChanged = true
    }
}


// MARK: - UIScrollView Delegate

extension GreetingCardDetailsController2: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
