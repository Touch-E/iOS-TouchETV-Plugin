//
//  LogoutPopupViewController.swift
//  
//
//  Created by Jaydip Godhani on 27/01/25.
//

import UIKit

public class LogoutPopupViewController: UIViewController {
    
    static func storyboardInstance() -> LogoutPopupViewController {
        return mainStoryboard.instantiateViewController(withIdentifier: "LogoutPopupViewController") as! LogoutPopupViewController
    }

    var onDismissBottomSheetClosure: (_ dismiss: Bool) -> Void = { _ in }

    public override func viewDidLoad() {
        super.viewDidLoad()

        if let view = Bundle.module.loadNibNamed("LogoutPopupViewController", owner: self, options: nil)?.first as? UIView {
            self.view = view
        }
    }


    @IBAction func btnCancelAction(_ sender: UIButton) {
        self.onDismissBottomSheetClosure(true)
        self.dismiss(animated: false)
    }
    @IBAction func btnLogoutAction(_ sender: UIButton) {
        self.onDismissBottomSheetClosure(true)
        UserDefaults.standard.setValue(nil, forKey: "userToken")
        UserDefaults.standard.synchronize()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
            let vc = authStoryboard.instantiateViewController(withIdentifier: "loginNav") as! UINavigationController
            UIApplication.shared.windows.first?.rootViewController = vc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }

}
