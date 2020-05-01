//
//  SupportViewController.swift
//  BeerElite
//
//  Created by Jigar on 17/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SwiftyJSON
import Kingfisher

class SupportViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet var txtEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Add Button Click
    @IBAction func btnSendEmail(sender: UIButton) {
        if self.validateUser() {
            self.sendSupportJob()
        }
    }
    
    //MARK: Send Mail
    @IBAction func btnSendMail(sender: UIButton) {
        let email = "thebeerelite@gmail.com"
        if let url = URL(string: "mailto:\(email)") {
          if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
          } else {
            UIApplication.shared.openURL(url)
          }
        }
    }
    
    //MARK: - Validate Data Method
    func validateUser() -> Bool {
        var boolVal : Bool = true
        if txtEmail.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter Email Address")
            boolVal = false
        }else if AppUtilities.sharedInstance.isValidEmail(emailAddressString: txtEmail.text!) == false {
            showAlert(title: App_Title, msg: "Please Enter Valid Email")
            boolVal = false
        }
        return boolVal
    }
    
    //MARK: API Calling
    func sendSupportJob() {
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        param.setValue(self.txtEmail.text, forKey: "email")
        
        let successed = {(responseObject: AnyObject) -> Void in
            self.stopAnimating()
            if responseObject != nil{
                let dataObj : JSON = JSON.init(responseObject)
                if(dataObj["status"].stringValue == "1") {
                    //self.showAlert(title: App_Title, msg: dataObj["message"].stringValue)
                    self.showAlert(title: App_Title, msg: "Success! We'll review and get back to you ASAP!")
                    self.txtEmail.text = ""
                }else{
                    self.showAlert(title: App_Title, msg: responseObject.value(forKeyPath: "message") as! String)
                }
            }
        }
        let failure = {(error: AnyObject) -> Void in
            self.stopAnimating()
            self.showAlert(title: App_Title, msg: WrongMsg)
        }
        
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: ADDSUPPORTAPI as NSString, success: successed, failure: failure)
    }
}
