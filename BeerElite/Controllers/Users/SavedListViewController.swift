//
//  SavedListViewController.swift
//  BeerElite
//
//  Created by Jigar on 16/06/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import SideMenu
import NVActivityIndicatorView
import SwiftyJSON
import Kingfisher

class SavedListViewController: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet var tblJobsList: UITableView!
    var jobList = [JobsDataModel]()
    var selectedJob: JobsDataModel!
    var selUser: JSON = JSON()
    var isNav = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tblJobsList.estimatedRowHeight = 150
        self.tblJobsList.rowHeight = UITableView.automaticDimension
        
        self.getAllJobsList()
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.createChatResponse(noti:)), name:
            NSNotification.Name(rawValue: "createChatResponse"), object: nil)
    }
    
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Get All Jobs List
    func getAllJobsList() {
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        let successed = {(responseObject: AnyObject) -> Void in
            self.stopAnimating()
            if responseObject != nil {
                let dataObj : JSON = JSON.init(responseObject)
                if(dataObj["status"].stringValue == "1") {
                    let dataModel = JobsModel.init(jsonDic: dataObj)
                    self.jobList = [JobsDataModel]()
                    self.jobList = dataModel.listData
                    self.tblJobsList.reloadData()
                }else{
                    self.showAlert(title: App_Title, msg: responseObject.value(forKeyPath: "message") as! String)
                }
            }
        }
        let failure = {(error: AnyObject) -> Void in
            self.stopAnimating()
            self.showAlert(title: App_Title, msg: WrongMsg)
        }
        
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: GETSAVEDJOBAPI as NSString, success: successed, failure: failure)
    }
    
    //MARK:- Chat
    @objc func btnCreateChat(sender:UIButton) {
        ISCHATBOOL = false
        let userid = Defaults.value(forKey: "user_id") as! String
        let token = Defaults.value(forKey: "token")as! String
        selectedJob = jobList[sender.tag]
        selectedJobGL = jobList[sender.tag]
        let cData = jobList[sender.tag]
        self.selUser = JSON.init(cData)
        print(cData)
        var providertID = ""
        providertID = cData.id!
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
        var isSB = false
        if let dic: NSDictionary = noti.userInfo as NSDictionary? {
            ISCHATBOOL = false
            let json = JSON.init(dic)
            let cid = json["chat_id"].stringValue
            chatId = cid
            if isSB == false {
                isSB = true
                let sb = UIStoryboard.init(name: "Provider", bundle: nil)
                let contactVC = sb.instantiateViewController(withIdentifier: "SuperChatViewController") as! SuperChatViewController
                contactVC.userObj = JSON.init(selectedJobGL.dictionaryRepresentation())
                contactVC.cid = chatId
                if isNav == false {
                    isNav = true
                    self.navigationController?.pushViewController(contactVC, animated: true)
                }
            }
        }
    }
    
    //MARK: Remove from Saved List
    func removeJobs(row: Int) {
        let obj = self.jobList[row]
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        param.setValue(obj.jobId, forKey: "saved_job_id")
        
        let successed = {(responseObject: AnyObject) -> Void in
            self.stopAnimating()
            if responseObject != nil{
                let dataObj : JSON = JSON.init(responseObject)
                if(dataObj["status"].stringValue == "1") {
                    self.showAlert(title: App_Title, msg: "Removed from Saved Jobs!")
                    self.jobList.remove(at: row)
                    self.tblJobsList.reloadData()
                }else{
                    self.showAlert(title: App_Title, msg: responseObject.value(forKeyPath: "message") as! String)
                }
            }
        }
        let failure = {(error: AnyObject) -> Void in
            self.stopAnimating()
            self.showAlert(title: App_Title, msg: WrongMsg)
        }
        
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: REMOVESAVEDJOBAPI as NSString, success: successed, failure: failure)
    }
}

extension SavedListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.jobList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblJobsList.dequeueReusableCell(withIdentifier: "tblJobsListCell") as! tblJobsListCell
        let obj = self.jobList[indexPath.row]
        if obj.profile_pic == "" {
            cell.imgProfile.image = UIImage.init(named: "ios_icon")
        } else {
            cell.imgProfile.kf.setImage(with: URL(string: obj.profile_pic!))
        }
        cell.lblTitle.text = obj.jobTitle
        cell.lblDescr.text = obj.description
        cell.lblSubTitle.text = obj.company_name
        cell.lblWages.text = "Salary/hourly wage: " + obj.salary!
        cell.btnChat.tag = indexPath.row
        cell.btnChat.addTarget(self, action: #selector(self.btnCreateChat(sender:)), for: .touchUpInside)
        
        let msgTime = obj.created_at
        let dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale // save locale temporarily
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if msgTime != "" {
            let date = dateFormatter.date(from: msgTime!)!
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
            dateFormatter.locale = tempLocale // reset the locale
            let lastSeenString = Date().timeAgo(from: date)
            print(lastSeenString)
            cell.lblDate.text = "\(lastSeenString)"
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsVC = self.storyboard?.instantiateViewController(withIdentifier: "JobDetailsViewController") as! JobDetailsViewController
        detailsVC.dataObj = self.jobList[indexPath.row]
        self.navigationController?.pushViewController(detailsVC, animated: true)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            self.removeJobs(row: indexPath.row)
        }
    }
}
