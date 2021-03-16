//
//  GreetingCardController.swift
//  MagicPaper
//
//  Created by Eddie Char on 1/10/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
//import FirebaseUI


// MARK: - Greeting Card Cell

class GreetingCardCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
}


// MARK: - Greeting Card Controller

class GreetingCardController: UITableViewController {
    
    // MARK: - Properties
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter
    }()

    var uid: String!
    var query: Query!
    var listener: ListenerRegistration!
    var greetingCards: [MagicGreetingCard] = []
//    var greetingCardAssets: [GreetingCardAsset] = []
    
    
    // MARK: - Initialization

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUser = Auth.auth().currentUser else {
            fatalError("Something went wrong... no user logged in. Quitting perfunctorily.")
        }
        
        uid = currentUser.uid
        query = Firestore.firestore().collection(FIR.collection).whereField(FIR.greetingUID, isEqualTo: currentUser.uid)
        
        guard FIR.allUsers == nil || FIR.allUsers!.range(of: currentUser.uid) == nil else {
            print("Only grab Storage assets once.")
            return
        }


        FIR.allUsers = FIR.allUsers == nil ? uid : (FIR.allUsers! + ", " + uid)
        print("Grabbing Storage assets for the first time for user(s): \(FIR.allUsers!)")

        //Grab the assets in Storage by looking at the files in Firestore. Genius!
        query.getDocuments { [weak self] (querySnapshot, error) in
            guard error == nil else {
                print("Error getting documents: \(error!)")
                return
            }

            guard let self = self else { return }

            for document in querySnapshot!.documents {
                let storageRef = Storage.storage().reference().child(self.uid)
                
                let imageRef = storageRef.child(FIR.storageImage).child("\(document.documentID).png")
                imageRef.getData(maxSize: 5 * K.mb) { (data, error) in
                    guard error == nil else { return }

                    self.updateAssets(for: document.documentID, image: UIImage(data: data!))
                }
                
                let videoRef = storageRef.child(FIR.storageVideo).child("\(document.documentID).mp4")
                videoRef.getData(maxSize: 18 * K.mb) { (data, error) in
                    guard error == nil else { return }
                    
                    videoRef.downloadURL { (url, error) in
                        guard let downloadURL = url else { return }
                        
                        self.updateAssets(for: document.documentID, video: downloadURL)
                    }
                }
                
                let qrCodeRef = storageRef.child(FIR.storageQR).child("\(document.documentID).png")
                qrCodeRef.getData(maxSize: K.mb) { (data, error) in
                    guard error == nil else { return }
                    
                    self.updateAssets(for: document.documentID, qrCode: UIImage(data: data!))
                }
            }//end for
        }//end query.snapshotListener
    }//end viewDidLoad
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        listener = query.addSnapshotListener { [weak self] (querySnapshot, error) in
            guard error == nil else {
                print("Error getting documents: \(error!)")
                return
            }
            
            guard let self = self else { return }
            

            //Update the model
            self.greetingCards = []
            
            for document in querySnapshot!.documents {
                let data = document.data()
                                
                guard let greetingDate = data[FIR.greetingDate] as? Timestamp,
                      let greetingCategory = data[FIR.greetingCategory] as? String,
                      let greetingDescription = data[FIR.greetingDescription] as? String,
                      let greetingHeading = data[FIR.greetingHeading] as? String,
                      let greetingUID = data[FIR.greetingUID] as? String else {
                    continue
                }
                
                self.greetingCards.append(MagicGreetingCard(id: document.documentID,
                                                            greetingDate: greetingDate.dateValue(),
                                                            greetingCategory: greetingCategory,
                                                            greetingDescription: greetingDescription,
                                                            greetingHeading: greetingHeading,
                                                            greetingUID: greetingUID))
            }//end for
            
            //Need this otherwise tableView will not udpate when listener updates the model!
            self.tableView.reloadData()
        }//end listener = query.addSnapshotListener
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener.remove()
    }
    
    /**
     Helper function that uploads asset(s) to the array by 1.) replacing it if it exists or 2.) appending if it doesn't exist.
     - parameters:
        - id: document ID to search for in the array
        - image: key image to replace/append (optional)
        - video: movie to replace/append (optional)
        - qrCode: QR code to replace/append (optional)
     */
    private func updateAssets(for id: String, image: UIImage? = nil, video: URL? = nil, qrCode: UIImage? = nil) {
        if let index = FIR.storageAssets.firstIndex(where: { $0.documentID == id }) {
            //Update the assets...
            if image != nil {
                FIR.storageAssets[index].image = image
                print("updateAssets called - added image: \(id).png")
            }
            
            if video != nil {
                FIR.storageAssets[index].video = video
                print("updateAssets called - added video: \(id).mp4")
            }
            
            if qrCode != nil {
                FIR.storageAssets[index].qrCode = qrCode
                print("updateAssets called - added qrCode: \(id).png")
            }
        }
        else {
            //...or create a new entry if it doesn't exist.
            FIR.storageAssets.append(GreetingCardAsset(documentID: id, image: image, video: video, qrCode: qrCode))
            print("FIR.storageAssets count: \(FIR.storageAssets.count)")
        }
    }
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return greetingCards.count
    }

    //NEED TO IMPROVE THIS!!
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GreetingCardCell", for: indexPath) as! GreetingCardCell
        let greetingCard = greetingCards[indexPath.row]

        cell.dateLabel.text = dateFormatter.string(from: greetingCard.greetingDate)
        cell.categoryLabel.text = greetingCard.greetingCategory
        cell.descriptionLabel.text = greetingCard.greetingHeading + " " + greetingCard.greetingDescription
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nc = segue.destination as? UINavigationController else {
            print("Logout pressed.")
            return
        }
        

        //Segue to AddGreetingCard
        if segue.identifier == "AddGreetingCard" {
            let controller = nc.topViewController as! GreetingCardDetailsController
            controller.uid = uid
            controller.delegate = self

        }

        //Segue to EditGreetingCard
        if segue.identifier == "EditGreetingCard" {
            let controller = nc.topViewController as! GreetingCardDetailsController
            controller.uid = uid
            controller.delegate = self

            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.docRef = Firestore.firestore().collection(FIR.collection).document(greetingCards[indexPath.row].id!)
                controller.greetingCard = greetingCards[indexPath.row]
                
                if let asset = FIR.storageAssets.first(where: { $0.documentID == greetingCards[indexPath.row].id! }) {
                    controller.image = asset.image
                    controller.videoURL = asset.video
                }
            }
        }
        
        //Segue to Test0Add (the real greeting card details)
        if segue.identifier == "SegueTest0Add" {
            
        }
        
        //Segue to Test0Edit
        if segue.identifier == "SegueTest0Edit" {
            let controller = nc.topViewController as! GreetingCardDetailsController2
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell),
               let asset = FIR.storageAssets.first(where: { $0.documentID == greetingCards[indexPath.row].id! }) {
                
                controller.image = asset.image
                controller.qrCode = asset.qrCode
                controller.heading = greetingCards[indexPath.row].greetingHeading
                controller.details = greetingCards[indexPath.row].greetingDescription
            }
        }
        
    }
    
    
}


extension GreetingCardController: GreetingCardDetailsControllerDelegate {
    func greetingCardDetailsController(_ controller: GreetingCardDetailsController,
                                       didUpdateFor image: UIImage?,
                                       video: URL?,
                                       qrCode: UIImage?) {
        guard let greetingCard = controller.greetingCard else {
            fatalError("fatalError: greetingCard object nil in GreetingCardController delegate function.")
        }
        
        updateAssets(for: greetingCard.id!, image: image, video: video, qrCode: qrCode)
    }
}
