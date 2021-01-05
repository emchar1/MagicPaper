//
//  MagicPaperController.swift
//  MagicPaper
//
//  Created by Eddie Char on 9/28/20.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation

class MagicPaperController: UIViewController, ARSCNViewDelegate {
    
    // MARK: - Properties
    
    enum ImageOrientation {
        case portrait, landscape
    }
    
    @IBOutlet var sceneView: ARSCNView!

    var configuration: ARImageTrackingConfiguration!
    var videoName: String?
    var node: SCNNode?
    var avPlayer: AVPlayer?
    
//    let videoNameTextField: UITextField = {
//        let textField = UITextField()
//        textField.placeholder = "Enter video name"
//        textField.autocapitalizationType = .none
//        textField.autocorrectionType = .no
//        textField.borderStyle = .roundedRect
//        textField.backgroundColor = .white
//        textField.textColor = .black
//        textField.font = UIFont(name: "Avenir Next", size: 14.0)
//        textField.becomeFirstResponder()
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        return textField
//    }()
//
//    let submitButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.layer.cornerRadius = 30
//        button.backgroundColor = UIColor(red: 148/255, green: 55/255, blue: 255/255, alpha: 1.0)
//        button.setTitle("Submit", for: .normal)
//        button.titleLabel?.font = UIFont(name: "Avenir Next Bold", size: 18)
//        button.addTarget(self, action: #selector(submitTapped(_:)), for: .touchUpInside)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//
//    var qrString: String = ""
//
//    lazy var qrCodeImageView: UIImageView = {
//        let qr = QRCode(string: qrString)
//
//        let imageView = UIImageView()
//        imageView.image = qr.generate()
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()

    
//    let videos = ["gigget2"]
//    let model = Model()
    
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        videoNameTextField.delegate = self
        sceneView.delegate = self
        sceneView.showsStatistics = true
        
//        view.addSubview(videoNameTextField)
//        NSLayoutConstraint.activate([videoNameTextField.widthAnchor.constraint(equalToConstant: 200),
//                                     videoNameTextField.heightAnchor.constraint(equalToConstant: 40),
//                                     videoNameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
//                                     videoNameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
//
//        view.addSubview(submitButton)
//        NSLayoutConstraint.activate([submitButton.widthAnchor.constraint(equalToConstant: 150),
//                                     submitButton.heightAnchor.constraint(equalToConstant: 60),
//                                     submitButton.topAnchor.constraint(equalTo: videoNameTextField.bottomAnchor, constant: 20),
//                                     submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
//
//        view.addSubview(qrCodeImageView)
//        NSLayoutConstraint.activate([qrCodeImageView.widthAnchor.constraint(equalToConstant: 60),
//                                     qrCodeImageView.heightAnchor.constraint(equalToConstant: 60),
//                                     qrCodeImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//                                     qrCodeImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
        
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
//        view.addGestureRecognizer(tapGestureRecognizer)
                
//        model.fetchVideos(videoNames: videos)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configuration = ARImageTrackingConfiguration()

        //Ensure you can read the images in the NewsPaperImages AR Resource Group in Assets.xcassets
        if let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "NewsPaperImages", bundle: .main) {
            configuration.trackingImages = trackedImages
            configuration.maximumNumberOfTrackedImages = 1
            print("Images found.")
        }

        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    
    // MARK: - ARSCNViewDelegate
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let imageAnchor = anchor as? ARImageAnchor,
              let videoName = videoName else {
            
            return nil
        }
        
        if let myVideo = makeVideo(for: imageAnchor, referenceImage: videoName, videoExtension: "mov") {
            return myVideo
        }

        return nil
    }
    
    
    // MARK: - Helper Functions
    
//    @objc func submitTapped(_ sender: UIButton) {
//        qrCodeImageView.removeFromSuperview()
        
//        videoName = videoNameTextField.text!
//        videoNameTextField.text = ""

