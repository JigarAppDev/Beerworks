//
//  UserHomeViewController.swift
//  BeerElite
//
//  Created by Jigar on 16/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import SideMenu
import NVActivityIndicatorView
import SwiftyJSON
import Kingfisher

class tblJobsListCell: UITableViewCell {
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblSubTitle: UILabel!
    @IBOutlet var lblDescr: UILabel!
    @IBOutlet var lblWages: UILabel!
    @IBOutlet var btnChat: UIButton!
}

class UserHomeViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet var tblJobsList: UITableView!
    var jobList = [JobsDataModel]()
    var selectedJob: JobsDataModel!
    var allUserData = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tblJobsList.estimatedRowHeight = 150
        self.tblJobsList.rowHeight = UITableView.automaticDimension
        NotificationCenter.default.addObserver(self, selector: #selector(self.getJobsByFilter), name: NSNotification.Name(rawValue: "GetJobsByFilter"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.createChatResponse(noti:)), name:
        NSNotification.Name(rawValue: "createChatResponse"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if allUserChatListGL != nil {
            allUserData = allUserChatListGL
        }
        if IsJobFilter {
            self.getJobsByFilter()
        } else {
            self.getAllJobsList()
        }
        
        if SocketHelper.CheckSocketIsConnectOrNot() == false {
            //Connect to socket
            SocketHelper.connectSocket()
        }
    }
    
    //MARK: Side menu click
    @IBAction func btnSideMenuClick(sender: UIButton) {
        let menu = storyboard!.instantiateViewController(withIdentifier: "LeftMenu") as! SideMenuNavigationController
        menu.statusBarEndAlpha = 0
        menu.menuWidth = self.view.frame.width - (self.view.frame.width / 3)
        menu.presentationStyle = .menuSlideIn
        present(menu, animated: true, completion: nil)
    }
    
    //MARK: Filter Click
    @IBAction func btnFilterClick(sender: UIButton) {
        let menu = storyboard!.instantiateViewController(withIdentifier: "FilterVC") as! SideMenuNavigationController
        menu.statusBarEndAlpha = 0
        menu.menuWidth = self.view.frame.width - (self.view.frame.width / 3)
        menu.presentationStyle = .menuSlideIn
        menu.enableSwipeToDismissGesture = false
        IsJobFilter = true
        present(menu, animated: true, completion: nil)
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
        
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: GETJOBLIST as NSString, success: successed, failure: failure)
    }
    
    //MARK: Get All Jobs By Filter
    @objc func getJobsByFilter() {
        IsJobFilter = false
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        param.setValue(filterDistance, forKey: "distance")
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
        
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: GETJOBSBYFILTERAPI as NSString, success: successed, failure: failure)
    }
    
    //MARK:- Chat
    @objc func btnCreateChat(sender:UIButton) {
        let userid = Defaults.value(forKey: "user_id") as! String
        let token = Defaults.value(forKey: "token")as! String
        selectedJob = jobList[sender.tag]
        let cData = jobList[sender.tag]
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
        if let dic: NSDictionary = noti.userInfo as NSDictionary? {
            let json = JSON.init(dic)
            let cid = json["chat_id"].stringValue
            chatId = cid
            let sb = UIStoryboard.init(name: "Provider", bundle: nil)
            let contactVC = sb.instantiateViewController(withIdentifier: "SuperChatViewController") as! SuperChatViewController
            contactVC.cid = chatId
            self.navigationController?.pushViewController(contactVC, animated: true)
        }
    }
}

extension UserHomeViewController: UITableViewDelegate, UITableViewDataSource {
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
        cell.btnChat.addTarget(self, action: #selector(self.btnCreateChat(sender:)), for: .touchUpInside)
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
}
