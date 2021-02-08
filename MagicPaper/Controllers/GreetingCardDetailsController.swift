//
//  GreetingCardDetailsController.swift
//  MagicPaper
//
//  Created by Eddie Char on 1/11/21.
//

import UIKit
import CoreData
import CloudKit
import AVFoundation

class GreetingCardDetailsController: UITableViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var headingField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var videoView: UIImageView!
    @IBOutlet weak var qrView: UIImageView!
    
    var greetingCardMO: GreetingCardMO!
    var greetingCardRecord: CKRecord?
    
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
    
    var videoData: NSData? {
        didSet {
            if videoData == nil {
                imageView.backgroundColor = .clear
            }
            else {
                imageView.backgroundColor = .green
            }
        }
    }


    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        if let greetingCard = greetingCardMO {
            dateLabel.text = dateFormatter.string(from: greetingCard.greetingDate!)
            headingField.text = greetingCard.greetingHeading
            descriptionField.text = greetingCard.greetingDescription
            
            if let imageImage = greetingCard.greetingImage {
                imageView.image = UIImage(data: imageImage as Data)
            }
            
            if let qrImage = greetingCard.greetingQRCode {
                qrView.image = UIImage(data: qrImage as Data)
            }

            if let _ = greetingCard.greetingVideo {
//                let videoString = String(data: video, encoding: String.Encoding(rawValue: String.Encoding.utf32.rawValue))!//NSString.init(data: video, encoding: String.Encoding.utf8.rawValue)
//                let videoURL = URL(string: videoString)!//NSURL(string: videoString! as String)
//                
//                let item = AVPlayerItem(url: videoURL)
//                let player = AVPlayer(playerItem: item)
//                player.seek(to: CMTime.zero)
//                player.play()
                
//                videoView.image = UIImage(data: video)
                videoView.backgroundColor = .green
            }
        }
        else {
            dateLabel.text = dateFormatter.string(from: Date())
        }
        
        imagePicker = ImagePicker(presentationController: self, delegate: self)
        videoPicker2 = VideoPicker(presentationController: self, delegate: self)
        videoPicker.delegate = self
        headingField.becomeFirstResponder()
    }
    
    
    // MARK: - Data Persistence
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        let greetingCard = MagicGreetingCard(greetingCategory: "🎄",
                                         greetingDate: Date(),
                                         greetingDescription: descriptionField.text!,
                                         greetingHeading: headingField.text!,
                                         greetingIdentifier: "magicpaper" + UUID().uuidString,
                                         greetingImage: imageView.image ?? UIImage(),
                                         greetingQRCode: qrView.image ?? UIImage(),
                                         greetingVideo: videoView.image ?? UIImage())
        
        saveCoreData(greetingCard: greetingCard)
        saveCloudKit(greetingCard: greetingCard)
        
        dismiss(animated: true, completion: nil)
    }
    
    private func saveCoreData(greetingCard: MagicGreetingCard) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if greetingCardMO == nil {
                greetingCardMO = GreetingCardMO(context: appDelegate.persistentContainer.viewContext)
            }
            
            greetingCardMO.greetingCategory = greetingCard.greetingCategory
            greetingCardMO.greetingDate = greetingCard.greetingDate
            greetingCardMO.greetingDescription = greetingCard.greetingDescription
            greetingCardMO.greetingHeading = greetingCard.greetingHeading
            greetingCardMO.greetingIdentifier = greetingCard.greetingIdentifier
            if let qrCodeImage = greetingCard.greetingQRCode.pngData() {
                greetingCardMO.greetingQRCode = Data(qrCodeImage)
            }
            if let imageImage = greetingCard.greetingImage.pngData() {
                greetingCardMO.greetingImage = Data(imageImage)
            }
            
            if let videoData = videoData {
                greetingCardMO.greetingVideo = videoData as Data
            }

            print("Saving to Core Data")
            appDelegate.saveContext()
        }
    }
    
    private func saveCloudKit(greetingCard: MagicGreetingCard) {
        let container = CKContainer.default()
        let publicDatabase = container.publicCloudDatabase
        let record: CKRecord
        
        let imageFilePath = NSTemporaryDirectory() + greetingCard.greetingIdentifier//greetingCardMO.greetingIdentifier!
        let imageFileURL = URL(fileURLWithPath: imageFilePath)
        print(imageFilePath)
        
        if let currentRecord = greetingCardRecord {
            record = currentRecord
            print("currentRecord exists")
        }
        else {
            record = CKRecord(recordType: "MagicVideo")
            print("currentrecord doesn't exist")
        }
        
        record.setValue(greetingCard.greetingIdentifier, forKey: "greetingIdentifier")
        record.setValue(greetingCard.greetingHeading, forKey: "greetingHeading")
        record.setValue(greetingCard.greetingDescription, forKey: "greetingDescription")
        
        if let image = greetingCardMO.greetingImage {
            let imageData = image as Data
            let originalImage = UIImage(data: imageData)!
            let scalingFactor = (originalImage.size.width > 1024) ? 1024 / originalImage.size.width : 1.0
            let scaledImage = UIImage(data: imageData, scale: scalingFactor)!
            
            //WTF???
            ((try? scaledImage.jpegData(compressionQuality: 0.8)?.write(to: imageFileURL)) as ()??)
            
            let imageAsset = CKAsset(fileURL: imageFileURL)
            
            record.setValue(imageAsset, forKey: "greetingImage")
        }
        else {
            record.setObject(nil, forKey: "greetingImage")
        }
        
        
        
        
        
        
        
        
        //How the hell do you save a video to cloudkit???
        if let video = greetingCardMO.greetingVideo {
            let videoAsset = CKAsset(fileURL: imageFileURL)

//            record.setObject(videoAsset, forKey: "greetingVideo")
            print("trying to save a vid dude")
        }
        
        
        
        
        
        
        
        
        
        publicDatabase.save(record, completionHandler: { result, error in
            if self.greetingCardRecord != nil {
                print("Updating data to Cloud...")
            }
            else {
                print("Saving new data to Cloud...")
            }
            
            //Garbage collection
//            try? FileManager.default.removeItem(at: imageFileURL)
        })
        
//        let predicate = NSPredicate(format: "identifier=%@", greetingCard!.qrCode)
//        let query = CKQuery(recordType: "DrinkRecipe", predicate: predicate)
//        publicDatabase.perform(query, inZoneWith: nil, completionHandler: { results, error in
//            if let error = error {
//                print("Error querying Cloud: \(error)")
//            }
//            else {
//                if results!.count > 0 {
//                    let record = results![0]
//
//                    print("Found existing record when querying Cloud!")
//                    controller.currentRecord = record
//                }
//                else {
//                    print("No match found when querying Cloud")
//                }
//            }
//        })
    }
        
    
    
    // MARK: - Table view data source

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
        guard let movieURL = info[.mediaURL] as? URL else { return }
        
        videoData = NSData(contentsOf: movieURL)
        
        
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


