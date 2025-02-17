//
//  OrderStatusCell.swift
//  TouchE TV
//
//  Created by Parth on 02/09/24.
//

import UIKit

class OrderStatusCell: UICollectionViewCell {    
    @IBOutlet weak var statusName: UILabel!
    @IBOutlet weak var dotUV: UIView!
    @IBOutlet weak var backUV: UIViewX!
    @IBOutlet weak var nameLBLLeftCON: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //backUV.layer.borderWidth = 4
       // backUV.layer.borderColor = UIColor.clear.cgColor
    }
  
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        let borderColor = UIColor(red: 58/255, green: 171/255, blue: 242/255, alpha: 1)
        coordinator.addCoordinatedAnimations({ [weak self] in
            if self?.isFocused ?? false{
                self?.backUV.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                self?.backUV.layer.borderColor = borderColor.cgColor
            } else {
               
                if self?.backUV.borderColor == borderColor{
                    self?.backUV.transform = CGAffineTransform(scaleX: 1, y: 1)
                    //self?.backUV.layer.borderColor = UIColor.clear.cgColor
                }else{
                    self?.backUV.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self?.backUV.layer.borderColor = UIColor.clear.cgColor
                }
                
            }
        }, completion: nil)
    }
}
