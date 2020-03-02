//
//  AddCertiLevelViewController.swift
//  BeerElite
//
//  Created by Jigar on 21/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SwiftyJSON
import Kingfisher

class AddCertiLevelViewController: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet var btnCicerone_beer_server: UIButton!
    @IBOutlet var btnCertified_cicerone: UIButton!
    @IBOutlet var btnAdvanced_cicerone: UIButton!
    @IBOutlet var btnMaster_cicerone: UIButton!
    @IBOutlet var btnBjcp_judge: UIButton!
    @IBOutlet var btnSales_rep: UIButton!
    @IBOutlet var btnDoemens_bier: UIButton!
    @IBOutlet var btnNone: UIButton!
    
    var levelArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.btnCicerone_beer_server.isSelected = false
        self.btnCertified_cicerone.isSelected = false
        self.btnAdvanced_cicerone.isSelected = false
        self.btnMaster_cicerone.isSelected = false
        self.btnBjcp_judge.isSelected = false
        self.btnSales_rep.isSelected = false
        self.btnDoemens_bier.isSelected = false
        self.btnNone.isSelected = false
        
        if self.levelArray.count > 0 {
            for val in self.levelArray {
                if val.lowercased() == "sales rep" {
                    self.btnSales_rep.isSelected = true
                } else if val.lowercased() == "bjcp judge" {
                    self.btnBjcp_judge.isSelected = true
                } else if val.lowercased() == "none" {
                    self.btnNone.isSelected = true
                } else if val.lowercased() == "cicerone beer server" {
                    self.btnCicerone_beer_server.isSelected = true
                } else if val.lowercased() == "advanced cicerone" {
                    self.btnAdvanced_cicerone.isSelected = true
                } else if val.lowercased() == "certified cicerone" {
                    self.btnCertified_cicerone.isSelected = true
                } else if val.lowercased() == "master cicerone" {
                    self.btnMaster_cicerone.isSelected = true
                } else if val.lowercased() == "doemens bier" {
                    self.btnDoemens_bier.isSelected = true
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
            if self.btnCicerone_beer_server.isSelected == false {
                self.btnCicerone_beer_server.isSelected = true
            } else {
                self.btnCicerone_beer_server.isSelected = false
            }
        } else if sender.tag == 102 {
            if self.btnCertified_cicerone.isSelected == false {
                self.btnCertified_cicerone.isSelected = true
            } else {
                self.btnCertified_cicerone.isSelected = false
            }
        } else if sender.tag == 103 {
            if self.btnAdvanced_cicerone.isSelected == false {
                self.btnAdvanced_cicerone.isSelected = true
            } else {
                self.btnAdvanced_cicerone.isSelected = false
            }
        } else if sender.tag == 104 {
            if self.btnMaster_cicerone.isSelected == false {
                self.btnMaster_cicerone.isSelected = true
            } else {
                self.btnMaster_cicerone.isSelected = false
            }
        } else if sender.tag == 105 {
            if self.btnBjcp_judge.isSelected == false {
                self.btnBjcp_judge.isSelected = true
            } else {
                self.btnBjcp_judge.isSelected = false
            }
        } else if sender.tag == 106 {
            if self.btnSales_rep.isSelected == false {
                self.btnSales_rep.isSelected = true
            } else {
                self.btnSales_rep.isSelected = false
            }
        } else if sender.tag == 107 {
            if self.btnDoemens_bier.isSelected == false {
                self.btnDoemens_bier.isSelected = true
            } else {
                self.btnDoemens_bier.isSelected = false
            }
        } else if sender.tag == 108 {
            if self.btnNone.isSelected == false {
                self.btnNone.isSelected = true
            } else {
                self.btnNone.isSelected = false
            }
        }
    }
    
    //MARK: API Calling on Submit
    @IBAction func submitCertiLevels(sender: UIButton) {
        self.view.endEditing(true)
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        //let uid = Defaults.value(forKey: "user_id") as? String
        param.setValue(self.btnCicerone_beer_server.isSelected, forKey: "cicerone_beer_server")
        param.setValue(self.btnCertified_cicerone.isSelected, forKey: "certified_cicerone")
        param.setValue(self.btnAdvanced_cicerone.isSelected, forKey: "advanced_cicerone")
        param.setValue(self.btnMaster_cicerone.isSelected, forKey: "master_cicerone")
        param.setValue(self.btnBjcp_judge.isSelected, forKey: "bjcp_judge")
        param.setValue(self.btnSales_rep.isSelected, forKey: "sales_rep")
        param.setValue(self.btnDoemens_bier.isSelected, forKey: "doemens_bier")
        param.setValue(self.btnNone.isSelected, forKey: "none")
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
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: ADDCERTILEVELAPI as NSString, success: successed, failure: failure)
    }
}
