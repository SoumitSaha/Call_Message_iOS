//
//  UsersVC.swift
//  Call&Message
//
//  Created by Soumit Kanti Saha on 2026-02-08.
//

import UIKit
import SVProgressHUD
import FirebaseAuth

final class UsersVC: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    enum Segment: Int {
        case recommended = 0
        case friends = 1
    }
    
    struct UserSearchResult: Decodable {
        let uid: String
        let email: String
        let name: String?
        let verified: Bool
        let last_online: Int?
    }

    struct UserRow {
        let uid: String
        let email: String
        let name: String?
        let online: Bool
        let mutualCount: Int?   // only for recommended
    }

    private var recommended: [UserRow] = []
    private var friends: [UserRow] = []

    private var currentSegment: Segment {
        Segment(rawValue: segmentedControl.selectedSegmentIndex) ?? .recommended
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set navigation bar title
        title = "Users"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]  // Title in black
        
        navigationController?.navigationBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "userCell")
        tableView.backgroundColor = .clear
        
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.textColor = .black

        // default UI state
        segmentedControl.selectedSegmentIndex = 0
        let normalAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.darkGray]

            let selectedAttrs: [NSAttributedString.Key: Any] = [ .foregroundColor: UIColor.white ]

            segmentedControl.setTitleTextAttributes(normalAttrs, for: .normal)
            segmentedControl.setTitleTextAttributes(selectedAttrs, for: .selected)
        updateUIForSegment()

        // initial load
        loadRecommended()
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        updateUIForSegment()
        switch currentSegment {
        case .recommended:
            if recommended.isEmpty { loadRecommended() }
        case .friends:
            if friends.isEmpty { loadFriends() }
        }
    }

    private func updateUIForSegment() {
        // Only show search in Recommended tab
        tableView.reloadData()
    }

    // MARK: - Networking (you will connect with your real endpoints)

    private func loadFriends() {
        SVProgressHUD.show(withStatus: "Loading friends...")
        // TODO: call GET /friends with Bearer token
        // For now: mock
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            SVProgressHUD.dismiss()
            self.friends = [] // fill from API
            self.tableView.reloadData()
        }
    }

    private func loadRecommended() {
        SVProgressHUD.show(withStatus: "Loading recommended...")
        // TODO: call your recommended endpoint (later)
        // For now: mock
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            SVProgressHUD.dismiss()
            self.recommended = [] // fill from API
            self.tableView.reloadData()
        }
    }

    private func searchUserByEmail(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return }

        guard let base = ngrok.shared.URL, !base.isEmpty else {
            SVProgressHUD.showError(withStatus: "Missing server URL")
            return
        }

        guard let user = Auth.auth().currentUser else {
            SVProgressHUD.showError(withStatus: "Not logged in")
            return
        }

        SVProgressHUD.show(withStatus: "Searching...")

        user.getIDTokenForcingRefresh(true) { [weak self] token, error in
            guard let self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    SVProgressHUD.showError(withStatus: "Token error: \(error.localizedDescription)")
                }
                return
            }

            guard let token = token, !token.isEmpty else {
                DispatchQueue.main.async {
                    SVProgressHUD.showError(withStatus: "Empty token")
                }
                return
            }

            var comps = URLComponents(string: "\(base)/users/search")
            // ✅ new param name on server: q
            comps?.queryItems = [URLQueryItem(name: "q", value: trimmed)]

            guard let url = comps?.url else {
                DispatchQueue.main.async {
                    SVProgressHUD.showError(withStatus: "Bad URL")
                }
                return
            }

            var req = URLRequest(url: url)
            req.httpMethod = "GET"
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            req.setValue("application/json", forHTTPHeaderField: "Accept")

            URLSession.shared.dataTask(with: req) { data, response, err in
                if let err = err {
                    DispatchQueue.main.async {
                        SVProgressHUD.showError(withStatus: "Network: \(err.localizedDescription)")
                    }
                    return
                }

                guard let http = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        SVProgressHUD.showError(withStatus: "Invalid response")
                    }
                    return
                }

                guard (200...299).contains(http.statusCode) else {
                    var message = "Error \(http.statusCode)"
                    if let data = data,
                       let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let errMsg = obj["error"] as? String {
                        message = errMsg
                    }
                    DispatchQueue.main.async {
                        SVProgressHUD.showError(withStatus: message)
                    }
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        SVProgressHUD.showError(withStatus: "Empty body")
                    }
                    return
                }

                do {
                    print(print("data: \(data)"))
                    let results = try JSONDecoder().decode([UserSearchResult].self, from: data)

                    let rows: [UserRow] = results.map { res in
                        UserRow(
                            uid: res.uid,
                            email: res.email,
                            name: res.name,
                            online: false,       // you can infer from last_online later
                            mutualCount: nil
                        )
                    }

                    DispatchQueue.main.async {
                        if rows.isEmpty {
                            SVProgressHUD.showInfo(withStatus: "No users found")
                        } else {
                            SVProgressHUD.showSuccess(withStatus: "Found \(rows.count)")
                        }

                        // Replace recommended list with search results (clean UX)
                        // or merge into existing list if you prefer.
                        self.recommended = rows
                        self.tableView.reloadData()
                    }
                } catch {
                    DispatchQueue.main.async {
                        SVProgressHUD.showError(withStatus: "Parse error")
                    }
                }
            }.resume()
        }
    }
    
    
}

extension UsersVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentSegment {
            case .recommended: return recommended.count
            case .friends: return friends.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell

        let row: UserRow
        switch currentSegment {
            case .recommended: row = recommended[indexPath.row]
            case .friends: row = friends[indexPath.row]
        }

        // cell.textLabel?.text = row.name?.isEmpty == false ? row.name : row.email

        if currentSegment == .recommended {
            cell.email.text = row.email
            cell.onlineStatus.text = "\(row.online ? "Online" : "Offline")"
        } else {
            
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // Later:
        // - Recommended: tap -> send friend request
        // - Friends: tap -> open chat/call screen
    }
}

extension UsersVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchUserByEmail(searchBar.text ?? "")
    }
}
