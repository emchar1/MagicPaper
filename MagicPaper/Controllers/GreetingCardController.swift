//
//  GreetingCardController.swift
//  MagicPaper
//
//  Created by Eddie Char on 1/10/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
//import FirebaseUI


// MARK: - Greeting Card Cell

class GreetingCardCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
}


// MARK: - Greeting Card Controller

class GreetingCardController: UITableViewController { //, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter
    }()

    var uid: String!
    var query: Query!
    var listener: ListenerRegistration!
    var greetingCards: [MagicGreetingCard]!
    
    
    // MARK: - Initialization

    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser!.uid
        query = Firestore.firestore().collection("greetingcards").whereField("greetingIdentifier", isEqualTo: uid!)
        greetingCards = []

        //So I deleted the getDocuments code because I figured the listener calls it occasionally in viewWillAppear, i.e. no need to have it in two different places.
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
                
                guard let tryDate = data["greetingDate"] as? String,
                      let greetingDate = self.dateFormatter.date(from: tryDate),
                      let greetingCategory = data["greetingCategory"] as? String,
                      let greetingDescription = data["greetingDescription"] as? String,
                      let greetingHeading = data["greetingHeading"] as? String,
                      let greetingIdentifier = data["greetingIdentifier"] as? String else {
                    continue
                }
                                                                 
                let card = MagicGreetingCard(greetingDate: greetingDate,
                                             greetingCategory: greetingCategory,
                                             greetingDescription: greetingDescription,
                                             greetingHeading: greetingHeading,
                                             greetingIdentifier: greetingIdentifier,
                                             //NEED TO IMPLEMENT THESE!!
                                             greetingImage: UIImage(),
                                             greetingQRCode: UIImage(),
                                             greetingVideo: UIImage())
                
                self.greetingCards.append(card)
            }
            
            //Need this otherwise tableView will not udpate when listener updates the model!
            self.tableView.reloadData()
        }
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
        let nc = segue.destination as! UINavigationController
        let controller = nc.topViewController as! GreetingCardDetailsController
        
        if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
            if segue.identifier == "EditGreetingCard" {
                controller.greetingCard = greetingCards[indexPath.row]
            }
            controller.uid = uid
        }
    }
        
    //WHY THIS SHIT AIN'T POPPIN?
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            print("Sign out.")
            navigationController?.popToRootViewController(animated: true)
        }
        catch let error as NSError {
            print("Error signing out: \(error)")
        }
    }
    
}
