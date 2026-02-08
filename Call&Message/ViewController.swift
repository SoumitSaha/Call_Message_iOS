//
//  ViewController.swift
//  Call&Message
//
//  Created by Soumit Kanti Saha on 2025-09-15.
//

import UIKit
import FirebaseAuth

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
        let firstLaunchKey = "hasLaunchedBefore"
        if !UserDefaults.standard.bool(forKey: firstLaunchKey) {
            UserDefaults.standard.set(true, forKey: firstLaunchKey)
            try? Auth.auth().signOut()
        }
        // Simulate a delay (like checking stored token or making API call)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if let user = Auth.auth().currentUser {
                if user.isEmailVerified {
                    self.goToHomePage()
                } else {
                    self.goToVerificationPage(user.email ?? "")
                }
            } else {
                self.goToLoginPage()
            }
        }
    }

    private func goToHomePage() {
        WebSocketManager.shared.connect(baseURL: ngrok.shared.URL ?? "")
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
        }
    }
    
    private func goToVerificationPage(_ email: String) {
        // Get the current storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        // Instantiate the view controller using its Storyboard ID
        if let VerificationVC = storyboard.instantiateViewController(withIdentifier: "VerificationVC") as? VerificationVC {
            VerificationVC.emailId = email
            VerificationVC.modalTransitionStyle = .crossDissolve
            VerificationVC.modalPresentationStyle = .fullScreen
            self.present(VerificationVC, animated: true, completion: nil)
        }
    }
}
