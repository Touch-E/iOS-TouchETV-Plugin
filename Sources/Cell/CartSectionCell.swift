//
//  CartSectionCell.swift
//  TouchE TV
//
//  Created by Parth on 03/09/24.
//

import UIKit

class CartSectionCell: UITableViewCell {

    @IBOutlet weak var checkBTN: UIButton!
    @IBOutlet weak var checkIMG: UIImageView!
    @IBOutlet weak var brandNameLBL: UILabel!
    @IBOutlet weak var backUV: UIView!
    @IBOutlet weak var brandNameLeftCON: NSLayoutConstraint!

    var brandSelectChange: ((Bool) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backUV.layer.cornerRadius = 10
        backUV.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }
    @IBAction func checkClick_Action(_ sender: UIButton) {
        if checkIMG.image == UIImage(named: "check-box-empty", in: Bundle.module, with: nil){
            if let action = brandSelectChange{
                action(true)
            }
        }else{
            if let action = brandSelectChange{
                action(false)
            }
        }
    }

}
