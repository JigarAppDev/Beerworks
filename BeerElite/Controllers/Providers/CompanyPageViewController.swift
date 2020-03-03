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
import Kingfisher

class CompanyPageViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet var btnUpdateInfo: UIButton!
    @IBOutlet var btnUpdateAbout: UIButton!
    @IBOutlet var btnUpdateAddress: UIButton!
    @IBOutlet var txvAbout: UITextView!
    @IBOutlet var lblAddress: UILabel!
    @IBOutlet var lblWebsite: UILabel!
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblEmail: UILabel!
    @IBOutlet var btnMessage: UIButton!
    
    var companyId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if userType == "User" {
            self.btnUpdateInfo.isHidden = true
            self.btnUpdateAbout.isHidden = true
            self.btnUpdateAddress.isHidden = true
            self.getCompanyInfo()
        } else {
            self.btnUpdateInfo.isHidden = false
            self.btnUpdateAbout.isHidden = false
            self.btnUpdateAddress.isHidden = false
            self.getCompanyInfoByPro()
        }
    }
    
    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    //MARK: Edit Company Info
    @IBAction func btnAddAboutUs(sender: UIButton) {
        let aboutVC = self.storyboard?.instantiateViewController(withIdentifier: "AddAboutCompanyViewController") as! AddAboutCompanyViewController
        aboutVC.companyId = self.companyId
        aboutVC.about = self.txvAbout.text
        self.navigationController?.pushViewController(aboutVC, animated: true)
    }
    
    //MARK: Edit Location & URL
    @IBAction func btnEditWebLocation(sender: UIButton) {
        let webVC = self.storyboard?.instantiateViewController(withIdentifier: "AddWebLocationViewController") as! AddWebLocationViewController
        webVC.companyId = self.companyId
        webVC.addr = self.lblAddress.text!
        webVC.web = self.lblWebsite.text!
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
                    self.lblName.text = cData["username"].stringValue
                    self.lblEmail.text = cData["email"].stringValue
                    self.companyId = cData["company_id"].stringValue
                    let pic = cData["profile_pic"].stringValue
                    if pic == "" {
                        self.imgProfile.image = UIImage.init(named: "ios_icon")
                    } else {
                        self.imgProfile.kf.setImage(with: URL(string: pic))
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
        
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: VIEWCOMPANYAPI as NSString, success: successed, failure: failure)
    }
    
    //MARK: Get Company Info by Pro
    func getCompanyInfoByPro() {
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        let uid = Defaults.value(forKey: "user_id") as? String
        param.setValue(uid, forKey: "user_id")
        let successed = {(responseObject: AnyObject) -> Void in
            self.stopAnimating()
            if responseObject != nil{
                let dataObj : JSON = JSON.init(responseObject)
                if(dataObj["status"].stringValue == "1") {
                    let data = dataObj["data"]
                    self.txvAbout.text = data["company_about"].stringValue
                    self.lblWebsite.text = data["company_website"].stringValue
                    self.lblAddress.text = data["company_address"].stringValue
                    self.lblName.text = data["username"].stringValue
                    self.lblEmail.text = data["email"].stringValue
                    self.companyId = data["company_id"].stringValue
                    let pic = data["profile_pic"].stringValue
                    if pic == "" {
                        self.imgProfile.image = UIImage.init(named: "ios_icon")
                    } else {
                        self.imgProfile.kf.setImage(with: URL(string: pic))
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
        
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: VIEWCOMPANYBYPROAPI as NSString, success: successed, failure: failure)
    }
}
