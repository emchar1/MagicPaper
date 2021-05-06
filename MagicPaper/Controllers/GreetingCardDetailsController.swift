//
//  GreetingCardDetailsController.swift
//  MagicPaper
//
//  Created by Eddie Char on 3/7/21.
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


class GreetingCardDetailsController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    //2. Need to have a separate videoScrollView, embed videoViewNEW in it and do it like imageView.
    @IBOutlet weak var scrollViewPhoto: UIScrollView!
    @IBOutlet weak var scrollViewVideo: UIScrollView!
    private var photoView: UIImageView!
    private var videoViewNEW: VideoView!
//    @IBOutlet weak var videoView: VideoView!
    @IBOutlet weak var qrView: UIImageView!

    @IBOutlet weak var setZoomButton: UIButton!
    @IBOutlet weak var swapImageButton: UIButton!
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var playVideoButton: UIButton!
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter
    }()
    
    enum LayoutConstraint: Int {
        case top = 0, leading, trailing, bottom
    }

    private lazy var imageViewConstraints: [NSLayoutConstraint] = {
        let top = NSLayoutConstraint.init(item: photoView!, attribute: .top, relatedBy: .equal,
                                          toItem: photoView.superview, attribute: .top,
                                          multiplier: 1, constant: 0)
        let leading = NSLayoutConstraint.init(item: photoView!, attribute: .leading, relatedBy: .equal,
                                              toItem: photoView.superview, attribute: .leading,
                                              multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint.init(item: photoView!, attribute: .trailing, relatedBy: .equal,
                                               toItem: photoView.superview, attribute: .trailing,
                                               multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint.init(item: photoView!, attribute: .bottom, relatedBy: .equal,
                                             toItem: photoView.superview, attribute: .bottom,
                                             multiplier: 1, constant: 0)
//        let aspectratio = NSLayoutConstraint.init(item: imageView!, attribute: .width, relatedBy: .equal,
//                                                  toItem: imageView, attribute: .height,
//                                                  multiplier: 16/9, constant: 0)
        return [top, leading, trailing, bottom]
    }()
    
    private lazy var videoViewConstraints: [NSLayoutConstraint] = {
        let top = NSLayoutConstraint.init(item: videoViewNEW!, attribute: .top, relatedBy: .equal,
                                          toItem: videoViewNEW.superview, attribute: .top,
                                          multiplier: 1, constant: 0)
        let leading = NSLayoutConstraint.init(item: videoViewNEW!, attribute: .leading, relatedBy: .equal,
                                              toItem: videoViewNEW.superview, attribute: .leading,
                                              multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint.init(item: videoViewNEW!, attribute: .trailing, relatedBy: .equal,
                                               toItem: videoViewNEW.superview, attribute: .trailing,
                                               multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint.init(item: videoViewNEW!, attribute: .bottom, relatedBy: .equal,
                                             toItem: videoViewNEW.superview, attribute: .bottom,
                                             multiplier: 1, constant: 0)
        
        return [top, leading, trailing, bottom]
    }()

    private var imagePicker: ImagePicker!
    private var videoPicker: VideoPicker!
    private var isNewDoc: Bool!
    private var imageChanged: Bool!
    private var videoChanged: Bool!
    private var showImageSide: Bool = true {
        didSet {
            scrollViewPhoto.isHidden = !showImageSide
            scrollViewVideo.isHidden = showImageSide
        }
    }
    private var didSetImage: Bool! {
        didSet {
            setZoomButton.isHidden = !didSetImage
            scrollViewPhoto.isUserInteractionEnabled = didSetImage
        }
    }
    
    //I dunno know about this...
    private var didSetVideo: Bool! {
        didSet {
            setZoomButton.isHidden = !didSetVideo
            scrollViewVideo.isUserInteractionEnabled = didSetVideo
        }
    }

    //Public properties that can be set from parent view
    var uid: String!
    var docRef: DocumentReference!
    var greetingCard: MagicGreetingCard?
    var delegate: GreetingCardDetailsControllerDelegate?
    var image: UIImage?
    var videoURL: URL?


    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollViewPhoto.delegate = self                 //Needed to take advantage of zooming.
//        scrollViewVideo.delegate = self
        photoView = UIImageView(frame: CGRect(x: 0, y: 0, width: 1024, height: 768))
        photoView.backgroundColor = .green
        videoViewNEW = VideoView()
        print("videoViewNEW frame: \(videoViewNEW.frame)")
        videoViewNEW.backgroundColor = .systemPink
        
        scrollViewPhoto.backgroundColor = .green
        scrollViewVideo.backgroundColor = .yellow

        //Do this AFTER setting imageView and videoViewNEW
        imageChanged = false
        videoChanged = false
        showImageSide = true
        didSetImage = false
        didSetVideo = false
        
        
        
        
        
        
        
        if let greetingCard = greetingCard {
            dateLabel.text = dateFormatter.string(from: greetingCard.greetingDate)
            headingLabel.text = greetingCard.greetingHeading
            descriptionLabel.text = greetingCard.greetingDescription
            photoView.image = image
            videoViewNEW.url = videoURL
            isNewDoc = false
        }
        else {
            docRef = Firestore.firestore().collection(FIR.collection).document()
            dateLabel.text = dateFormatter.string(from: Date())
            isNewDoc = true
        }

        
        
        
        scrollViewPhoto.addSubview(photoView)
        photoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(imageViewConstraints)
        
        scrollViewVideo.addSubview(videoViewNEW)
        videoViewNEW.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(videoViewConstraints)
        
        updateMinZoomScaleForSize(view.bounds.size)

        
        
        
        let code = QRCode(uid: uid, docID: docRef.documentID)
        qrView.image = code.generate()
        imagePicker = ImagePicker(presentationController: self, delegate: self)
        videoPicker = VideoPicker(presentationController: self, delegate: self)
        
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didGestureAtScreen(_ :))))
        view.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: #selector(didGestureAtScreen(_ :))))
        view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didGestureAtScreen(_ :))))
        
        headingLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapLabel(_ :))))
        descriptionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapLabel(_ :))))

        //Notification observer for videoView player
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                               object: self.videoViewNEW.player?.currentItem,
                                               queue: nil) { [weak self] notification in
            guard let self = self else { return }
            self.videoViewNEW.player?.seek(to: CMTime.zero)
            self.playVideoButton.isHidden = false
        }
        

        //Debug purposes only
        title = docRef.documentID
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        
        //I don't think these are right -EC
