//
//  VerificationVC.swift
//  Call&Message
//
//  Created by Soumit Kanti Saha on 2025-09-19.
//

import UIKit
import SVProgressHUD

class VerificationVC: UIViewController {
    
    var emailId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.email.text = self.emailId
    }
    
    @IBOutlet weak var email: UILabel!
    
    @IBOutlet weak var code: UITextField!
    
    @IBAction func codeSubmitted(_ sender: Any) {
        guard let codeText = code.text, !codeText.isEmpty else {
            SVProgressHUD.showError(withStatus: "Please enter the verification code")
            return
        }
        
        // Show loading
        SVProgressHUD.show(withStatus: "Verifying...")
        
        // Build request
        guard let url = URL(string: "\(ngrok.shared.URL ?? "")/verify") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": emailId ?? "",
            "code": codeText
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        // Start API call
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    SVProgressHUD.showError(withStatus: "Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    SVProgressHUD.showError(withStatus: "Invalid response")
                    return
                }
                
                switch httpResponse.statusCode {
                case 200:
                    SVProgressHUD.showSuccess(withStatus: "Email verified!")
                    DispatchQueue.main.async {
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
                case 400:
                    SVProgressHUD.showError(withStatus: "Invalid verification code")
                default:
                    SVProgressHUD.showError(withStatus: "Unexpected error: \(httpResponse.statusCode)")
                }
            }
        }
        
        task.resume()
    }
    
}
