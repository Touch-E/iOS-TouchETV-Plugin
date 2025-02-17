//
//  SelectedFilterCell.swift
//  TouchE TV
//
//  Created by Jekil Dabhoya on 13/09/24.
//

import UIKit

class SelectedFilterCell: UICollectionViewCell {

    @IBOutlet weak var backUV: UIViewX!
    @IBOutlet weak var itemNameLBL: UILabel!
    var closeAction : (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override var canBecomeFocused: Bool {
        return false
    }

    @IBAction func closeClick_Action(_ sender: UIButton) {
        if let action = closeAction{
            action()
        }
    }
}
