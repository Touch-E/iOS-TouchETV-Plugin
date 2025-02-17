//
//  LangAndCurencyCollectionViewCell.swift
//  TouchE TV
//
//  Created by Jekil Dabhoya on 10/09/24.
//

import UIKit

class LangAndCurencyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lblname: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    
    func configure(with text: String) {
            lblname.text = text
        }
        
        override func awakeFromNib() {
            super.awakeFromNib()
            bgView.layer.borderWidth = 5
            bgView.layer.borderColor = UIColor.clear.cgColor
        }
      
        override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
            coordinator.addCoordinatedAnimations({ [weak self] in
                if self?.isFocused ?? false {
                    self?.bgView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    self?.bgView.layer.borderColor = UIColor.white.cgColor
                } else {
                    self?.bgView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self?.bgView.layer.borderColor = UIColor.clear.cgColor
                }
            }, completion: nil)
        }
}
