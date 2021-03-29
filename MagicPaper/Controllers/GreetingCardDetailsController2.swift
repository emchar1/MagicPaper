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
                                        video: URL?,
                                        qrCode: UIImage?)
}


class GreetingCardDetailsController2: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var videoView: VideoView!
    @IBOutlet weak var qrView: UIImageView!
    @IBOutlet weak var cameraVideoButton: UIButton!
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var playVideoButton: UIButton!
    
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
    private var showImageSide: Bool!

    var uid: String!
    var docRef: DocumentReference!
    var greetingCard: MagicGreetingCard?
    var delegate: GreetingCardDetailsController2Delegate?
    var image: UIImage?
    var videoURL: URL?


    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageChanged = false
        videoChanged = false
        showImageSide = true

        if let greetingCard = greetingCard {
            dateLabel.text = dateFormatter.string(from: greetingCard.greetingDate)
            headingLabel.text = greetingCard.greetingHeading
            descriptionLabel.text = greetingCard.greetingDescription
            imageView.image = image
            videoView.url = videoURL
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
        
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didGestureAtScreen(_ :))))
        view.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: #selector(didGestureAtScreen(_ :))))
        view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didGestureAtScreen(_ :))))
        
        //Notification observer for videoView player
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                               object: self.videoView.player?.currentItem,
                                               queue: nil) { [weak self] notification in
            guard let self = self else { return }
            self.videoView.player?.seek(to: CMTime.zero)
            self.playVideoButton.isHidden = false
        }
        

        //Debug purposes only
        title = docRef.documentID
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fadeButtons(delay: 5.0)
    }
    
    @objc func didGestureAtScreen(_ sender: UIGestureRecognizer) {
        fadeButtons(delay: 3.0)
    }
    
    private func fadeButtons(delay: TimeInterval) {
        cameraVideoButton.gentleFade(withDuration: 0.5, delay: delay)
        selectImageButton.gentleFade(withDuration: 0.5, delay: delay)
    }

    
    // MARK: - UIBar Button Items
    
    @IBAction func cameraVideoButtonPressed(_ sender: UIButton) {
        let speed: TimeInterval = 0.5
        
        UIView.animateKeyframes(withDuration: 2 * speed, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: speed) {
                sender.transform = CGAffineTransform(rotationAngle: .pi)
            }
            UIView.addKeyframe(withRelativeStartTime: speed, relativeDuration: speed) {
                sender.transform = CGAffineTransform.identity
            }
        }, completion: nil)
        
        fadeButtons(delay: 3.0)
        showHelper(isImage: showImageSide)
        showImageSide = !showImageSide
    }
    
    private func showHelper(isImage: Bool) {
        let speed: TimeInterval = 0.5
        let keyPath = "transform.rotation.y"
        let midPoint: Float = .pi / 2
        
        
        //Prepare to hide the current view...
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.imageView.isHidden = isImage ? true : false
            self.videoView.isHidden = isImage ? false : true
            self.selectImageButton.setImage(UIImage(systemName: isImage ? "video.fill" : "camera.fill"), for: .normal)

            if !isImage {
                self.videoView.player?.pause()
            }
        }
        
        if isImage {
            self.imageView.isUserInteractionEnabled = false
            self.imageView.animate(keyPath: keyPath, fromValue: 0, toValue: midPoint, duration: speed, delay: 0)
        }
        else {
            self.playVideoButton.isHidden = true
            self.videoView.isUserInteractionEnabled = false
            self.videoView.animate(keyPath: keyPath, fromValue: 0, toValue: midPoint, duration: speed, delay: 0)
        }
        
        CATransaction.commit()
        
        
        //...and show the next view.
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            if isImage {
                self.imageView.isUserInteractionEnabled = true
                self.videoView.player?.play()
                self.playVideoButton.isHidden = true
            }
            else {
                self.videoView.isUserInteractionEnabled = true
            }
        }
        
        if isImage {
            self.videoView.animate(keyPath: keyPath, fromValue: midPoint, toValue: 0, duration: speed, delay: speed)
        }
        else {
            self.imageView.animate(keyPath: keyPath, fromValue: midPoint, toValue: 0, duration: speed, delay: speed)
        }
        
        CATransaction.commit()
    }
    
    @IBAction func selectImagePressed(_ sender: UIButton) {
        fadeButtons(delay: 3.0)

        if showImageSide {
            imagePicker.present(from: view)
        }
        else {
            videoPicker.present(from: view)
        }
    }
    
    @IBAction func playVideoPressed(_ sender: UIButton) {
        self.videoView.player?.play()
        self.playVideoButton.isHidden = true
    }

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
            
            if videoChanged, let dataFile = videoView.url {
                //Use try if you want to catch the error and investigate. Use try? if you just care about success and failure without the "why". Use try! if you're certain it'll succeed.
                putInStorage(withData: try? Data(contentsOf: dataFile),
                             inFolder: FIR.storageVideo,
                             forFilename: docRef.documentID + ".mp4",
                             contentType: "video/mp4")
            }
            
            if isNewDoc, let dataFile = qrView.image {
                putInStorage(withData: dataFile.pngData(),
                             inFolder: FIR.storageQR,
                             forFilename: docRef.documentID + ".png",
                             contentType: "image/png")
            }
            
            delegate?.greetingCardDetailsController2(self,
                                                    didUpdateFor: imageView.image,
                                                    video: videoView.url,
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


// MARK: - Image & Video Picker Delegates

extension GreetingCardDetailsController2: ImagePickerDelegate, VideoPickerDelegate {
    func didSelect(image: UIImage?) {
        self.image = image
        imageView.image = image
        imageChanged = true
    }
    
    func didSelect(url: URL?) {
        videoURL = url
        videoView.url = url
        videoView.player?.play()
        playVideoButton.isHidden = true
        videoChanged = true
    }
}
