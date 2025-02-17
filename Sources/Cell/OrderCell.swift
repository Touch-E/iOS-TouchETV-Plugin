//
//  OrderCell.swift
//  TouchE TV
//
//  Created by Jaydip Godhani on 30/08/24.
//

import UIKit

class OrderCell: UITableViewCell {

    var orderAction : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override var canBecomeFocused: Bool {
        return false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func orderClick_Action(_ sender: UIButton) {
        if let action = orderAction{
            action()
        }
    }
    
}
