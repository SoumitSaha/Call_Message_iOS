//
//  LoginVC.swift
//  Call&Message
//
//  Created by Soumit Kanti Saha on 2025-09-19.
//

import UIKit
import SVProgressHUD
import FirebaseAuth

class LoginVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(onSocketConnected), name: .socketConnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSocketAuthError(_:)), name: .socketAuthError, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var apiResponseMessage: UILabel!
    
    @objc private func onSocketConnected() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
            SVProgressHUD.showSuccess(withStatus: "Connected")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let tabBar = HomeTabBarController()
                tabBar.modalPresentationStyle = .fullScreen
                self.present(tabBar, animated: true)
            }
        }
    }

    @objc private func onSocketAuthError(_ notification: Notification) {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
            SVProgressHUD.showError(withStatus: "Socket auth failed")
        }
    }
    
    func updateAlert(message: String, color: UIColor, error: String?) {
        DispatchQueue.main.async {
            self.apiResponseMessage.text = "\(message)\(error ?? "")"
            self.apiResponseMessage.textColor = color
        }
        return
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        guard let emailText = email.text, !emailText.isEmpty, let passwordText = password.text, !passwordText.isEmpty else {
            apiResponseMessage.text = "Please enter email and password"
            apiResponseMessage.textColor = .red
            return
        }
        
        SVProgressHUD.show(withStatus: "Logging in...")

        guard let emailText = email.text, !emailText.isEmpty, let passwordText = password.text, !passwordText.isEmpty else {
            apiResponseMessage.text = "Please enter email and password"
            apiResponseMessage.textColor = .red
            return
        }

        SVProgressHUD.show(withStatus: "Logging in...")

        Auth.auth().signIn(withEmail: emailText, password: passwordText) { result, error in
            if let error = error {
                SVProgressHUD.dismiss()
                self.updateAlert(message: "Login failed: ", color: .red, error: error.localizedDescription)
                return
            }

            guard let user = result?.user else {
                SVProgressHUD.dismiss()
                self.updateAlert(message: "Login failed: ", color: .red, error: "No user returned")
                return
            }

            // Save email for convenience
            UserDefaults.standard.set(emailText, forKey: "lastUserEmail")

            // IMPORTANT: reload user to get fresh verification state
            user.reload { reloadError in
                if let reloadError = reloadError {
                    SVProgressHUD.dismiss()
                    self.updateAlert(message: "Error: ", color: .red, error: reloadError.localizedDescription)
                    return
                }

                // If not verified -> go to VerificationVC
                if !user.isEmailVerified {
                    SVProgressHUD.showInfo(withStatus: "Email not verified")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.goToVerificationPage(emailText)
                    }
                    return
                }

                // Verified -> fetch ID token (you'll send this to backend later)
                user.getIDTokenForcingRefresh(true) { token, tokenError in
                    SVProgressHUD.dismiss()

                    if let tokenError = tokenError {
                        self.updateAlert(message: "Failed to get ID token: ", color: .red, error: tokenError.localizedDescription)
                        return
                    }

                    guard let token = token, !token.isEmpty else {
                        self.updateAlert(message: "Failed to get ID token: ", color: .red, error: "Empty token")
                        return
                    }

                    print("🔥 Firebase ID Token:\n\(token)")
                    self.printFirebaseUserInfo(user)

                    // ✅ Connect socket, then go home
                    SVProgressHUD.show(withStatus: "Connecting...")

                    let socketBaseURL = ngrok.shared.URL ?? ""

                    WebSocketManager.shared.connect(baseURL: socketBaseURL)
                }
            }
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
    
    func printFirebaseUserInfo(_ user: User) {
        print("========== 🔐 Firebase User Info ==========")
        print("UID: \(user.uid)")
        print("Email: \(user.email ?? "nil")")
        print("Email Verified: \(user.isEmailVerified)")
        print("Display Name: \(user.displayName ?? "nil")")
        print("Photo URL: \(user.photoURL?.absoluteString ?? "nil")")
        print("Phone Number: \(user.phoneNumber ?? "nil")")
        print("Is Anonymous: \(user.isAnonymous)")

        // Provider info (important for multi-login setups)
        print("Providers:")
        for provider in user.providerData {
            print("  - Provider ID: \(provider.providerID)")
            print("    UID: \(provider.uid)")
            print("    Email: \(provider.email ?? "nil")")
            print("    Display Name: \(provider.displayName ?? "nil")")
        }

        // Metadata
        let metadata = user.metadata
        print("Account Created At: \(metadata.creationDate?.description ?? "nil")")
        print("Last Sign-In At: \(metadata.lastSignInDate?.description ?? "nil")")

        print("==========================================")
    }
}
