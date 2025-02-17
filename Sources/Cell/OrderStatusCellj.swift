//
//  OrderStatusCell.swift
//  TouchE TV
//
//  Created by Jekil Dabhoya on 13/09/24.
//

import UIKit

class OrderStatusCellj: UICollectionViewCell {

    @IBOutlet weak var statusName: UILabel!
    @IBOutlet weak var dotUV: UIViewX!
    @IBOutlet weak var backUV: UIViewX!
    
    
    var statusAction : ((Int) -> Void)?
    
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override var canBecomeFocused: Bool {
        return false
    }
    @IBAction func btnOrderStatusAction(_ sender: UIButton) {
        if let action = statusAction{
            action(index)
        }
    }
    
}
