//
//  OrderListCell.swift
//  TouchE TV
//
//  Created by Jekil Dabhoya on 11/09/24.
//

import UIKit

import UIKit

class OrderListCell: UITableViewCell {

    @IBOutlet weak var orderNOLBL: UILabel!
    @IBOutlet weak var orderDateLBL: UILabel!
    @IBOutlet weak var totalPurchaseLBL: UILabel!
    var cellViewButton : (()->Void)?
    
    
    var selectionAction : ((Int) -> Void)?
    
    var index = 0
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func btnSelectionAction(_ sender: UIButton) {
        if let action = selectionAction{
            action(index)
        }
    }
}
