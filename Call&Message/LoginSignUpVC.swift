//
//  LoginSignUpVC.swift
//  Call&Message
//
//  Created by Soumit Kanti Saha on 2025-09-19.
//

import UIKit

class LoginSignUpVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        // Get the current storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        // Instantiate the view controller using its Storyboard ID
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
            loginVC.modalTransitionStyle = .crossDissolve
            loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true, completion: nil)
        } else {
            print("⚠️ Could not find LoginVC with given ID")
        }
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        // Get the current storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        // Instantiate the view controller using its Storyboard ID
        if let signUpVC = storyboard.instantiateViewController(withIdentifier: "SignUpVC") as? SignUpVC {
            signUpVC.modalTransitionStyle = .crossDissolve
            signUpVC.modalPresentationStyle = .fullScreen
                self.present(signUpVC, animated: true, completion: nil)
        } else {
            print("⚠️ Could not find SignUpVC with given ID")
        }
    }
    
    @IBAction func deleteDB(_ sender: Any) {
        DatabaseManager.shared.deleteDatabaseFile()
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "lastUserEmail")
    }
    
}
