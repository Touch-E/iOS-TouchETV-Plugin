//
//  RatePopupViewController.swift
//  
//
//  Created by Jaydip Godhani on 28/01/25.
//

import UIKit
import Cosmos

public class RatePopupViewController: UIViewController {

    static func storyboardInstance() -> RatePopupViewController {
        return mainStoryboard.instantiateViewController(withIdentifier: "RatePopupViewController") as! RatePopupViewController
    }
    
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var reviewStartUV: CosmosView!
    @IBOutlet weak var rateItemTitleLBL: UILabel!
    
    
    var onDismissBottomSheetClosure: (_ dismiss: Bool) -> Void = { _ in }
    var onDismissWithRateClosure: (_ txtValue: String, _ rateValue: Double) -> Void = {_,_ in}
    
    let placeholderLabel = UILabel()
    var titleName = ""
    var ratingValue = 5
    var isRating = false

    public override func viewDidLoad() {
        super.viewDidLoad()
        if let view = Bundle.module.loadNibNamed("RatePopupViewController", owner: self, options: nil)?.first as? UIView {
            self.view = view
        }
        
        rateItemTitleLBL.text = titleName
        // Request focus for reviewStartUV
        setNeedsFocusUpdate()
        updateFocusIfNeeded()
    }
    
    public override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [reviewStartUV] // Set the reviewStartUV as the preferred focus item
    }

   
    @IBAction func btnRatingStarActionView(_ sender: UIButton) {
        if !isRating {
            if ratingValue == 5 {
                reviewStartUV.rating = 4
                ratingValue = 4
            } else if ratingValue == 4 {
                reviewStartUV.rating = 3
                ratingValue = 3
            } else if ratingValue == 3 {
                reviewStartUV.rating = 2
                ratingValue = 2
            } else if ratingValue == 2 {
                reviewStartUV.rating = 1
                ratingValue = 1
            } else if ratingValue == 1 {
                reviewStartUV.rating = 0
                ratingValue = 0
                isRating = true
            }
        } else {
            if ratingValue == 0 {
                reviewStartUV.rating = 1
                ratingValue = 1
            } else if ratingValue == 1 {
                reviewStartUV.rating = 2
                ratingValue = 2
            } else if ratingValue == 2 {
                reviewStartUV.rating = 3
                ratingValue = 3
            } else if ratingValue == 3 {
                reviewStartUV.rating = 4
                ratingValue = 4
            } else if ratingValue == 4 {
                reviewStartUV.rating = 5
                ratingValue = 5
                isRating = false
            }
        }
    }
    @IBAction func btnCancelAction(_ sender: UIButton) {
        self.onDismissBottomSheetClosure(true)
        self.dismiss(animated: false)
    }
    
    @IBAction func btnRateAction(_ sender: UIButton) {
        onDismissWithRateClosure(txtDescription.text ?? "", reviewStartUV.rating)
        self.dismiss(animated: false)
    }
}


extension RatePopupViewController: UITextViewDelegate{
    public func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
