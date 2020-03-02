//
//  ApplyViewController.swift
//  BeerElite
//
//  Created by Jigar on 21/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SwiftyJSON
import Kingfisher

class ApplyViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet var txtFirstName: UITextField!
    @IBOutlet var txtLastName: UITextField!
    @IBOutlet var txtCurOccupation: UITextField!
    @IBOutlet var txtCityState: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Add Button Click
    @IBAction func btnAddInfo(sender: UIButton) {
        if self.validateUser() {
            self.applyForJob()
        }
    }
    
    //MARK: - Validate Data Method
    func validateUser() -> Bool {
        var boolVal : Bool = true
        if txtFirstName.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter FirstName")
            boolVal = false
        }else if txtLastName.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter LastName")
            boolVal = false
        }else if txtCurOccupation.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter Current Occupation")
            boolVal = false
        }else if txtCityState.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter Current City,State & Zip")
            boolVal = false
        }
        return boolVal
    }
    
    //MARK: API Calling
    func applyForJob() {
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        
        let uid = Defaults.value(forKey: "user_id") as? String
        param.setValue(uid, forKey: "job_added_by")
        
        let successed = {(responseObject: AnyObject) -> Void in
            self.stopAnimating()
            if responseObject != nil{
                let dataObj : JSON = JSON.init(responseObject)
                if(dataObj["status"].stringValue == "1") {
                    self.showAlert(title: App_Title, msg: dataObj["message"].stringValue)
                }else{
                    self.showAlert(title: App_Title, msg: responseObject.value(forKeyPath: "message") as! String)
                }
            }
        }
        let failure = {(error: AnyObject) -> Void in
            self.stopAnimating()
            self.showAlert(title: App_Title, msg: WrongMsg)
        }
        
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: APPLYFORJOBAPI as NSString, success: successed, failure: failure)
    }
}
