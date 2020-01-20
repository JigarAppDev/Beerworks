//
//  LoginViewController.swift
//  BeerElite
//
//  Created by Jigar on 13/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import KSToastView
import NVActivityIndicatorView
import SwiftyJSON

class LoginViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    //MARK: Sign Up Click
    @IBAction func btnSignUpClick(sender: UIButton) {
        let signupVC = self.storyboard?.instantiateViewController(withIdentifier:"SignUpViewController") as! SignUpViewController
        self.navigationController?.pushViewController(signupVC, animated: true)
    }
    
    //MARK: Forgot Password Click
    @IBAction func btnForgotClick(sender: UIButton) {
        let forgotVC = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        self.navigationController?.pushViewController(forgotVC, animated: true)
    }
    
    //MARK: Login Click
    @IBAction func btnLoginClick(sender: UIButton) {
        if userType == "User" {
            let userStoryBoard = UIStoryboard.init(name: "User", bundle: nil)
            let userHomeVC = userStoryBoard.instantiateViewController(withIdentifier: "UserHomeViewController") as! UserHomeViewController
            self.navigationController?.pushViewController(userHomeVC, animated: true)
        } else {
            let proStoryBoard = UIStoryboard.init(name: "Provider", bundle: nil)
            let proHomeVC = proStoryBoard.instantiateViewController(withIdentifier: "ProviderHomeViewController") as! ProviderHomeViewController
            self.navigationController?.pushViewController(proHomeVC, animated: true)
        }
        
        //if self.validateUser() {
            //self.makeLogin()
        //}
    }
    
    //MARK: - Validate Login Data Method
    func validateUser() -> Bool {
        var boolVal : Bool = true
        if txtEmail.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter Username")
            boolVal = false
        }else if txtPassword.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter Password")
            boolVal = false
        }
        return boolVal
    }
    
    //MARK: - Make User Login Method
    func makeLogin(){
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let identifier = UUID()
        let param : NSMutableDictionary =  NSMutableDictionary()
        param.setValue(txtEmail.text!, forKey: "email")
        param.setValue(txtPassword.text!, forKey: "password")
        param.setValue("1234567890", forKey: "device_token")
        param.setValue("2", forKey: "device_type")
        param.setValue(identifier.uuidString, forKey: "device_id")
        let successed = {(responseObject: AnyObject) -> Void in
            self.stopAnimating()
            if(responseObject.value(forKeyPath: "status") as! NSNumber == 1){
                //DispatchQueue.main.async() {
                    if (responseObject.value(forKeyPath: "data")) != nil{
                        self.setDefaultData(responseObject: responseObject)
                    }
                //}
            }else{
                self.showAlert(title: App_Title, msg: responseObject.value(forKeyPath: "message") as! String)
            }
        }
        let failure = {(error: AnyObject) -> Void in
            self.stopAnimating()
            self.showAlert(title: App_Title, msg: WrongMsg)
        }
        service.PostWithAlamofire(Parameters: param as? [String : AnyObject], action: LOGINAPI as NSString, success: successed, failure: failure)
    }
    
    func setDefaultData(responseObject : AnyObject) {
        
        let dataFull : JSON = JSON.init(responseObject)
        let data : JSON = JSON.init(dataFull["data"].stringValue)
        Defaults.setValue(data["token"].stringValue, forKey: "token")
        let uData: JSON = JSON.init(data["data"])
        userData = uData
        //guard let rowdata = try? uData.rawData() else {return}
        //Defaults.setValue(rowdata, forKey: "userDetail")
        Defaults.synchronize()
        
        //Navigate to home
        //let customerStoryBoard = UIStoryboard.init(name: "Customer", bundle: nil)
        //let customerHomeVC = customerStoryBoard.instantiateViewController(withIdentifier: "CustomerHomeViewController") as! CustomerHomeViewController
        //self.navigationController?.pushViewController(customerHomeVC, animated: true)
    }
}

extension UIViewController {
    func showAlert(title: String, msg: String)    {
        let alert = UIAlertController.init(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
