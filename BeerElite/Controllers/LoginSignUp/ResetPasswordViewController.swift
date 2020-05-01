//
//  ResetPasswordViewController.swift
//  BeerElite
//
//  Created by Jigar on 13/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import KSToastView
import NVActivityIndicatorView
import SwiftyJSON

class ResetPasswordViewController: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet var txtOTP: UITextField!
    @IBOutlet var txtPassword: UITextField!
    @IBOutlet var txtConfirmPassword: UITextField!
    
    var emailStr = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Submit Click
    @IBAction func btnSubmitClick(sender: UIButton) {
        if self.validateUser() {
            self.resetPassword()
        }
    }
    
    //MARK: Resend Click
    @IBAction func btnResendClick(sender: UIButton) {
        self.forgotPasswordAPI()
    }
    
    //MARK: - Validate Data Method
    func validateUser() -> Bool {
        var boolVal : Bool = true
        if txtOTP.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Invalid Temporary Password")
            boolVal = false
        }else if txtPassword.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter Password")
            boolVal = false
        }else if txtPassword.text!.count < 6 {
            showAlert(title: App_Title, msg: "Password must be at least 6 characters")
            boolVal = false
        }else if txtPassword.text != txtConfirmPassword.text {
            showAlert(title: App_Title, msg: "Password Must Match")
            boolVal = false
        }
        return boolVal
    }
    
    //MARK: - Make Reset Method
    func resetPassword(){
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        param.setValue(txtOTP.text!, forKey: "temp_pass")
        param.setValue(emailStr, forKey: "email")
        param.setValue(txtPassword.text!, forKey: "new_pass")
        
        let successed = {(responseObject: AnyObject) -> Void in
            self.stopAnimating()
            if responseObject != nil{
                let dataObj : JSON = JSON.init(responseObject)
                if(dataObj["status"].stringValue == "1") {
                    self.showAlertNavigate(title: "OK", msg: dataObj["message"].stringValue)
                }else{
                    if dataObj["message"].stringValue == "Wrong OTP" {
                        self.showAlert(title: App_Title, msg: "Invalid temporary password.")
                    } else {
                        self.showAlert(title: App_Title, msg: dataObj["message"].stringValue)
                    }
                }
            }
        }
        let failure = {(error: AnyObject) -> Void in
            self.stopAnimating()
            self.showAlert(title: App_Title, msg: WrongMsg)
        }
        service.PostWithAlamofire(Parameters: param as? [String : AnyObject], action: RESETPASSWORD as NSString, success: successed, failure: failure)
    }
    
    //MARK: - Navigate to Login Screen
    func showAlertNavigate(title: String, msg: String){
        let alert = UIAlertController.init(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "OK", style: .default) { (UIAlertAction) in
            for vc in self.navigationController!.viewControllers {
                if vc.isKind(of: LoginViewController.classForCoder()) {
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            }
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: Use to Resend OTP
    func forgotPasswordAPI(){
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        param.setValue(self.emailStr, forKey: "email")
        let successed = {(responseObject: AnyObject) -> Void in
            self.stopAnimating()
            if responseObject != nil{
                let dataObj : JSON = JSON.init(responseObject)
                if(dataObj["status"].stringValue == "1") {
                    if (responseObject.value(forKeyPath: "message")) != nil{
                        self.showAlert(title: App_Title, msg: responseObject.value(forKeyPath: "message") as! String)
                    }
                }else{
                    self.showAlert(title: App_Title, msg: responseObject.value(forKeyPath: "message") as! String)
                }
            }
        }
        let failure = {(error: AnyObject) -> Void in
            self.stopAnimating()
            self.showAlert(title: App_Title, msg: WrongMsg)
        }
        service.PostWithAlamofire(Parameters: param as? [String : AnyObject], action: FORGOTPASSWORD as NSString, success: successed, failure: failure)
    }
}
