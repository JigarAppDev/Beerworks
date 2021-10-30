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

    @IBOutlet var btnLocalJobs: UIButton!
    @IBOutlet var btnLocalJobsHeight: NSLayoutConstraint!
    @IBOutlet var btnMenu1: UIButton!
    @IBOutlet var btnMenu2: UIButton!
    @IBOutlet var btnMenu3: UIButton!
    @IBOutlet var btnMenu4: UIButton!
    @IBOutlet var btnMenu5: UIButton!
    @IBOutlet var btnMenu6: UIButton!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblEmail: UILabel!
    @IBOutlet var btnCity: UIButton!
    @IBOutlet var imgProfile: UIImageView!
    
    var msgCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.getUnreadMessageCount), name: NSNotification.Name(rawValue: "GetUnreadCount"), object: nil)
        
        self.btnCity.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setupUI()
        
        if SocketHelper.CheckSocketIsConnectOrNot() {
            SocketHelper.getUserList()
        } else {
            SocketHelper.connectSocket()
        }
    }
    
    @objc func getUnreadMessageCount() {
        self.msgCount = 0
        for data in allUserChatListGL {
            var unreadCount = data["unread_count"].intValue
            //Check for msg count visibility
            let userid = Defaults.value(forKey: "user_id") as! String
            if let msgBy: String = data["message_by"].stringValue {
                if userid == msgBy {
                    unreadCount = 0
                } else {
                    //Add it
                    self.msgCount = self.msgCount + unreadCount
                }
            }
        }
        
        if self.msgCount > 0 {
            self.btnMenu3.setTitle("Messages (\(self.msgCount))", for: .normal)
        }
    }

    func setupUI() {
        let name = Defaults.value(forKey: "user_name") as! String
        let email = Defaults.value(forKey: "user_email") as! String
        var city = Defaults.value(forKey: "user_city") as! String
        if city == "" {
            city = "City"
        }
        if let picUrl: String = Defaults.value(forKey: "profile_pic") as? String, picUrl != "" {
            self.imgProfile.kf.setImage(with: URL(string: picUrl))
        } else {
            //self.imgProfile.image = UIImage.init(named: "ios_icon")
        }
        self.lblName.text = name
        self.lblEmail.text = email
        self.btnCity.setTitle(city, for: .normal)
        
        self.btnLocalJobs.isHidden = true
        self.btnLocalJobsHeight.constant = 0
        self.btnMenu1.isHidden = false
        self.btnMenu2.isHidden = false
        self.btnMenu3.isHidden = false
        //self.btnMenu4.isHidden = false
        self.btnMenu5.isHidden = false
        self.btnMenu6.isHidden = false
        
        if userType == "User" {
            self.btnMenu5.isHidden = true
            self.btnMenu6.isHidden = true
            self.btnMenu1.setTitle("Job List", for: .normal)
            self.btnMenu2.setTitle("Application", for: .normal)
            self.btnMenu3.setTitle("Messages", for: .normal)
            self.btnMenu4.setTitle("Saved Jobs", for: .normal)
        } else {
            self.btnLocalJobs.isHidden = false
            self.btnLocalJobsHeight.constant = 30
            self.btnMenu1.setTitle("Post a Job", for: .normal)
            self.btnMenu2.setTitle("Candidates", for: .normal)
            self.btnMenu3.setTitle("Messages", for: .normal)
            self.btnMenu4.setTitle("My Postings", for: .normal)
            self.btnMenu5.setTitle("Company Profile", for: .normal)
        }
    }
    
    //MARK: gotoProfile
    @IBAction func btnOpenProfile(sender: UIButton) {
        if userType == "User" {
            let userStoryBoard = UIStoryboard.init(name: "User", bundle: nil)
            let proVC = userStoryBoard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            self.navigationController?.pushViewController(proVC, animated: true)
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
                let alert = UIAlertController.init(title: App_Title, message: "Are you sure you want to logout?", preferredStyle: .alert)
                let yesAction = UIAlertAction.init(title: "Yes", style: .default) { (action) in
                    self.LogoutAPI()
                    //self.clearAllUserDefault()
                    //let loginVC = mainStoryBoard.instantiateViewController(withIdentifier: "UserSelectionViewController") as! UserSelectionViewController
                    //self.navigationController?.pushViewController(loginVC, animated: true)
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
                //Saved Jobs
                let jobsVC = userStoryBoard.instantiateViewController(withIdentifier: "SavedListViewController") as! SavedListViewController
                self.navigationController?.pushViewController(jobsVC, animated: true)
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
                let alert = UIAlertController.init(title: App_Title, message: "Are you sure you want to logout?", preferredStyle: .alert)
                let yesAction = UIAlertAction.init(title: "Yes", style: .default) { (action) in
                    self.LogoutAPI()
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
            } else if sender.tag == 108 {
                //Favorites
                let favVC = proStoryBoard.instantiateViewController(withIdentifier: "FavoriteViewController") as! FavoriteViewController
                self.navigationController?.pushViewController(favVC, animated: true)
            } else if sender.tag == 201 {
                //JobList
                let homeVC = userStoryBoard.instantiateViewController(withIdentifier: "UserHomeViewController") as! UserHomeViewController
                homeVC.isFrom = "EMP"
                self.navigationController?.pushViewController(homeVC, animated: true)
            }
        }
    }
    
    //MARK:- Logout API
    func LogoutAPI(){
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        //let identifier = UUID()
        //param.setValue(identifier.uuidString, forKey: "device_id")
        if let did: String = Defaults.value(forKey: "deviceId") as? String {
            param.setValue(did, forKey: "device_id")
        }
        let successed = {(responseObject: AnyObject) -> Void in
        self.stopAnimating()
            if responseObject != nil{
                       let dataObj : JSON = JSON.init(responseObject)
                       if(dataObj["status"].stringValue == "1") {
                            self.clearAllUserDefault()
                            let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
                            let loginVC = mainStoryBoard.instantiateViewController(withIdentifier: "UserSelectionViewController") as! UserSelectionViewController
                            self.navigationController?.pushViewController(loginVC, animated: true)
                       }else{
                           self.showAlert(title: App_Title, msg: responseObject.value(forKeyPath: "success") as! String)
                       }
                   }
        }
        let failure = {(error: AnyObject) -> Void in
            self.stopAnimating()
            self.showAlert(title: App_Title, msg: WrongMsg)
        }
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: LOGOUT as NSString, success: successed, failure: failure)
    }
    
    func clearAllUserDefault() {
        Defaults.removeObject(forKey: "user_type")
        Defaults.removeObject(forKey: "user_id")
        Defaults.removeObject(forKey: "user_email")
        Defaults.removeObject(forKey: "user_name")
        Defaults.removeObject(forKey: "is_logged_in")
        Defaults.removeObject(forKey: "user_city")
        Defaults.removeObject(forKey: "deviceId")
        Defaults.removeObject(forKey: "profile_pic")
        if allUserChatListGL != nil {
            allUserChatListGL.removeAll()
        }
        if lastUserChatMsgGL != nil {
            lastUserChatMsgGL.removeAll()
        }
        IsJobFilter = false
        filterDistance = "0"
        Defaults.synchronize()
    }
}
