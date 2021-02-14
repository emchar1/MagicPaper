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
    var greetingCardAssets: [GreetingCardAsset] = []
    
    
    // MARK: - Initialization

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUser = Auth.auth().currentUser else {
            fatalError("Something went wrong... no user logged in. Quitting perfunctorily.")
        }
        
        uid = currentUser.uid
        query = Firestore.firestore().collection(FIR.collection).whereField(FIR.greetingUID, isEqualTo: uid!)
        
        //Grab the images in Storage by looking at the files in Firestore. Genius!
        query.getDocuments { [weak self] (querySnapshot, error) in
            guard error == nil else {
                print("Error getting documents: \(error!)")
                return
            }

            guard let self = self else { return }

            for document in querySnapshot!.documents {
                let imageRef = Storage.storage().reference().child(FIR.storageImage).child("\(document.documentID).png")

                imageRef.getData(maxSize: 5 * 1024 * 1024) { (data, error) in
                    guard error == nil else {
                        print("\(error!.localizedDescription)")
                        return
                    }

                    self.greetingCardAssets.append(GreetingCardAsset(documentID: document.documentID,
                                                                     image: UIImage(data: data!),
                                                                     video: nil,
                                                                     qrCode: nil))
                }//end imageRef.getData
            }//end for
        }//end query.snapshotListener
    }
    
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
                                                            greetingUID: greetingUID,
                                                            //NEED TO IMPLEMENT THESE!!
                                                            greetingImage: "image",
                                                            greetingQRCode: "qr",
                                                            greetingVideo: "video"))
            }//end for
            
            //Need this otherwise tableView will not udpate when listener updates the model!
            self.tableView.reloadData()
        }//end listener = query.addSnapshotListener
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener.remove()
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
        if segue.identifier == "AddGreetingCard" {
            let nc = segue.destination as! UINavigationController
            let controller = nc.topViewController as! GreetingCardDetailsController
            controller.uid = uid
            controller.delegate = self
        }

        if segue.identifier == "EditGreetingCard" {
            let nc = segue.destination as! UINavigationController
            let controller = nc.topViewController as! GreetingCardDetailsController
            controller.uid = uid
            controller.delegate = self

            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.docRef = Firestore.firestore().collection(FIR.collection).document(greetingCards[indexPath.row].id!)
                controller.greetingCard = greetingCards[indexPath.row]
                
                if let asset = greetingCardAssets.first(where: { $0.documentID == greetingCards[indexPath.row].id! }) {
                    controller.image = asset.image
                    controller.video = asset.video
                    controller.qrCode = asset.qrCode
                }
            }
        }
        
    }
   
    
    
}


extension GreetingCardController: GreetingCardDetailsControllerDelegate {
    func greetingCardDetailsController(_ controller: GreetingCardDetailsController,
                                       image: UIImage?,
                                       video: UIImage?,
                                       qrCode: UIImage?) {
        guard let greetingCard = controller.greetingCard else {
            print("No greetingCard object attached.")
            return
        }

        
        if let index = greetingCardAssets.firstIndex(where: { $0.documentID == greetingCard.id! }) {
            greetingCardAssets[index].image = image
            greetingCardAssets[index].video = video
            greetingCardAssets[index].qrCode = qrCode
        }
        else {
            greetingCardAssets.append(GreetingCardAsset(documentID: greetingCard.id!,
                                                        image: image,
                                                        video: video,
                                                        qrCode: qrCode))
        }
        print("Added an image. greetingCardAssets now has: \(greetingCardAssets.count) items.")
    }
}
