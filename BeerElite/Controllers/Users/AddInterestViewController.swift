//
//  AddInterestViewController.swift
//  BeerElite
//
//  Created by Jigar on 21/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SwiftyJSON
import Kingfisher

class AddInterestViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet var btnBartending: UIButton!
    @IBOutlet var btnBar_back: UIButton!
    @IBOutlet var btnBartending_liquor: UIButton!
    @IBOutlet var btnAdministrative: UIButton!
    @IBOutlet var btnBrewing: UIButton!
    @IBOutlet var btnSales_rep: UIButton!
    @IBOutlet var btnServer_restaurant: UIButton!
    @IBOutlet var btnOther: UIButton!
    
    var interestArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.btnServer_restaurant.isSelected = false
        self.btnBar_back.isSelected = false
        self.btnAdministrative.isSelected = false
        self.btnOther.isSelected = false
        self.btnBrewing.isSelected = false
        self.btnSales_rep.isSelected = false
        self.btnBartending.isSelected = false
        self.btnBartending_liquor.isSelected = false
        
        if self.interestArray.count > 0 {
            for val in self.interestArray {
                if val.lowercased() == "sales rep" {
                    self.btnSales_rep.isSelected = true
                } else if val.lowercased() == "brewing" {
                    self.btnBrewing.isSelected = true
                } else if val.lowercased() == "other" {
                    self.btnOther.isSelected = true
                } else if val.lowercased() == "administrative" {
                    self.btnAdministrative.isSelected = true
                } else if val.lowercased() == "bar back" {
                    self.btnBar_back.isSelected = true
                } else if val.lowercased() == "server restaurant" {
                    self.btnServer_restaurant.isSelected = true
                } else if val.lowercased() == "bartending liquor" {
                    self.btnBartending_liquor.isSelected = true
                } else if val.lowercased() == "bartending" {
                    self.btnBartending.isSelected = true
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
        if sender.tag == 101 {
            if self.btnBartending.isSelected == false {
                self.btnBartending.isSelected = true
            } else {
                self.btnBartending.isSelected = false
            }
        } else if sender.tag == 102 {
            if self.btnBar_back.isSelected == false {
                self.btnBar_back.isSelected = true
            } else {
                self.btnBar_back.isSelected = false
            }
        } else if sender.tag == 103 {
            if self.btnBartending_liquor.isSelected == false {
                self.btnBartending_liquor.isSelected = true
            } else {
                self.btnBartending_liquor.isSelected = false
            }
        } else if sender.tag == 104 {
            if self.btnAdministrative.isSelected == false {
                self.btnAdministrative.isSelected = true
            } else {
                self.btnAdministrative.isSelected = false
            }
        } else if sender.tag == 105 {
            if self.btnBrewing.isSelected == false {
                self.btnBrewing.isSelected = true
            } else {
                self.btnBrewing.isSelected = false
            }
        } else if sender.tag == 106 {
            if self.btnSales_rep.isSelected == false {
                self.btnSales_rep.isSelected = true
            } else {
                self.btnSales_rep.isSelected = false
            }
        } else if sender.tag == 107 {
            if self.btnServer_restaurant.isSelected == false {
                self.btnServer_restaurant.isSelected = true
            } else {
                self.btnServer_restaurant.isSelected = false
            }
        } else if sender.tag == 108 {
            if self.btnOther.isSelected == false {
                self.btnOther.isSelected = true
            } else {
                self.btnOther.isSelected = false
            }
        }
    }

    //MARK: API Calling on Submit
    @IBAction func submitInterestAns(sender: UIButton) {
        self.view.endEditing(true)
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        //let uid = Defaults.value(forKey: "user_id") as? String
        param.setValue(self.btnBartending.isSelected, forKey: "bartending")
        param.setValue(self.btnBar_back.isSelected, forKey: "bar_back")
        param.setValue(self.btnBartending_liquor.isSelected, forKey: "bartending_liquor")
        param.setValue(self.btnAdministrative.isSelected, forKey: "administrative")
        param.setValue(self.btnBrewing.isSelected, forKey: "brewing")
        param.setValue(self.btnSales_rep.isSelected, forKey: "sales_rep")
        param.setValue(self.btnServer_restaurant.isSelected, forKey: "server_restaurant")
        param.setValue(self.btnOther.isSelected, forKey: "other")
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
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: ADDINTERESTAPI as NSString, success: successed, failure: failure)
    }
}
