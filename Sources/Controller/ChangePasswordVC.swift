//
//  ChangePasswordVC.swift
//  
//
//  Created by Jaydip Godhani on 27/01/25.
//

import UIKit
import Alamofire

class ChangePasswordVC: UIViewController {

    static func storyboardInstance() -> ChangePasswordVC {
        return mainStoryboard.instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordVC
    }
    
    @IBOutlet weak var txtCurrentPassword: UITextField!
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtRepeat: UITextField!
    
    var userId: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = Bundle.module.loadNibNamed("ChangePasswordVC", owner: self, options: nil)?.first as? UIView {
            self.view = view
        }
    }
    @IBAction func btnBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSave(_ sender: UIButton) {
        changePassword()
    }
    
    
    
    func changePassword(){
        
        let params = [
            "password": txtCurrentPassword.text ?? "",
            "newPassword": txtNewPassword.text ?? "",
            "confirmPassword": txtRepeat.text ?? "",
            "id" : "\(userId ?? 0)"
        ] as [String : Any]
        
        print(params)
        start_loading()
        
        self.post_api_request_withJson("https://api-cluster.system.touchetv.com/backoffice-user/api/v1/user/changePassword\(loadContents)", params: params, headers: headersCommon).responseData { response in
            print(response.result)
            switch response.result {
            case .success(let data):
                do {
                    let asJSON = try JSONSerialization.jsonObject(with: data)
                    let dic = asJSON as? NSDictionary ?? [:]
                    debugPrint("change password response", dic)
                    let alert  = UIAlertController(title: "Change Password Succsesfull", message: nil, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "ok", style: .default) { _ in
                        self.navigationController?.popViewController(animated: true)
                    }
                    alert.addAction(ok)
                    self.present(alert, animated: true,completion: nil)
                } catch {
                    self.ShowAlert(title: "Error", message: response.error?.localizedDescription ?? "Something Went Wrong")
                }
            case .failure(let error):
                self.ShowAlert(title: "Error", message: "\(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                self.stop_loading()
            }
        }
       
    }
}
