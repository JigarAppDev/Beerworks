//
//  SignUpViewController.swift
//  BeerElite
//
//  Created by Jigar on 13/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import KSToastView
import NVActivityIndicatorView
import SwiftyJSON

class SignUpViewController: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet var txtFullname: UITextField!
    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var txtPassword: UITextField!
    @IBOutlet var txtConfirmPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Login Click
    @IBAction func btnLoginClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Sign Up Click
    @IBAction func btnSignUpClick(sender: UIButton) {
        if self.validateUser() {
            //self.makeSignUp()
        }
    }
    
    //MARK: - Validate Signup Data Method
    func validateUser() -> Bool {
        var boolVal : Bool = true
        if txtFullname.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter Username")
            boolVal = false
        } else if txtEmail.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter Email Address")
            boolVal = false
        }else if AppUtilities.sharedInstance.isValidEmail(emailAddressString: txtEmail.text!) == false {
            showAlert(title: App_Title, msg: "Please Enter Valid Email")
            boolVal = false
        }else if txtPassword.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter Password")
            boolVal = false
        }else if txtPassword.text != txtConfirmPassword.text {
            showAlert(title: App_Title, msg: "Confirm Password is Mismatch!")
            boolVal = false
        }
        return boolVal
    }
    
    //MARK: - Make SignUp Method
    func makeSignUp(){
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let identifier = UUID()
        let param : NSMutableDictionary =  NSMutableDictionary()
        param.setValue(txtFullname.text!, forKey: "name")
        param.setValue(txtEmail.text!, forKey: "email")
        param.setValue(txtPassword.text!, forKey: "password")
        param.setValue("21.17", forKey: "user_lat")
        param.setValue("72.83", forKey: "user_long")
        param.setValue("1234567890", forKey: "device_token")
        param.setValue("2", forKey: "device_type")
        param.setValue(identifier.uuidString, forKey: "device_id")
        param.setValue("1", forKey: "user_role") //1=customer, 2=provider
        param.setValue("395001", forKey: "location") //Postal Code here
        
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
        service.PostWithAlamofire(Parameters: param as? [String : AnyObject], action: SIGNAPI as NSString, success: successed, failure: failure)
    }
    
    func setDefaultData(responseObject : AnyObject) {
        
        let dataFull : JSON = JSON.init(responseObject)
        let data : JSON = JSON.init(dataFull["data"].stringValue)
        Defaults.setValue(data["token"].stringValue, forKey: "token")
        let uData: JSON = JSON.init(data["user"])
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
