//
//  GenresTBLCell.swift
//  TouchE TV
//
//  Created by Parth on 23/08/24.
//

import UIKit

class GenresTBLCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLBL: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLBL.layer.cornerRadius = 35
        titleLBL.clipsToBounds = true
    }
}
