//
//  CompanyPageViewController.swift
//  BeerElite
//
//  Created by Jigar on 18/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SwiftyJSON

class CompanyPageViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet var btnUpdateInfo: UIButton!
    @IBOutlet var btnUpdateAbout: UIButton!
    @IBOutlet var btnUpdateAddress: UIButton!
    @IBOutlet var txvAbout: UITextView!
    @IBOutlet var lblAddress: UILabel!
    @IBOutlet var lblWebsite: UILabel!
    var companyId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if userType == "User" {
            self.btnUpdateInfo.isHidden = true
            self.btnUpdateAbout.isHidden = true
            self.btnUpdateAddress.isHidden = true
            self.getCompanyInfo()
        } else {
            self.btnUpdateInfo.isHidden = false
            self.btnUpdateAbout.isHidden = false
            self.btnUpdateAddress.isHidden = false
        }
        
    }
    
    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    //MARK: Edit Company Info
    @IBAction func btnAddAboutUs(sender: UIButton) {
        let aboutVC = self.storyboard?.instantiateViewController(withIdentifier: "AddAboutCompanyViewController") as! AddAboutCompanyViewController
        self.navigationController?.pushViewController(aboutVC, animated: true)
    }
    
    //MARK: Edit Location & URL
    @IBAction func btnEditWebLocation(sender: UIButton) {
        let webVC = self.storyboard?.instantiateViewController(withIdentifier: "AddWebLocationViewController") as! AddWebLocationViewController
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    //MARK: Get Company Info
    func getCompanyInfo() {
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        param.setValue(self.companyId, forKey: "company_id")
        let successed = {(responseObject: AnyObject) -> Void in
            self.stopAnimating()
            if responseObject != nil{
                let dataObj : JSON = JSON.init(responseObject)
                if(dataObj["status"].stringValue == "1") {
                    let data = dataObj["data"].arrayValue
                    let cData = data[0]
                    self.txvAbout.text = cData["company_about"].stringValue
                    self.lblWebsite.text = cData["company_website"].stringValue
                    self.lblAddress.text = cData["company_address"].stringValue
                }else{
                    self.showAlert(title: App_Title, msg: responseObject.value(forKeyPath: "message") as! String)
                }
            }
        }
        let failure = {(error: AnyObject) -> Void in
            self.stopAnimating()
            self.showAlert(title: App_Title, msg: WrongMsg)
        }
        
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: VIEWCOMPANYAPI as NSString, success: successed, failure: failure)
    }
}
