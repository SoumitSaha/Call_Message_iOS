//
//  LoginVC.swift
//  Call&Message
//
//  Created by Soumit Kanti Saha on 2025-09-19.
//

import UIKit
import SVProgressHUD

class LoginVC: UIViewController {

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
    
    @IBAction func loginPressed(_ sender: Any) {
        guard let emailText = email.text, !emailText.isEmpty,
                  let passwordText = password.text, !passwordText.isEmpty else {
                apiResponseMessage.text = "Please enter email and password"
                apiResponseMessage.textColor = .red
                return
            }
            
            // 1. Build request
        guard let url = URL(string: "\(ngrok.shared.URL ?? "")/login") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = [
                "email": emailText,
                "password": passwordText
            ]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
            SVProgressHUD.show(withStatus: "Logging in...")

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil {
                    SVProgressHUD.showError(withStatus: "Network error")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    SVProgressHUD.showError(withStatus: "Invalid response")
                    return
                }

                switch httpResponse.statusCode {
                case 200:
                    SVProgressHUD.showSuccess(withStatus: "Login successful")
                    if let data = data {
                        do {
                            if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                                print("📦 User data:", jsonObject)
                                let email = jsonObject["email"] as! String
                                let name = jsonObject["name"] as? String
                                let verified = jsonObject["verified"] as? Int
                                let dob = jsonObject["verified"] as? Int64
                                if verified == 1 {
                                    DatabaseManager.shared.insertUser(name: name ?? "", email: email, dob: Date(timeIntervalSince1970: TimeInterval(dob ?? -1)), image: nil, isLoggedIn: true)
                                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                                    UserDefaults.standard.set(email, forKey: "lastUserEmail")
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        let tabBar = HomeTabBarController()
                                        tabBar.modalPresentationStyle = .fullScreen
                                        self.present(tabBar, animated: true)
                                    }
                                }
                            }
                        } catch {
                            print("❌ JSON parsing error:", error)
                        }
                    }
                case 400:
                    SVProgressHUD.showError(withStatus: "Invalid credentials")
                case 403:
                    SVProgressHUD.showInfo(withStatus: "Email not verified")
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
                case 500:
                    SVProgressHUD.showError(withStatus: "Code Send Failed")
                default:
                    SVProgressHUD.showError(withStatus: "Unexpected Error")
                }
            }

            task.resume()
    }
    
}
