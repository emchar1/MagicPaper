//
//  GreetingCardController.swift
//  MagicPaper
//
//  Created by Eddie Char on 1/10/21.
//

import UIKit


class GreetingCardCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
}

class GreetingCardController: UITableViewController {
    
    var greetingCards: [GreetingCard] = []
    let dateFormatter = DateFormatter()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "MM/dd/yy"
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return greetingCards.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GreetingCardCell", for: indexPath) as! GreetingCardCell
        let greetingCard = greetingCards[indexPath.row]

        cell.dateLabel.text = dateFormatter.string(from: greetingCard.greetingDate)
        cell.iconLabel.text = greetingCard.greetingIcon
        cell.descriptionLabel.text = greetingCard.greetingHeadline

        return cell
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    //Cancel button segue
    @IBAction func unwindToHomeScreen(segue: UIStoryboardSegue) {
        
    }

}
