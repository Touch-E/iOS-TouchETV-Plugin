//
//  categoriesCollectionViewCell.swift
//  TouchE TV
//
//  Created by Parth on 21/08/24.
//

import UIKit

class categoriesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imgVideo: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var nameHeightCON: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgVideo.layer.borderWidth = 5
        imgVideo.layer.borderColor = UIColor.clear.cgColor
    }
  
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({ [weak self] in
            if self?.isFocused ?? false{
                self?.imgVideo.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
               self?.imgVideo.layer.borderColor = UIColor.white.cgColor
            } else {
                self?.imgVideo.transform = CGAffineTransform(scaleX: 1, y: 1)
                self?.imgVideo.layer.borderColor = UIColor.clear.cgColor
            }
        }, completion: nil)
    }
}