//        let widthScale = view.bounds.size.width / imageView.bounds.width
//        let heightScale = view.bounds.size.height / imageView.bounds.height
//        let minScale = min(widthScale, heightScale)
//
//        scrollView.minimumZoomScale = minScale
//        scrollView.zoomScale = minScale
//        scrollView.maximumZoomScale = 100
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fadeButtons(delay: 5.0)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: .AVPlayerItemDidPlayToEndTime,
                                                  object: self.videoViewNEW.player?.currentItem)
    }
    
    private func updateMinZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.width / (showImageSide ? photoView.bounds.width : videoViewNEW.bounds.width)
        let heightScale = size.height / (showImageSide ? photoView.bounds.height : videoViewNEW.bounds.height)
        let minScale = min(widthScale, heightScale)
        
        print("photoViewBounds: \(photoView.constraints), size: \(size.width), widthScale: \(widthScale), heightScale: \(heightScale), minScale: \(minScale)")
        
//        if showImageSide {
            scrollViewPhoto.minimumZoomScale = minScale
            scrollViewPhoto.zoomScale = minScale
            scrollViewPhoto.maximumZoomScale = 100
//        }
//        else {
            scrollViewVideo.minimumZoomScale = minScale
            scrollViewVideo.zoomScale = minScale
            scrollViewVideo.maximumZoomScale = 100
