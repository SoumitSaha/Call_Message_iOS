//
//  UserCell.swift
//  Call&Message
//
//  Created by Soumit Kanti Saha on 2026-02-08.
//

import UIKit

class UserCell: UITableViewCell {

    var alreadyFriend: Bool = false
    var userEmail: String?
    var userOnlineStatus: String?
    
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var onlineStatus: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if alreadyFriend {
            addButton.isHidden = true
        }
        self.email.text = userEmail ?? ""
        self.onlineStatus.text = userOnlineStatus ?? ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addFriendPressed(_ sender: Any) {
        
    }
    
}
