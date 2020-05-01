//
//  ProviderHomeViewController.swift
//  BeerElite
//
//  Created by Jigar on 16/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import SideMenu
import NVActivityIndicatorView
import SwiftyJSON

class ProviderHomeViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet var txtJobTitle: UITextField!
    @IBOutlet var txtCompanyName: UITextField!
    @IBOutlet var txtSalary: UITextField!
    @IBOutlet var txvDescription: UITextView!
    var isFrom = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if SocketHelper.CheckSocketIsConnectOrNot() == false {
            //Connect to socket
            SocketHelper.connectSocket()
        }
        
        if self.isFrom == "SignUp" {
            //Go to Company Page
            let proStoryBoard = UIStoryboard.init(name: "Provider", bundle: nil)
            let pageVC = proStoryBoard.instantiateViewController(withIdentifier: "CompanyPageViewController") as! CompanyPageViewController
            pageVC.isFrom = "SignUp"
            self.navigationController?.pushViewController(pageVC, animated: true)
        }
    }

    //MARK: Side menu click
    @IBAction func btnSideMenuClick(sender: UIButton) {
        let userStoryBoard = UIStoryboard.init(name: "User", bundle: nil)
        let menu = userStoryBoard.instantiateViewController(withIdentifier: "LeftMenu") as! SideMenuNavigationController
        menu.statusBarEndAlpha = 0
        menu.menuWidth = self.view.frame.width - (self.view.frame.width / 3)
        menu.presentationStyle = .menuSlideIn
        present(menu, animated: true, completion: nil)
    }
    
    //MARK: Post Job Click
    @IBAction func btnPostJobClick(sender: UIButton) {
        if self.validateJob() {
            self.postNewJobClick()
        }
    }
    
    //MARK: - Validate Jobs Input Data
    func validateJob() -> Bool {
        var boolVal : Bool = true
        if txtJobTitle.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter Job Title")
            boolVal = false
        } else if txtCompanyName.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter Business Name")
            boolVal = false
        }else if txtSalary.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter Salary")
            boolVal = false
        }else if txvDescription.text?.trimmingCharacters(in: .whitespaces).isEmpty == true || txvDescription.text == "Enter job activites, responsibilities and requirements" {
            showAlert(title: App_Title, msg: "Please Enter Description")
            boolVal = false
        }
        return boolVal
    }
    
    //MARK: - Post new job
    func postNewJobClick(){
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        param.setValue(self.txtJobTitle.text!, forKey: "job_title")
        param.setValue(self.txtCompanyName.text!, forKey: "company_name")
        param.setValue(self.txtSalary.text!, forKey: "salery")
        param.setValue(self.txvDescription.text!, forKey: "description")
        let uid = Defaults.value(forKey: "user_id") as? String
        param.setValue(uid, forKey: "job_added_by")
        
        let successed = {(responseObject: AnyObject) -> Void in
            self.stopAnimating()
            if responseObject != nil{
                let dataObj : JSON = JSON.init(responseObject)
                if(dataObj["status"].stringValue == "1") {
                    //Make Text Clear
                    self.txtJobTitle.text = ""
                    self.txtSalary.text = ""
                    self.txtCompanyName.text = ""
                    self.txvDescription.text = "Enter job activites, responsibilities and requirements"
                    self.showAlert(title: App_Title, msg: "Job Added Successfully!")
                }else{
                    self.showAlert(title: App_Title, msg: responseObject.value(forKeyPath: "message") as! String)
                }
            }
        }
        let failure = {(error: AnyObject) -> Void in
            self.stopAnimating()
            self.showAlert(title: App_Title, msg: WrongMsg)
        }
        
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: POSTJOBAPI as NSString, success: successed, failure: failure)
    }
    
}
