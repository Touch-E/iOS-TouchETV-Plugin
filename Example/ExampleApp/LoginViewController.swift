//
//  LoginViewController.swift
//  ExampleApp
//
//  Created by Parth on 24/01/25.
//

import UIKit
import TouchETVPlugin
class LoginViewController: UIViewController {

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailTF.text = "kishanchecker123@gmail.com"
        passwordTF.text = "Kishan@123"
    }
    @IBAction func loginClick_Action(_ sender: Any) {
        if emailTF.text!.isEmpty {
            ShowAlert1(title: "Error", message: "Please enter Email.")
            
        } else if !emailTF.text!.isValidEmail() {
            ShowAlert1(title: "Error", message: "Please enter valid Email.")
            
        }else if passwordTF.text!.isEmpty {
            
            ShowAlert1(title: "Error", message: "Please enter Password.")
        }else {
            LoginAPI()
            
        }
    }
}
extension LoginViewController {
    func LoginAPI(){
        
        TouchETVPluginVC.shared.userAuthentication(username: emailTF.text ?? "", password: passwordTF.text ?? "") { result in
            switch result {
            case .success(let resultValue):
                print("Operation successful: \(resultValue)")
                
                UserToken = resultValue.token
                UserDefaults.standard.set(UserToken, forKey: "userToken")
                
                userTID = resultValue.userId
                UserDefaults.standard.set(userTID, forKey: "userID")

                profileTData = resultValue.profileData
                save()
                let testViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                self.navigationController?.pushViewController(testViewController, animated: true)
                
            case .failure(let error):
                print("Error: \(error)")
                self.ShowAlert1(title: "Error", message: "Wrong Username and Password")
            }
        }
       
    }
}
