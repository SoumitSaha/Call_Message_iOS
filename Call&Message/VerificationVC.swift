//
//  VerificationVC.swift
//  Call&Message
//
//  Created by Soumit Kanti Saha on 2025-09-19.
//

import UIKit
import SVProgressHUD
import FirebaseAuth

class VerificationVC: UIViewController {
    
    var emailId: String!
    
    @IBOutlet weak var email: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let email = Auth.auth().currentUser?.email ?? ""
        self.email.text = "A verification link has been sent to: \(email)."
    }
    
    @IBAction func checkVerificationStatus(_ sender: Any) {
        guard let user = Auth.auth().currentUser else {
            SVProgressHUD.showError(withStatus: "No logged-in user")
            return
        }

        SVProgressHUD.show(withStatus: "Checking verification...")

        // Important: reload to refresh isEmailVerified status
        user.reload { error in
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                return
            }

            if user.isEmailVerified {
                SVProgressHUD.showSuccess(withStatus: "Email verified!")

                // Go to main app (or login screen if you want)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.goToLoginPage()
                }
            } else {
                SVProgressHUD.showError(withStatus: "Not verified yet. Please check your email.")
            }
        }
    }
    
    @IBAction func resendVerificationLink(_ sender: Any) {
        guard let user = Auth.auth().currentUser else {
            SVProgressHUD.showError(withStatus: "No logged-in user")
            return
        }

        SVProgressHUD.show(withStatus: "Sending verification email...")
            user.sendEmailVerification { error in
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                return
            }
            SVProgressHUD.showSuccess(withStatus: "Verification email sent!")
        }
    }
    
    private func goToLoginPage() {
        // Get the current storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        // Instantiate the view controller using its Storyboard ID
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
            loginVC.modalTransitionStyle = .crossDissolve
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true, completion: nil)
        }
    }
}
