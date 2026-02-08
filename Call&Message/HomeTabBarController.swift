//
//  HomeTabBarController.swift
//  Call&Message
//
//  Created by Soumit Kanti Saha on 2025-09-19.
//

import UIKit

class HomeTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create ViewControllers for each tab
        let usersStoryboard = UIStoryboard(name: "Users", bundle: nil)
        let usersVCInstance = usersStoryboard.instantiateViewController(withIdentifier: "UsersVC") as! UsersVC
        let usersNav = UINavigationController(rootViewController: usersVCInstance)
        usersNav.tabBarItem = UITabBarItem(title: "Users", image: UIImage(systemName: "person.2.fill"), tag: 0)
        
        let messagesVC = UINavigationController(rootViewController: MessagesVC())
        messagesVC.tabBarItem = UITabBarItem(title: "Messages", image: UIImage(systemName: "message.fill"), tag: 1)
        
        let dialPadVC = UINavigationController(rootViewController: DialPadVC())
        dialPadVC.tabBarItem = UITabBarItem(title: "Dialpad", image: UIImage(systemName: "phone.fill"), tag: 2)
        
        let historyVC = UINavigationController(rootViewController: CallHistoryVC())
        historyVC.tabBarItem = UITabBarItem(title: "History", image: UIImage(systemName: "clock.fill"), tag: 3)
        
        let settingsStoryboard = UIStoryboard(name: "Settings", bundle: nil)
        let settingsVCInstance = settingsStoryboard.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        let settingsNav = UINavigationController(rootViewController: settingsVCInstance)
        settingsNav.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape.fill"), tag: 4)
        
        viewControllers = [usersNav, messagesVC, dialPadVC, historyVC, settingsNav]
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        tabBar.standardAppearance = appearance
        
        // If using iOS 15+, also set scrollEdgeAppearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        
        tabBar.tintColor = .black  // Selected icon/text color
        tabBar.unselectedItemTintColor = .gray
        
        UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        // WebSocketManager.shared.connect(email: UserDefaults.standard.string(forKey: "lastUserEmail") ?? "", baseURL: "\(ngrok.shared.URL ?? "")")
    }
}