//        view.addSubview(qrCodeImageView)
//        NSLayoutConstraint.activate([qrCodeImageView.widthAnchor.constraint(equalToConstant: 60),
//                                     qrCodeImageView.heightAnchor.constraint(equalToConstant: 60),
//                                     qrCodeImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//                                     qrCodeImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)])

//        avPlayer?.pause()
//        node?.removeFromParentNode()
//
//        sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
//    }
    
//    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
//        let location = sender.location(in: view)
//
//        if location.x < videoNameTextField.frame.origin.x || location.x > videoNameTextField.bounds.width || location.y < videoNameTextField.frame.origin.y || location.y > videoNameTextField.bounds.height {
//
//            videoNameTextField.endEditing(true)
//        }
//    }
    
    /**
     Creates the video based on the key image file.
     - parameters:
        - imageAnchor: the AR Image Anchor node to reference
        - referenceImage: the key image file used for comparison against the image anchor
        - fileExtension: file extension of the movie file, e.g. mov, mp4
        - imageOrientation: the physical orientation of the image, i.e. portrait or landscape
        - imageDimensions: the dimensions of the image file
     */
    private func makeVideo(for imageAnchor: ARImageAnchor, referenceImage: String, videoExtension: String) -> SCNNode? {
        guard imageAnchor.referenceImage.name == referenceImage else {
            //Do not use fatalError() because it needs to cycle through the list of images.
            print("referenceImage: \(referenceImage) not equal to anchor name: \(imageAnchor.referenceImage.name ?? "nil").")
            return nil
        }
        
        guard let path = Bundle.main.path(forResource: referenceImage, ofType: videoExtension) else {
            print("Path not valid.")
            return nil
        }
        
        guard let image = UIImage(named: referenceImage) else {
            print("Image is nil.")
            return nil
        }
        
        
        let imageDimensions: (width: CGFloat, height: CGFloat) = (image.size.width, image.size.height)
        let imageOrientation: ImageOrientation = imageDimensions.width > imageDimensions.height ? .landscape : .portrait
        
        print("img: \(referenceImage), dimensions: \(imageDimensions), orientation: \(imageOrientation)")
            
        let url = URL(fileURLWithPath: path)
        let item = AVPlayerItem(url: url)
        avPlayer = AVPlayer(playerItem: item)
        
        let videoNode = SKVideoNode(avPlayer: avPlayer!)
        //sets the center position of the video, i.e. the midpoint of the image
        videoNode.position = CGPoint(x: imageDimensions.width / 2, y: imageDimensions.height / 2)
        //flips the video horizontally. I added an xScale with the same size as the absolute value of the yScale. I tested various values and found that 0.5 works for all image/video pairs. Eh.
        videoNode.yScale = -0.5
        videoNode.xScale = 0.5

//        //Alternately, this works to the above...
//        videoNode.yScale = -1.0
//        videoNode.size = CGSize(width: imageDimensions.width, height: imageDimensions.height)
        
        //So... this is only needed for portrait oriented photos/videos!
        videoNode.zRotation = imageOrientation == .portrait ? .pi / 2 : 0
        avPlayer!.seek(to: CMTime.zero)
        avPlayer!.play()
        
        let videoScene = SKScene(size: CGSize(width: imageDimensions.width, height: imageDimensions.height))
        videoScene.addChild(videoNode)
        
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
        let material = SCNMaterial()
        material.diffuse.contents = videoScene
        plane.materials = [material]
        
        let planeNode = SCNNode(geometry: plane)
        //flips the plane so that it's flat on the screen/paper instead of jutting out along the z-axis
        planeNode.eulerAngles.x = -.pi / 2
        
        node = SCNNode()
        node!.addChildNode(planeNode)
        
        //Determine what to do once playback ends.
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer?.currentItem,
                                               queue: nil) { notification in
            self.node?.removeFromParentNode()
//            self.sceneView.session.remove(anchor: imageAnchor)
//            self.avPlayer?.seek(to: CMTime.zero)
//            avPlayer.play()
        }

        
        return node!
    }
    
}
