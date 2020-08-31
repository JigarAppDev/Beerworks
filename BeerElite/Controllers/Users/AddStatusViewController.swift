//
//  AddStatusViewController.swift
//  BeerElite
//
//  Created by Jigar on 18/06/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SwiftyJSON
import Kingfisher

class AddStatusViewController: UIViewController, NVActivityIndicatorViewable {

    var statusArray = [String]()
    
    @IBOutlet var btnReady: UIButton!
    @IBOutlet var btnOpp: UIButton!
    @IBOutlet var btnUnAvail: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.btnReady.isSelected = false
        self.btnOpp.isSelected = false
        self.btnUnAvail.isSelected = false
        
        if self.statusArray.count > 0 {
            for val in self.statusArray {
                if val.lowercased() == "ready to work" {
                    self.btnReady.isSelected = true
                } else if val.lowercased() == "open to new opportunities" {
                    self.btnOpp.isSelected = true
                } else if val.lowercased() == "unavailable" {
                    self.btnUnAvail.isSelected = true
                }
            }
        }
    }

    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Selection of Options
    @IBAction func btnSelectionClick(sender: UIButton) {
        self.btnReady.isSelected = false
        self.btnOpp.isSelected = false
        self.btnUnAvail.isSelected = false
        sender.isSelected = true
    }
    
    //MARK: API Calling on Submit
    @IBAction func submitStatus(sender: UIButton) {
        //status : 1 = ready to work , 2 = open to apportunity , 3 = unavailable
        self.view.endEditing(true)
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        if self.btnReady.isSelected == true {
            param.setValue("1", forKey: "user_current_status")
        } else if self.btnOpp.isSelected == true {
            param.setValue("2", forKey: "user_current_status")
        } else if self.btnUnAvail.isSelected == true {
            param.setValue("3", forKey: "user_current_status")
        } else {
            self.showAlert(title: App_Title, msg: "Select your current status!")
            return
        }
        print(param)
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
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: STATUSAPI as NSString, success: successed, failure: failure)
    }
}
