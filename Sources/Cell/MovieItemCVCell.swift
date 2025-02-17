//
//  MovieItemCVCell.swift
//  TouchE TV
//
//  Created by Parth on 22/08/24.
//

import UIKit

class MovieItemCVCell: UICollectionViewCell {
    
    @IBOutlet weak var posterIMG: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        posterIMG.layer.borderWidth = 5
        posterIMG.layer.borderColor = UIColor.clear.cgColor
    }
  
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({ [weak self] in
            if self?.isFocused ?? false{
                self?.posterIMG.transform = CGAffineTransform(scaleX: 1.01, y: 1.01)
               self?.posterIMG.layer.borderColor = UIColor.white.cgColor
            } else {
                self?.posterIMG.transform = CGAffineTransform(scaleX: 1, y: 1)
                self?.posterIMG.layer.borderColor = UIColor.clear.cgColor
            }
        }, completion: nil)
    }
}
