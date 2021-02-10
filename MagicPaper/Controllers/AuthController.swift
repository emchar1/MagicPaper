//
//  AuthController.swift
//  MagicPaper
//
//  Created by Eddie Char on 2/8/21.
//

import UIKit
import Firebase

class AuthController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginErrorLabel: UILabel!
    @IBOutlet weak var peekPasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginErrorLabel.alpha = 0
                
        let email = UserDefaults.standard.string(forKey: "loginEmail")
        let password = UserDefaults.standard.string(forKey: "loginPassword")
                
        emailField.text = email
        passwordField.text = password
        
        peekPasswordButton.addTarget(self, action: #selector(peekPasswordTapped(_:)), for: .touchDown)
        peekPasswordButton.addTarget(self, action: #selector(unpeekPasswordTapped(_:)), for: .touchUpInside)
    }
    
    @objc func peekPasswordTapped(_ sender: UIButton) {
        passwordField.isSecureTextEntry = false
    }
    
    @objc func unpeekPasswordTapped(_ sender: UIButton) {
        passwordField.isSecureTextEntry = true
    }
    
    //Cancel button segue
    @IBAction func unwindToHomeScreen(segue: UIStoryboardSegue) {
        
    }

    @IBAction func loginPressed(_ sender: UIButton) {
        guard let email = emailField.text, let password = passwordField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            guard error == nil else {
                self.loginErrorLabel.alpha = 1
                UIView.animate(withDuration: 0.5, delay: 2.0, options: .curveEaseIn, animations: {
                    self.loginErrorLabel.alpha = 0
                }, completion: nil)

                print(error!.localizedDescription)
                return
            }
            
            //Save password to UserDefaults
            UserDefaults.standard.set(email, forKey: "loginEmail")
            UserDefaults.standard.set(password, forKey: "loginPassword")

//            print("user: \(authResult?.user.uid)")

            self.performSegue(withIdentifier: "segueLogin", sender: nil)
            
        }
    }

    
}
