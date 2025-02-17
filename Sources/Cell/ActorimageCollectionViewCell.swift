//
//  ActorimageCollectionViewCell.swift
//  TouchE TV
//
//  Created by Parth on 22/08/24.
//

import UIKit

class ActorimageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgActor: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgActor.layer.borderWidth = 5
        imgActor.layer.borderColor = UIColor.clear.cgColor
    }
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({ [weak self] in
            if self?.isFocused ?? false{
                self?.imgActor.transform = CGAffineTransform(scaleX: 1.01, y: 1.01)
               self?.imgActor.layer.borderColor = UIColor.white.cgColor
            } else {
                self?.imgActor.transform = CGAffineTransform(scaleX: 1, y: 1)
                self?.imgActor.layer.borderColor = UIColor.clear.cgColor
            }
        }, completion: nil)
    }

}
