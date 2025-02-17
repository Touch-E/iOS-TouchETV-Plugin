//
//  PosttoTBLCell.swift
//  TouchE TV
//
//  Created by Parth on 10/09/24.
//

import UIKit

class PosttoTBLCell: UITableViewCell {

    @IBOutlet weak var lblHome: UILabel!
    @IBOutlet weak var sAddressHome: UILabel!
    @IBOutlet weak var bAddressHome: UILabel!
    @IBOutlet weak var btnHomeChange: UIButton!
    @IBOutlet weak var backUV: UIView!
    @IBOutlet weak var sepratorLineUV: UIView!
    
    var changeAddresss : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func changeAddressClick_Action(_ sender: UIButton) {
        if let action = changeAddresss{
            action()
        }
    }
    
}
