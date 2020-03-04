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
import GoogleSignIn
import MapKit

class LoginViewController: UIViewController, NVActivityIndicatorViewable, GIDSignInDelegate {
    
    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var txtPassword: UITextField!
    var isForSocial = false
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    var lati = "21.17"
    var longi = "72.83"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        locManager.requestWhenInUseAuthorization()

        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            guard let currentLocation = locManager.location else {
                return
            }
            print(currentLocation.coordinate.latitude)
            print(currentLocation.coordinate.longitude)
            self.lati = "\(currentLocation.coordinate.latitude)"
            self.longi = "\(currentLocation.coordinate.longitude)"
        }
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
        if self.validateUser() {
            self.makeLogin()
        }
    }
    
    //MARK: - Validate Login Data Method
    func validateUser() -> Bool {
        var boolVal : Bool = true
        if txtEmail.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter Email")
            boolVal = false
        }else if AppUtilities.sharedInstance.isValidEmail(emailAddressString: txtEmail.text!) == false {
            showAlert(title: App_Title, msg: "Please Enter Valid Email")
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
            
            if responseObject != nil{
                let dataObj : JSON = JSON.init(responseObject)
                if(dataObj["status"].stringValue == "1") {
                    if (responseObject.value(forKeyPath: "data")) != nil{
                        self.isForSocial = false
                        self.setDefaultData(responseObject: responseObject)
                    }
                }else{
                    self.showAlert(title: App_Title, msg: responseObject.value(forKeyPath: "error") as! String)
                }
                
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
        let data : JSON = JSON.init(dataFull["data"])
        Defaults.setValue(data["token"].stringValue, forKey: "token")
        if self.isForSocial == true {
            let uData: JSON = JSON.init(data["user"].dictionaryObject!)
            userData = uData
        } else {
            let uData: JSON = JSON.init(data["data"].dictionaryObject!)
            userData = uData
        }
        let userRole = userData["user_type"].stringValue
        let user_ID = userData["id"].stringValue
        let user_Email = userData["email"].stringValue
        let profilePic = userData["profile_pic"].stringValue
        if profilePic != "" {
            Defaults.setValue(profilePic, forKey: "profile_pic")
        }
        let user_Name = userData["username"].stringValue
        Defaults.setValue(user_Name, forKey: "user_name")
        Defaults.setValue(userRole, forKey: "user_type")
        Defaults.setValue(user_ID, forKey: "user_id")
        Defaults.setValue(user_Email, forKey: "user_email")
        Defaults.setValue(true, forKey: "is_logged_in")
        Defaults.setValue(userData["city"].stringValue, forKey: "user_city")
        Defaults.synchronize()
        
        //Navigate to home
        if userType == "User" {
            let userStoryBoard = UIStoryboard.init(name: "User", bundle: nil)
            let userHomeVC = userStoryBoard.instantiateViewController(withIdentifier: "UserHomeViewController") as! UserHomeViewController
            self.navigationController?.pushViewController(userHomeVC, animated: true)
        } else {
            let proStoryBoard = UIStoryboard.init(name: "Provider", bundle: nil)
            let proHomeVC = proStoryBoard.instantiateViewController(withIdentifier: "ProviderHomeViewController") as! ProviderHomeViewController
            self.navigationController?.pushViewController(proHomeVC, animated: true)
        }
    }
    
    //MARK: Google Login Click
    @IBAction func btnGoogleLoginClick(sender: UIButton) {
        view.endEditing(true)
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    //MARK: - Google Sign In Delegate Method
    
    func sign(_ signIn: GIDSignIn!,present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!,dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            
            startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
            
            let fullName : [String] = user.profile!.name.components(separatedBy: " ")
            self.loginBySocial(name: fullName[0], id: user.userID, email: user.profile.email!, type: "1")
            GIDSignIn.sharedInstance().signOut()
        } else {
            self.stopAnimating()
            print("\(error.debugDescription)")
        }
    }
    
    //MARK: Login by Social
    func loginBySocial(name:String,id:String,email:String,type:String) {
        let type = "1"
        var emailId = email
        if email == "" {
            emailId = name
        }
        self.view.endEditing(true)
        self.startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        let Url = String(format: BASEURL + LOGINBYSOCIAL)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        var uType = ""
        if userType == "User" {
            uType = "1" //user_type = 1 = user , 2 = provider
        } else {
            uType = "2" //user_type = 1 = user , 2 = provider
        }
        let paramString = "username=\(name)&thirdparty_id=\(id)&email=\(emailId)&login_type=\(type)&device_token=123456789&device_type=2&device_id=\(deviceId)&latitude=\(self.lati)&longitude=\(self.longi)&user_type=\(uType)"
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                self.stopAnimating()
            }
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    let dataObj = json as! NSDictionary
                    if dataObj.value(forKey: "status") as! Int == 1 {
                        print(dataObj)
                    }
                    let dataObj1 = JSON.init(json)
                    if dataObj1["status"].intValue == 1 {
                        print(dataObj1)
                    } else {
                        DispatchQueue.main.async {
                            self.showAlert(title: App_Title, msg: dataObj1["message"].stringValue)
                        }
                    }
                    DispatchQueue.main.async {
                        self.isForSocial = true
                        self.setDefaultData(responseObject: dataObj)
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
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
