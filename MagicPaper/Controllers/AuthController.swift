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
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginErrorLabel.alpha = 0
        loginButton.isEnabled = true
                
        let email = UserDefaults.standard.string(forKey: "loginEmail")
        let password = UserDefaults.standard.string(forKey: "loginPassword")
                
        emailField.text = email
        passwordField.text = password
        
        peekPasswordButton.addTarget(self, action: #selector(peekPasswordTapped(_:)), for: .touchDown)
        peekPasswordButton.addTarget(self, action: #selector(unpeekPasswordTapped(_:)), for: .touchUpInside)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func peekPasswordTapped(_ sender: UIButton) {
        passwordField.isSecureTextEntry = false
    }
    
    @objc func unpeekPasswordTapped(_ sender: UIButton) {
        passwordField.isSecureTextEntry = true
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        
        if location.isOutside(of: emailField.bounds) && location.isOutside(of: passwordField.bounds) {
            emailField.endEditing(true)
            passwordField.endEditing(true)
        }
    }
    
    //Logout button segue
    @IBAction func unwindToAuthController(segue: UIStoryboardSegue) {
        loginButton.isEnabled = true

        do {
            try Auth.auth().signOut()
            print("Sign out.")
        }
        catch let error as NSError {
            print("Error signing out: \(error)")
        }
    }

    @IBAction func loginPressed(_ sender: UIButton) {
        guard let email = emailField.text, let password = passwordField.text else { return }
        
        //prevents multiple button taps resulting in stupid warning saying presenting view is not in window hierarchy
        loginButton.isEnabled = false
        
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

            self.performSegue(withIdentifier: "segueLogin", sender: nil)
        }
    }

    
}
