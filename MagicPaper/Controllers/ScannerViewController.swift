//
//  ScannerViewController.swift
//  MagicPaper
//
//  Created by Eddie Char on 1/2/21.
//

import UIKit
import AVFoundation

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var qrLabel: UILabel!
    @IBOutlet weak var scannerView: UIView!
    
    var checkmarkView: CheckmarkView!
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var qrCodeString: String?
    
    
    // MARK: - Initialization

    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestCamera()
        audioManager.playSound(for: "Load")
        qrLabel.text = "Scan the QR Code on your\nMagic Greeting Card and\nwatch it come to life!"
        scannerView.layer.cornerRadius = 10
        scannerView.layer.borderWidth = 4
        scannerView.layer.borderColor = UIColor.white.cgColor
        scannerView.clipsToBounds = true
        let scannerBorder = UIView(frame: CGRect(x: view.center.x - 1, y: view.center.y - 1, width: 2, height: 2))
        scannerBorder.layer.borderWidth = 1
        scannerBorder.layer.borderColor = UIColor.white.cgColor
        view.addSubview(scannerBorder)
        checkmarkView = CheckmarkView(frame: .zero, in: view)
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        captureSession = AVCaptureSession()

        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        scannerView.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let captureSession = captureSession, !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let captureSession = captureSession, captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    
    // MARK: - Helper Functions
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported",
                                   message: "Your device does not support QR Code scanning. Please use a device with a camera.",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let qrCodeString = readableObject.stringValue else { return }

            found(qrCodeString: qrCodeString)
        }
    }
    
    /**
     This determines what to do once a QR Code is found.
     - parameter qrCodeString: The string info used to create the QR Code
     */
    func found(qrCodeString: String) {
        guard QRCode.isValidCode(string: qrCodeString) else {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

            let errorLabel = UILabel(frame: CGRect(x: 20, y: view.frame.height / 2 + 180, width: view.frame.width - 40, height: 100))
            errorLabel.font = UIFont(name: "Avenir Next Regular", size: 18.0)
            errorLabel.text = "Invalid QR Code! Please scan the code on the Greeting Card."
            errorLabel.textAlignment = .center
            errorLabel.numberOfLines = 0
            errorLabel.textColor = .systemRed
            view.addSubview(errorLabel)
            
            UIView.animate(withDuration: 0.5, delay: 3.0, options: .curveEaseIn, animations: {
                errorLabel.alpha = 0
            }, completion: { _ in
                errorLabel.removeFromSuperview()
            })
            
            captureSession.startRunning()
            return
        }
        
        
        self.qrCodeString = qrCodeString
        
        checkmarkView.animate { [weak self] in
            guard let self = self else { return }
            
            self.performSegue(withIdentifier: "segueMagic", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueMagic" {
            let controller = segue.destination as! MagicPaperController
            
            if let qrCodeString = qrCodeString {
                controller.qrCode = QRCode(string: qrCodeString)
            }
        }
    }
    
    
    @IBAction func unwindToScannerViewController(segue: UIStoryboardSegue) {
        
    }
}


// MARK: - Camera Access

extension ScannerViewController {
    func requestCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            return
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    print("Camera granted.")
                    return
                }
            }
        case .denied: // The user has previously denied access.
            return
        case .restricted: // The user can't grant access due to restrictions.
            return
        default:
            return
        }
    }
}

