//
//  ReplayViewController.swift
//  MagicPaper
//
//  Created by Eddie Char on 1/2/21.
//

import UIKit

class ReplayViewController: UIViewController {
    
    let segueMagic = "segueMagic"
    
    let replayButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Replay", for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir Next Bold", size: 18.0)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 30
        button.addTarget(self, action: #selector(replayPressed(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let rateLabel: UILabel = {
        let label = UILabel()
        label.text = "Loving the app? Drop a rating/review!"
        label.textAlignment = .center
        label.font = UIFont(name: "Avenir Next Regular", size: 24.0)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        
        view.addSubview(rateLabel)
        NSLayoutConstraint.activate([rateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
                                     rateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                                     view.trailingAnchor.constraint(equalTo: rateLabel.trailingAnchor, constant: 20)])

        view.addSubview(replayButton)
        NSLayoutConstraint.activate([replayButton.widthAnchor.constraint(equalToConstant: 100),
                                     replayButton.heightAnchor.constraint(equalToConstant: 60),
                                     replayButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     replayButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100)])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueMagic {
            let controller = segue.destination as! MagicPaperController
            
            if let qrCode = K.qrCode {
                controller.videoName = qrCode
            }
        }
    }
    
    
    @objc func replayPressed(_ sender: UIButton) {
        performSegue(withIdentifier: segueMagic, sender: nil)
    }
}
