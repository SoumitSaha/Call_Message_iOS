//
//  ViewController.swift
//  Call&Message
//
//  Created by Soumit Kanti Saha on 2025-09-15.
//

import UIKit

class InitialViewController: UIViewController {

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkUserStatus()
    }

    private func checkUserStatus() {
        // Simulate a delay (like checking stored token or making API call)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if self.isUserLoggedIn() {
                self.goToHomePage()
            } else {
                self.goToLoginPage()
            }
        }
    }

    private func isUserLoggedIn() -> Bool {
        // Replace with actual logic (e.g. check UserDefaults or Keychain)
        var loggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        let lastUser = UserDefaults.standard.string(forKey: "lastUserEmail")
        
        if lastUser == nil {
            return false
        } else if !loggedIn {
            let user = DatabaseManager.shared.getUser(byEmail: lastUser!)
            if user == nil {
                return false
            } else {
                let loginStatus = user!["isLoggedInStatus"]
                UserDefaults.standard.set(loginStatus as! Bool, forKey: "isLoggedIn")
                loggedIn = loginStatus as! Bool
                return loginStatus as! Bool
            }
        }
        
        return loggedIn
    }

    private func goToHomePage() {
        let tabBar = HomeTabBarController()
        tabBar.modalPresentationStyle = .fullScreen
        self.present(tabBar, animated: true)
    }

    private func goToLoginPage() {
        // Get the current storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        // Instantiate the view controller using its Storyboard ID
        if let LoginSignUpVC = storyboard.instantiateViewController(withIdentifier: "LoginSignUpVC") as? LoginSignUpVC {
            LoginSignUpVC.modalTransitionStyle = .crossDissolve
            LoginSignUpVC.modalPresentationStyle = .fullScreen
            self.present(LoginSignUpVC, animated: true, completion: nil)
        } else {
            print("⚠️ Could not find LoginSignUpVC with given ID")
        }
    }
}
