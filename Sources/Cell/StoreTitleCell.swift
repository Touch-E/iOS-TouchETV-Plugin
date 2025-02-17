//
//  StoreTitleCell.swift
//  TouchE TV
//
//  Created by Jekil Dabhoya on 13/09/24.
//

import UIKit

class StoreTitleCell: UICollectionViewCell {

    @IBOutlet weak var viewName: UIViewX!
    
    @IBOutlet weak var storeNameLBL: UILabel!
    
    var storAction : ((Int) -> Void)?
    
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override var canBecomeFocused: Bool {
        return false
    }
    
    @IBAction func selectionAction(_ sender: UIButton) {
        if let action = storAction{
            action(index)
        }
    }
}

