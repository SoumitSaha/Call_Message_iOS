//
//  SignUpVC.swift
//  Call&Message
//
//  Created by Soumit Kanti Saha on 2025-09-19.
//

import UIKit
import SVProgressHUD
import FirebaseAuth

class SignUpVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var apiResponseMessage: UILabel!
    
    func updateAlert(message: String, color: UIColor, error: String?) {
        DispatchQueue.main.async {
            self.apiResponseMessage.text = "\(message)\(error ?? "")"
            self.apiResponseMessage.textColor = color
        }
        return
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        guard let emailText = email.text, !emailText.isEmpty,
              let passwordText = password.text, !passwordText.isEmpty else {
            apiResponseMessage.text = "Please enter email and password"
            apiResponseMessage.textColor = .red
            return
        }

        SVProgressHUD.show(withStatus: "Signing Up...")

        Auth.auth().createUser(withEmail: emailText, password: passwordText) { result, error in
            if let error = error {
                SVProgressHUD.dismiss()
                self.updateAlert(
                    message: "Signup failed: ",
                    color: .red,
                    error: error.localizedDescription
                )
                return
            }

            guard let user = result?.user else {
                SVProgressHUD.dismiss()
                self.updateAlert(
                    message: "Signup failed: ",
                    color: .red,
                    error: "No user returned"
                )
                return
            }

            // Send verification email
            user.sendEmailVerification { error in
                if let error = error {
                    SVProgressHUD.dismiss()
                    self.updateAlert(
                        message: "Failed to send verification email: ",
                        color: .red,
                        error: error.localizedDescription
                    )
                    return
                }

                // Fetch ID token (you'll send this to backend later)
                user.getIDTokenForcingRefresh(true) { token, error in
                    SVProgressHUD.dismiss()

                    if let error = error {
                        self.updateAlert(
                            message: "Failed to get ID token: ",
                            color: .red,
                            error: error.localizedDescription
                        )
                        return
                    }

                    // SUCCESS
                    print("Firebase ID Token:")
                    print(token ?? "nil")

                    // Optional: save email for convenience
                    UserDefaults.standard.set(emailText, forKey: "lastUserEmail")

                    // Go to VerificationVC
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let verificationVC = storyboard.instantiateViewController(
                            withIdentifier: "VerificationVC"
                        ) as? VerificationVC {

                            verificationVC.emailId = emailText
                            verificationVC.modalTransitionStyle = .crossDissolve
                            verificationVC.modalPresentationStyle = .fullScreen
                            self.present(verificationVC, animated: true)
                        }
                    }
                }
            }
        }
    }

}
