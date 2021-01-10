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
    
    let instructionsView: UIView = {
        let label = UILabel()
        label.text = "Point the camera at your\nMagic Greeting Card and\nwatch the magic unfold!"
        label.font = UIFont(name: "Avenir Next Regular", size: 18.0)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let view = UIView()
        view.addSubview(label)
        view.backgroundColor = .black
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     label.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
        return view
    }()
    
    let scanButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Scan Another Card", for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir Next Bold", size: 24)
        button.backgroundColor = UIColor(red: 238/255, green: 82/255, blue: 83/255, alpha: 1)
        button.layer.cornerRadius = 40
        button.addTarget(self, action: #selector(scanPressed(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let replayButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Play Again", for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir Next Bold", size: 24)
        button.backgroundColor = UIColor(red: 16/255, green: 172/255, blue: 132/255, alpha: 1)
        button.layer.cornerRadius = 40
        button.addTarget(self, action: #selector(replayPressed(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var replayButtonWidthAnchor: NSLayoutConstraint!
    var replayButtonHeightAnchor: NSLayoutConstraint!
    var scanButtonWidthAnchor: NSLayoutConstraint!
    var scanButtonHeightAnchor: NSLayoutConstraint!

    let segueReplay = "segueReplay"
    var configuration: ARImageTrackingConfiguration!
    var videoName: String?
    var node: SCNNode?
    var avPlayer: AVPlayer?
    
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
//        sceneView.showsStatistics = true

        instructionsView.alpha = 0

        //Only show instructions once.
        if K.showInstructions {
            view.addSubview(instructionsView)
            NSLayoutConstraint.activate([instructionsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                         instructionsView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                                         instructionsView.widthAnchor.constraint(equalToConstant: 250),
                                         instructionsView.heightAnchor.constraint(equalToConstant: 100)])
        }
        
        scanButtonWidthAnchor = scanButton.widthAnchor.constraint(equalToConstant: 0)
        scanButtonHeightAnchor = scanButton.heightAnchor.constraint(equalToConstant: 0)
        replayButtonWidthAnchor = replayButton.widthAnchor.constraint(equalToConstant: 0)
        replayButtonHeightAnchor = replayButton.heightAnchor.constraint(equalToConstant: 0)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Only show instructions once.
        if K.showInstructions {
            UIView.animate(withDuration: 0.5, delay: 2.0, options: .curveEaseIn, animations: {
                self.instructionsView.alpha = 0.8
            }, completion: { _ in
                UIView.animate(withDuration: 0.5, delay: 3.5, options: .curveEaseIn, animations: {
                    self.instructionsView.alpha = 0
                }, completion: { _ in
                    self.instructionsView.removeFromSuperview()
                })

            })
        
            
            
            K.showInstructions = false
        }
        
        configuration = ARImageTrackingConfiguration()

        //Ensure you can read the images in the NewsPaperImages AR Resource Group in Assets.xcassets
        if let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "NewsPaperImages", bundle: .main) {
            configuration.trackingImages = trackedImages
            configuration.maximumNumberOfTrackedImages = 1
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
            print("couldn't find videoName")
            return nil
        }
        
        if let myVideo = makeVideo(for: imageAnchor, referenceImage: videoName, videoExtension: "mov") {
            return myVideo
        }
        
        return nil
    }
    
    
    // MARK: - Helper Functions
    
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
            self.sceneView.session.remove(anchor: imageAnchor)
            self.avPlayer?.seek(to: CMTime.zero)
//            self.avPlayer?.play()
            
            self.view.addSubview(self.scanButton)
            NSLayoutConstraint.activate([self.scanButtonWidthAnchor,
                                         self.scanButtonHeightAnchor,
                                         self.scanButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                                         self.view.layoutMarginsGuide.bottomAnchor.constraint(equalTo: self.scanButton.bottomAnchor, constant: 180)])
            
            self.scanButtonWidthAnchor.constant = 260
            self.scanButtonHeightAnchor.constant = 80

            self.view.addSubview(self.replayButton)
            NSLayoutConstraint.activate([self.replayButtonWidthAnchor,
                                         self.replayButtonHeightAnchor,
                                         self.replayButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                                         self.view.layoutMarginsGuide.bottomAnchor.constraint(equalTo: self.replayButton.bottomAnchor, constant: 80)])
            
            self.replayButtonWidthAnchor.constant = 260
            self.replayButtonHeightAnchor.constant = 80
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 10, options: .curveEaseIn, animations: {

                self.scanButton.layoutIfNeeded()
            }, completion: { _ in
                
            })
            
            UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.4, initialSpringVelocity: 10, options: .curveEaseIn, animations: {
                
                self.replayButton.layoutIfNeeded()
            }, completion: nil)
            
            AppStoreReviewManager.requestReviewIfAppropriate()
        }
        
        return node!
    }
    
    
    @objc func scanPressed(_ sender: UIButton) {
        K.addHapticFeedback(withStyle: .medium)
        
        shrinkButtons(replayPressed: false)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.performSegue(withIdentifier: "segueScan", sender: nil)
        }
    }
    
    @objc func replayPressed(_ sender: UIButton) {
        K.addHapticFeedback(withStyle: .medium)
        
        shrinkButtons(replayPressed: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.sceneView.session.run(self.configuration, options: [.removeExistingAnchors, .resetTracking])
        }
    }
    
    private func shrinkButtons(replayPressed: Bool) {
        
        UIView.animate(withDuration: 0, animations: {
            //Don't do anyting here
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                if replayPressed {
                    self.scanButton.alpha = 0
                }
                else {
                    self.replayButton.alpha = 0
                }
            }, completion: { _ in
                self.scanButtonWidthAnchor.constant = 0
                self.scanButtonHeightAnchor.constant = 0
                self.replayButtonWidthAnchor.constant = 0
                self.replayButtonHeightAnchor.constant = 0
                self.scanButton.alpha = 1
                self.replayButton.alpha = 1
                
                self.scanButton.layoutIfNeeded()
                self.replayButton.layoutIfNeeded()
                
                self.scanButton.removeFromSuperview()
                self.replayButton.removeFromSuperview()
            })
        })
    }
}
