//
//  SignUpVC.swift
//  Call&Message
//
//  Created by Soumit Kanti Saha on 2025-09-19.
//

import UIKit
import SVProgressHUD

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
        
            // 1. Build request
            guard let url = URL(string: "\(ngrok.shared.URL ?? "")/register") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = [
                "email": emailText,
                "password": passwordText
            ]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil {
                    SVProgressHUD.showError(withStatus: "Network Error")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    SVProgressHUD.showError(withStatus: "Invalid response")
                    return
                }

                switch httpResponse.statusCode {
                case 200:
                    SVProgressHUD.showSuccess(withStatus: "Register successful")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)

                        // Instantiate the view controller using its Storyboard ID
                        if let verificationVC = storyboard.instantiateViewController(withIdentifier: "VerificationVC") as? VerificationVC {
                            verificationVC.emailId = emailText
                            verificationVC.modalTransitionStyle = .crossDissolve
                            verificationVC.modalPresentationStyle = .fullScreen
                                self.present(verificationVC, animated: true, completion: nil)
                        } else {
                            print("⚠️ Could not find VerificationVC with given ID")
                        }
                    }
                case 400:
                    SVProgressHUD.showError(withStatus: "Email Already Exists")
                case 500:
                    SVProgressHUD.showError(withStatus: "Code Send Failed")
                default:
                    SVProgressHUD.showError(withStatus: "Unexpected status code")
                }
            }

            task.resume()
    }
}
