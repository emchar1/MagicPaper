//
//  GreetingCardController.swift
//  MagicPaper
//
//  Created by Eddie Char on 1/10/21.
//

import UIKit
import CoreData
import CloudKit


// MARK: - Greeting Card Cell

class GreetingCardCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
}


// MARK: - Greeting Card Controller

class GreetingCardController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
    var greetingCards: [GreetingCardMO] = []
    var context: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<GreetingCardMO>!
    let dateFormatter = DateFormatter()
    
    
    // MARK: - Initialization

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "MM/dd/yy"
        
        loadCoreData()
    }
    
    private func loadCoreData() {
        let fetchRequest: NSFetchRequest<GreetingCardMO> = /*NSFetchRequest<GreetingCardMO>(entityName: "GreetingCard")*/GreetingCardMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "greetingDate", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            context = appDelegate.persistentContainer.viewContext
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
            fetchedResultsController.delegate = self
            
            do {
                try fetchedResultsController.performFetch()
                
                if let fetchedObjects = fetchedResultsController.fetchedObjects {
                    //This is where it populates the array!
                    greetingCards = fetchedObjects
                }
            }
            catch {
                print("Core Data Loading Error: \(error)")
            }
        }
    }

    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return greetingCards.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GreetingCardCell", for: indexPath) as! GreetingCardCell
        let greetingCard = greetingCards[indexPath.row]

        cell.dateLabel.text = dateFormatter.string(from: greetingCard.greetingDate!)
        cell.categoryLabel.text = greetingCard.greetingCategory
        cell.descriptionLabel.text = greetingCard.greetingHeading! + " " + greetingCard.greetingDescription!

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditGreetingCard" {
            let nc = segue.destination as! UINavigationController
            let controller = nc.topViewController as! GreetingCardDetailsController

            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.greetingCardMO = greetingCards[indexPath.row]
            }
        }
    }
    
    //Cancel button segue
    @IBAction func unwindToHomeScreen(segue: UIStoryboardSegue) {
        
    }
    
    
    // MARK: - NSFetchedResultsControllerDelegate methods
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //MUST SET SEARCH CONTROLLER TO NOT ACTIVE TO PREVENT A BUG WHERE IF A SEARCH IS OCCURING, AND USER CLICKS "+" TO ADD A NEW RECIPE, THE VIEW GETS ALL SCREWED UP!
        //        searchController.isActive = false
        
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        default:
            tableView.reloadData()
        }
        
        if let fetchedObjects = controller.fetchedObjects {
            greetingCards = fetchedObjects as! [GreetingCardMO]
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}
