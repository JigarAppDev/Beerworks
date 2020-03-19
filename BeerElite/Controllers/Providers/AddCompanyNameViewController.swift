//
//  AddCompanyNameViewController.swift
//  BeerElite
//
//  Created by Jigar on 17/03/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SwiftyJSON
import Kingfisher

class AddCompanyNameViewController: UIViewController, NVActivityIndicatorViewable {

    var companyId = ""
    var cname = ""
    @IBOutlet var txtName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.txtName.text = self.cname
    }
    
    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSaveClick(sender: UIButton) {
        if self.txtName.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter Your Company Name")
            return
        }
        self.updateName()
    }
    
    func updateName() {
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        param.setValue(self.companyId, forKey: "company_id")
        param.setValue(self.txtName.text!, forKey: "company_name")
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
        
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: UPDATECOMPANYAPI as NSString, success: successed, failure: failure)
    }

}
