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

            let settingsVC = UINavigationController(rootViewController: SettingsVC())
            settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape.fill"), tag: 3)

            viewControllers = [messagesVC, dialPadVC, historyVC, settingsVC]
        }
    
    
}
