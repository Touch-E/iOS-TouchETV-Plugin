//
//  AccountDetailsCell.swift
//  TouchE TV
//
//  Created by Jaydip Godhani on 29/08/24.
//
import UIKit

class AccountDetailsCell: UITableViewCell {

    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var profileIMG: UIImageViewX!
    @IBOutlet weak var emailLBL: UILabel!
    @IBOutlet weak var fnameLBL: UILabel!
    @IBOutlet weak var snameLBL: UILabel!
    @IBOutlet weak var genderLBL: UILabel!
    @IBOutlet weak var eventDateLBL: UILabel!
    @IBOutlet weak var mobileLBL: UILabel!
    @IBOutlet weak var langLBL: UILabel!
    @IBOutlet weak var currencyLBL: UILabel!
    var cellExpand : (()->Void)?
    var cellEdit : (()->Void)?
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
    @IBAction func editClick_Action(_ sender: UIButton) {
        if let action = cellEdit{
           action()
       }
    }
    @IBAction func expandClickAction(_ sender: UIButton) {
        if let action = cellExpand{
           action()
       }
    }
}
