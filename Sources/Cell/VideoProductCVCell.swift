//
//  VideoProductCVCell.swift
//  TouchE TV
//
//  Created by Parth on 03/09/24.
//

import UIKit

class VideoProductCVCell: UICollectionViewCell {
    
    @IBOutlet weak var backUV: UIView!
    @IBOutlet weak var productImageIMG: UIImageView!
    @IBOutlet weak var titleLBL: UILabel!
    @IBOutlet weak var countLBL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backUV.layer.borderWidth = 4
        backUV.layer.borderColor = UIColor.clear.cgColor
    }
  
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({ [weak self] in
            if self?.isFocused ?? false{
                self?.backUV.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
               self?.backUV.layer.borderColor = UIColor.white.cgColor
            } else {
                self?.backUV.transform = CGAffineTransform(scaleX: 1, y: 1)
                self?.backUV.layer.borderColor = UIColor.clear.cgColor
            }
        }, completion: nil)
    }
}
