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
        let messagesVC = UINavigationController(rootViewController: MessagesVC())
        messagesVC.tabBarItem = UITabBarItem(title: "Messages", image: UIImage(systemName: "message.fill"), tag: 0)
        
        let dialPadVC = UINavigationController(rootViewController: DialPadVC())
        dialPadVC.tabBarItem = UITabBarItem(title: "Dialpad", image: UIImage(systemName: "phone.fill"), tag: 1)
        
        let historyVC = UINavigationController(rootViewController: CallHistoryVC())
        historyVC.tabBarItem = UITabBarItem(title: "History", image: UIImage(systemName: "clock.fill"), tag: 2)
        
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let settingsVCInstance = storyboard.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        let settingsNav = UINavigationController(rootViewController: settingsVCInstance)
        settingsNav.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape.fill"), tag: 3)
        
        viewControllers = [messagesVC, dialPadVC, historyVC, settingsNav]
        
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
        
        
        WebSocketManager.shared.connect(email: UserDefaults.standard.string(forKey: "lastUserEmail") ?? "", baseURL: "\(ngrok.shared.URL ?? "")")
    }
}
