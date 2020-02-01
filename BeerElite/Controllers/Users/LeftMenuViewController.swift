//
//  LeftMenuViewController.swift
//  BeerElite
//
//  Created by Jigar on 16/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import SideMenu
import NVActivityIndicatorView
import SwiftyJSON

class LeftMenuViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet var btnMenu1: UIButton!
    @IBOutlet var btnMenu2: UIButton!
    @IBOutlet var btnMenu3: UIButton!
    @IBOutlet var btnMenu4: UIButton!
    @IBOutlet var btnMenu5: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupUI()
    }

    func setupUI() {
        self.btnMenu1.isHidden = false
        self.btnMenu2.isHidden = false
        self.btnMenu3.isHidden = false
        self.btnMenu4.isHidden = false
        self.btnMenu5.isHidden = false
        if userType == "User" {
            self.btnMenu4.isHidden = true
            self.btnMenu5.isHidden = true
            self.btnMenu1.setTitle("Job List", for: .normal)
            self.btnMenu2.setTitle("My Resume", for: .normal)
            self.btnMenu3.setTitle("Messages", for: .normal)
        } else {
            self.btnMenu1.setTitle("Add Job", for: .normal)
            self.btnMenu2.setTitle("Browse", for: .normal)
            self.btnMenu3.setTitle("Messages", for: .normal)
            self.btnMenu4.setTitle("Notifications", for: .normal)
            self.btnMenu5.setTitle("Company Page", for: .normal)
        }
    }
    
    //MARK: Left Menu Click Events
    @IBAction func btnAllActions(sender: UIButton) {
        let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let proStoryBoard = UIStoryboard.init(name: "Provider", bundle: nil)
        let userStoryBoard = UIStoryboard.init(name: "User", bundle: nil)
        if userType == "User" {
            if sender.tag == 101 {
                //JobList
                let homeVC = userStoryBoard.instantiateViewController(withIdentifier: "UserHomeViewController") as! UserHomeViewController
                self.navigationController?.pushViewController(homeVC, animated: true)
            } else if sender.tag == 102 {
                //My Resume
                let resumeVC = userStoryBoard.instantiateViewController(withIdentifier: "ResumeViewController") as! ResumeViewController
                self.navigationController?.pushViewController(resumeVC, animated: true)
            } else if sender.tag == 103 {
                //Messages
                let msgVC = proStoryBoard.instantiateViewController(withIdentifier: "MessagesViewController") as! MessagesViewController
                self.navigationController?.pushViewController(msgVC, animated: true)
            } else if sender.tag == 104 {
                //Logout
                let alert = UIAlertController.init(title: App_Title, message: "Are you sure to make logout?", preferredStyle: .alert)
                let yesAction = UIAlertAction.init(title: "Yes", style: .default) { (action) in
                    self.clearAllUserDefault()
                    let loginVC = mainStoryBoard.instantiateViewController(withIdentifier: "UserSelectionViewController") as! UserSelectionViewController
                    self.navigationController?.pushViewController(loginVC, animated: true)
                }
                let noAction = UIAlertAction.init(title: "No", style: .cancel, handler: nil)
                alert.addAction(yesAction)
                alert.addAction(noAction)
                self.present(alert, animated: true, completion: nil)
            } else if sender.tag == 105 {
                //Support
                let supportVC = proStoryBoard.instantiateViewController(withIdentifier: "SupportViewController") as! SupportViewController
                self.navigationController?.pushViewController(supportVC, animated: true)
                
            }
        } else {
            //Provider
            if sender.tag == 101 {
                //AddJob
                let homeVC = proStoryBoard.instantiateViewController(withIdentifier: "ProviderHomeViewController") as! ProviderHomeViewController
                self.navigationController?.pushViewController(homeVC, animated: true)
            } else if sender.tag == 102 {
                //Browse
                let browseVC = proStoryBoard.instantiateViewController(withIdentifier: "BrowseViewController") as! BrowseViewController
                self.navigationController?.pushViewController(browseVC, animated: true)
            } else if sender.tag == 103 {
                //Messages
                let msgVC = proStoryBoard.instantiateViewController(withIdentifier: "MessagesViewController") as! MessagesViewController
                self.navigationController?.pushViewController(msgVC, animated: true)
            } else if sender.tag == 104 {
                //Logout
                let alert = UIAlertController.init(title: App_Title, message: "Are you sure to make logout?", preferredStyle: .alert)
                let yesAction = UIAlertAction.init(title: "Yes", style: .default) { (action) in
                    self.clearAllUserDefault()
                    let loginVC = mainStoryBoard.instantiateViewController(withIdentifier: "UserSelectionViewController") as! UserSelectionViewController
                    self.navigationController?.pushViewController(loginVC, animated: true)
                }
                let noAction = UIAlertAction.init(title: "No", style: .cancel, handler: nil)
                alert.addAction(yesAction)
                alert.addAction(noAction)
                self.present(alert, animated: true, completion: nil)
            } else if sender.tag == 105 {
                //Support
                let supportVC = proStoryBoard.instantiateViewController(withIdentifier: "SupportViewController") as! SupportViewController
                self.navigationController?.pushViewController(supportVC, animated: true)
            } else if sender.tag == 106 {
                //Notification
                let notiVC = proStoryBoard.instantiateViewController(withIdentifier: "NotificationsViewController") as! NotificationsViewController
                self.navigationController?.pushViewController(notiVC, animated: true)
            } else if sender.tag == 107 {
                //Company Page
                let pageVC = proStoryBoard.instantiateViewController(withIdentifier: "CompanyPageViewController") as! CompanyPageViewController
                self.navigationController?.pushViewController(pageVC, animated: true)
            }
        }
    }
    
    //MARK:- Logout API
    /*func LogoutAPI(){
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        let identifier = UUID()
        let token = Defaults.value(forKey: "token")as! String
        param.setValue(identifier.uuidString, forKey: "device_id")
        headers = ["Authorization": "Bearer \(token)"]
        let successed = {(responseObject: AnyObject) -> Void in
        self.stopAnimating()
            if responseObject != nil{
                       let dataObj : JSON = JSON.init(responseObject)
                       if(dataObj["status"].stringValue == "1") {
                            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                            let navigationController = UINavigationController(rootViewController: nextViewController)
                            navigationController.navigationBar.isHidden = true
                        self.view.window!.rootViewController = navigationController
                       }else{
                           self.showAlert(title: App_Title, msg: responseObject.value(forKeyPath: "success") as! String)
                       }
                   }
        }
        let failure = {(error: AnyObject) -> Void in
            self.stopAnimating()
            self.showAlert(title: App_Title, msg: WrongMsg)
        }
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], header: headers as [String : AnyObject], action: LOGOUT as NSString, success: successed, failure: failure)
    }*/
    
    func clearAllUserDefault() {
        Defaults.removeObject(forKey: "user_type")
        Defaults.removeObject(forKey: "user_id")
        Defaults.removeObject(forKey: "user_email")
        Defaults.removeObject(forKey: "user_name")
        Defaults.removeObject(forKey: "is_logged_in")
        Defaults.synchronize()
    }
}