//        }
    }
    
    @objc func didGestureAtScreen(_ sender: UIGestureRecognizer) {
        fadeButtons(delay: 3.0)
    }
    
    @objc func didTapLabel(_ sender: UITapGestureRecognizer) {
        guard let tag = sender.view?.tag else { return }

        let tagHeading: Int = 0
        let alert = UIAlertController(title: tag == tagHeading ? "Enter Heading" : "Enter Description",
                                      message: nil,
                                      preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.autocapitalizationType = tag == tagHeading ? .words : .sentences
            textField.autocorrectionType = .default
            textField.delegate = self
        }
        
        //Add a second line for descriptionLabel
        if tag != tagHeading {
            alert.addTextField { textField2 in
                textField2.autocapitalizationType = .sentences
                textField2.autocorrectionType = .default
                textField2.delegate = self
            }
        }


        let submitButton = UIAlertAction(title: "Apply", style: .default) { [unowned alert, weak self] _ in
            guard let self = self,
                  let textField = alert.textFields?[0].text,
                  textField.count > 0 else {
                return
            }

            if tag == tagHeading {
                self.headingLabel.text = textField
            }
            else {
                self.descriptionLabel.text = textField
                
                if let textField2 = alert.textFields?[1].text, textField2.count > 0 {
                    self.descriptionLabel.text! += "\n" + textField2
                }
            }
        }
        
        submitButton.isEnabled = false
        alert.view.tintColor = UIColor(named: "colorBlue")
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification,
                                               object: alert.textFields?[0],
                                               queue: .main) { [unowned submitButton] notification in
            guard let textField = alert.textFields?[0].text else { return }
            submitButton.isEnabled = !textField.isEmpty
        }

        alert.addAction(submitButton)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelButton)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func fadeButtons(delay: TimeInterval) {
        swapImageButton.gentleFade(withDuration: 0.5, delay: delay)
        selectImageButton.gentleFade(withDuration: 0.5, delay: delay)
    }

    
    // MARK: - UIBar Button Items
    
    @IBAction func setImageViewButtonPressed(_ sender: UIButton) {
        let scale = 1 / scrollViewPhoto.zoomScale
        let visibleRect = CGRect(x: scrollViewPhoto.contentOffset.x * scale,
                                 y: scrollViewPhoto.contentOffset.y * scale,
                                 width: scrollViewPhoto.bounds.size.width * scale,
                                 height: scrollViewPhoto.bounds.size.height * scale)
        
        
        if showImageSide {
            didSetImage = false

            guard let cgImage = (photoView.image?.cgImage)!.cropping(to: visibleRect) else {
                return
            }
            
            let cropped = UIImage.init(cgImage: cgImage)
            photoView.image = cropped
        }
        else {
            didSetVideo = false

            //1. HOW THE FUCK DO YOU CROP A VIDEO???
        }
        
        viewWillLayoutSubviews()
    }
    
    @IBAction func swapImageButtonPressed(_ sender: UIButton) {
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
        showHelper(showImageSide: showImageSide)
    }
    
    private func showHelper(showImageSide: Bool) {
        let speed: TimeInterval = 0.5
        let keyPath = "transform.rotation.y"
        let midPoint: Float = .pi / 2
        
        
        //Prepare to hide the current view...
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            K.addHapticFeedback(withStyle: .light)

//            self.imageView.isHidden = showImageSide
//            self.videoView.isHidden = !showImageSide
//            self.videoViewNEW.isHidden = !showImageSide
            
            self.showImageSide = !self.showImageSide
//            self.photoView.isHidden = showImageSide
//            self.videoViewNEW.isHidden = !showImageSide
            self.selectImageButton.setImage(UIImage(systemName: showImageSide ? "video.fill" : "camera.fill"), for: .normal)

            if !showImageSide {
//                self.videoView.player?.pause()
                self.videoViewNEW.player?.pause()
            }
        }
        
        if showImageSide {
            self.photoView.isUserInteractionEnabled = false
//            self.imageView.animate(keyPath: keyPath, fromValue: 0, toValue: midPoint, duration: speed, delay: 0)
            self.scrollViewPhoto.animate(keyPath: keyPath, fromValue: 0, toValue: midPoint, duration: speed, delay: 0)
        }
        else {
            self.playVideoButton.isHidden = true
//            self.videoView.isUserInteractionEnabled = false
//            self.videoView.animate(keyPath: keyPath, fromValue: 0, toValue: midPoint, duration: speed, delay: 0)
            self.videoViewNEW.isUserInteractionEnabled = false
//            self.videoViewNEW.animate(keyPath: keyPath, fromValue: 0, toValue: midPoint, duration: speed, delay: 0)
            self.scrollViewVideo.animate(keyPath: keyPath, fromValue: 0, toValue: midPoint, duration: speed, delay: 0)
        }
        
        CATransaction.commit()
        
        
        //...and show the next view.
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            if showImageSide {
                self.photoView.isUserInteractionEnabled = true
//                self.videoView.player?.play()
                self.videoViewNEW.player?.play()
                self.playVideoButton.isHidden = true
            }
            else {
//                self.videoView.isUserInteractionEnabled = true
                self.videoViewNEW.isUserInteractionEnabled = true
            }
        }
        
        if showImageSide {
//            self.videoView.animate(keyPath: keyPath, fromValue: midPoint, toValue: 0, duration: speed, delay: speed)
            self.scrollViewVideo.animate(keyPath: keyPath, fromValue: midPoint, toValue: 0, duration: speed, delay: speed)
        }
        else {
//            self.imageView.animate(keyPath: keyPath, fromValue: midPoint, toValue: 0, duration: speed, delay: speed)
            self.scrollViewPhoto.animate(keyPath: keyPath, fromValue: midPoint, toValue: 0, duration: speed, delay: speed)
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
//        videoView.player?.play()
        videoViewNEW.player?.play()
        playVideoButton.isHidden = true
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
            if imageChanged, let dataFile = photoView.image {
                putInStorage(withData: dataFile.pngData(),
                             inFolder: FIR.storageImage,
                             forFilename: docRef.documentID + ".png",
                             contentType: "image/png")
            }
            
//            if videoChanged, let dataFile = videoView.url {
            if videoChanged, let dataFile = videoViewNEW.url {
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
            
            delegate?.greetingCardDetailsController(self,
                                                    didUpdateFor: photoView.image,
//                                                    video: videoView.url,
                                                    video: videoViewNEW.url,
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

extension GreetingCardDetailsController: ImagePickerDelegate, VideoPickerDelegate {
    func didSelect(image: UIImage?) {
        self.image = image
        photoView.image = image
        imageChanged = true
        didSetImage = true
        
        
    }
    
    func didSelect(url: URL?) {
        videoURL = url
//        videoView.url = url
//        videoView.player?.play()
        videoViewNEW.url = url
        videoViewNEW.player?.play()
        playVideoButton.isHidden = true
        videoChanged = true
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
//                                               object: self.videoView.player?.currentItem,
                                               object: self.videoViewNEW.player?.currentItem,
                                               queue: nil) { [weak self] notification in
            guard let self = self else { return }
//            self.videoView.player?.seek(to: CMTime.zero)
            self.videoViewNEW.player?.seek(to: CMTime.zero)
            self.playVideoButton.isHidden = false
        }
    }
}


// MARK: - UIScrollViewDelegate

extension GreetingCardDetailsController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return showImageSide ? photoView : videoViewNEW
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let yOffset: CGFloat = 0//max(0, (imageScrollView.bounds.size.height - imageScrollViewImageView.bounds.size.height) / 2)
        imageViewConstraints[LayoutConstraint.top.rawValue].constant = yOffset
        imageViewConstraints[LayoutConstraint.bottom.rawValue].constant = yOffset
        
        let xOffset: CGFloat = 0//max(0, (imageScrollView.bounds.size.height - imageScrollViewImageView.bounds.size.height) / 2)
        imageViewConstraints[LayoutConstraint.leading.rawValue].constant = xOffset
        imageViewConstraints[LayoutConstraint.trailing.rawValue].constant = xOffset
        
        
        print("scrollView.zoomScale: \(scrollView.zoomScale)")
        
        view.layoutIfNeeded()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("bounds.x: \(scrollView.bounds.origin.x), bounds.y: \(scrollView.bounds.origin.y)")
    }
}


// MARK: - UITextFieldDelegate

extension GreetingCardDetailsController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString

        return newString.length <= 50
    }
}
