//
//  JobDetailsViewController.swift
//  BeerElite
//
//  Created by Jigar on 21/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView

class JobDetailsViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet var imgBar: UIImageView!
    @IBOutlet var lblBarName: UILabel!
    @IBOutlet var lblSubName: UILabel!
    @IBOutlet var lblSalary: UILabel!
    @IBOutlet var lblDescr: UILabel!
    @IBOutlet var btnChat: UIButton!
    @IBOutlet var btnQuickApply: UIButton!
    
    var dataObj: JobsDataModel!
    var allUserData = [JSON]()
    var selUser: JSON = JSON()
    var isFrom = ""
    var clickDelegate: ClickDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupData()
        if allUserChatListGL != nil {
            allUserData = allUserChatListGL
        }
        
        NotificationCenter.default.removeObserver(self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.createChatResponse(noti:)), name:NSNotification.Name(rawValue: "createChatResponse"), object: nil)
        
        if SocketHelper.CheckSocketIsConnectOrNot() == false {
            //Connect to socket
            SocketHelper.connectSocket()
        }
        
        if self.isFrom == "EMP" {
            self.btnChat.isHidden = true
            self.btnQuickApply.isHidden = true
        }
    }
    
    func setupData() {
        if self.dataObj.profile_pic == "" {
            self.imgBar.image = UIImage.init(named: "ios_icon")
        } else {
            self.imgBar.kf.setImage(with: URL(string: self.dataObj.profile_pic!))
        }
        self.lblBarName.text = self.dataObj.jobTitle
        self.lblDescr.text = self.dataObj.description
        self.lblSubName.text = self.dataObj.company_name
        self.lblSalary.text = "Salary/hourly wage " + self.dataObj.salary!
    }

    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Apply Click
    @IBAction func btnApplyClick(sender: UIButton) {
        //self.clickDelegate.btnClickNow()
        
        if dataObj.applied_by_me == "1" {
            self.showAlert(title: App_Title, msg: "You have applied for this job already.")
            return
        }
        
        //let applyVC = self.storyboard?.instantiateViewController(withIdentifier: "ApplyViewController") as! ApplyViewController
        //applyVC.dataObj = self.dataObj
        //self.navigationController?.pushViewController(applyVC, animated: true)
        
        self.applyForJob()
    }
    
    //MARK: API Calling
    func applyForJob() {
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        param.setValue(self.dataObj.jobId, forKey: "job_id")
        
        let successed = {(responseObject: AnyObject) -> Void in
            self.stopAnimating()
            if responseObject != nil{
                let dataObj : JSON = JSON.init(responseObject)
                if(dataObj["status"].stringValue == "1") {
                    //self.showAlert(title: App_Title, msg: dataObj["message"].stringValue)
                    self.dataObj.applied_by_me = "1"
                    self.showAlert(title: App_Title, msg: "Done and Done! Now's the time to polish your application and increase your chances of landing that interview!")
                }else{
                    self.showAlert(title: App_Title, msg: responseObject.value(forKeyPath: "message") as! String)
                }
            }
        }
        let failure = {(error: AnyObject) -> Void in
            self.stopAnimating()
            self.showAlert(title: App_Title, msg: WrongMsg)
        }
        
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: APPLYFORJOBAPI as NSString, success: successed, failure: failure)
    }
    
    //MARK: View Company Click
    @IBAction func btnViewCompanyClick(sender: UIButton) {
        let proStoryBoard = UIStoryboard.init(name: "Provider", bundle: nil)
        let compVC = proStoryBoard.instantiateViewController(withIdentifier: "CompanyPageViewController") as! CompanyPageViewController
        compVC.companyId = self.dataObj.company_id!
        compVC.isFrom = self.isFrom
        self.navigationController?.pushViewController(compVC, animated: true)
    }
    
    //MARK:- Chat
    @IBAction func btnCreateChat(sender: UIButton) {
        ISCHATBOOL = false
        let userid = Defaults.value(forKey: "user_id") as! String
        let token = Defaults.value(forKey: "token")as! String
        let cData = dataObj
        selectedJobGL = dataObj
        self.selUser = JSON.init(cData)
        print(cData)
        var providertID = ""
        providertID = cData!.id!
        //print(allUserData.count)
        var obj = allUserChatListGL.filter { (json) -> Bool in
            return json["other_user_id"].stringValue == providertID
        }
        if obj.count == 0 {
            obj = allUserChatListGL.filter { (json) -> Bool in
                return json["chat_created_to"].stringValue == providertID
            }
        }
        if obj.count > 0 {
            let sb = UIStoryboard.init(name: "Provider", bundle: nil)
            let nextVC = sb.instantiateViewController(withIdentifier: "SuperChatViewController")as! SuperChatViewController
            nextVC.userObj = obj[0] //cData
            self.navigationController?.pushViewController(nextVC, animated: true)
        } else {
            if SocketHelper.CheckSocketIsConnectOrNot() {
                //CreateChat Room
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let dt = dateFormatter.string(from: Date())
                let param = ["en":CREATECHAT,"user_id":"\(userid)", "user_token":"\(token)",
                    "other_user_id":"\(providertID)","chat_created_time":dt] as [String : Any]
                SocketHelper.socket.emit("event", with: [param])
            } else {
                SocketHelper.connectSocket()
            }
        }
    }
    
    @objc func createChatResponse(noti: NSNotification) {
        print(noti)
        //Chat Created
        if let dic: NSDictionary = noti.userInfo as NSDictionary? {
            ISCHATBOOL = false
            let json = JSON.init(dic)
            let cid = json["chat_id"].stringValue
            chatId = cid
            let sb = UIStoryboard.init(name: "Provider", bundle: nil)
            let contactVC = sb.instantiateViewController(withIdentifier: "SuperChatViewController") as! SuperChatViewController
            contactVC.userObj = JSON.init(selectedJobGL.dictionaryRepresentation()) //self.selUser
            contactVC.cid = chatId
            self.navigationController?.pushViewController(contactVC, animated: true)
            
        }
    }
}
