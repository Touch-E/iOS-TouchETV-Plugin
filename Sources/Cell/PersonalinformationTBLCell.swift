//
//  PersonalinformationTBLCell.swift
//  TouchE TV
//
//  Created by Parth on 10/09/24.
//

import UIKit

class PersonalinformationTBLCell: UITableViewCell {
    
    @IBOutlet weak var txtFirstName: UITextFieldX!
    @IBOutlet weak var txtSecoundName: UITextFieldX!
    @IBOutlet weak var txtEmail: UITextFieldX!
    @IBOutlet weak var txtMobileNumber: UITextFieldX!

    override func awakeFromNib() {
        super.awakeFromNib()
       fillData()
    }
    
    func fillData(){
        txtFirstName.text = "\(profileData.value(forKey: "firstName") ?? "NA")"
        txtSecoundName.text = "\(profileData.value(forKey: "lastName") ?? "NA")"
        txtEmail.text = "\(profileData.value(forKey: "emailAddress")!)"
        txtMobileNumber.text = "\(profileData.value(forKey: "phoneNumber") ?? "NA")"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
