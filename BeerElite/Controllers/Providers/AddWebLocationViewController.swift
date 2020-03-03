//
//  AddWebLocationViewController.swift
//  BeerElite
//
//  Created by Jigar on 20/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SwiftyJSON
import Kingfisher

class AddWebLocationViewController: UIViewController, NVActivityIndicatorViewable {

    var companyId = ""
    var web = ""
    var addr = ""
    @IBOutlet var txtWeb: UITextField!
    @IBOutlet var txtAddr: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.txtWeb.text = self.web
        self.txtAddr.text = self.addr
    }
    
    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSaveClick(sender: UIButton) {
        if self.txtWeb.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter Website")
            return
        } else if self.txtAddr.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter Address")
            return
        }
        self.updateAbout()
    }
    
    func updateAbout() {
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        param.setValue(self.companyId, forKey: "company_id")
        param.setValue(self.txtAddr.text!, forKey: "company_address")
        param.setValue(self.txtWeb.text!, forKey: "company_website")
        let successed = {(responseObject: AnyObject) -> Void in
            self.stopAnimating()
            if responseObject != nil {
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
        
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: UPDATECOMPANYAPI as NSString, success: successed, failure: failure)
    }

}
