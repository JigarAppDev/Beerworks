//
//  NotificationsViewController.swift
//  BeerElite
//
//  Created by Jigar on 18/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import SideMenu
import NVActivityIndicatorView
import SwiftyJSON

class tblNotificationCell: UITableViewCell {
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblCompanyName: UILabel!
    @IBOutlet var lblSalary: UILabel!
    @IBOutlet var lblDescr: UILabel!
    @IBOutlet var lblTime: UILabel!
    @IBOutlet var lblExpireAt: UILabel!
}

class NotificationsViewController: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet var tblNotification: UITableView!
    var jobList = [JobsDataModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblNotification.estimatedRowHeight = 90
        self.tblNotification.rowHeight = UITableView.automaticDimension
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getMyPostList()
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
    
    //MARK: Get All My Post List
    func getMyPostList() {
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
                    self.tblNotification.reloadData()
                }else{
                    self.showAlert(title: App_Title, msg: responseObject.value(forKeyPath: "message") as! String)
                }
            }
        }
        let failure = {(error: AnyObject) -> Void in
            self.stopAnimating()
            self.showAlert(title: App_Title, msg: WrongMsg)
        }
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: LISTMYPOSTSAPI as NSString, success: successed, failure: failure)
    }
    
    func deleteJobById(jobId: String, index: IndexPath) {
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        param.setValue(jobId, forKey: "job_id")
        
        let successed = {(responseObject: AnyObject) -> Void in
            self.stopAnimating()
            if responseObject != nil{
                let dataObj : JSON = JSON.init(responseObject)
                if(dataObj["status"].stringValue == "1") {
                    self.jobList.remove(at: index.row)
                    self.tblNotification.deleteRows(at: [index], with: .fade)
                }else{
                    self.showAlert(title: App_Title, msg: responseObject.value(forKeyPath: "message") as! String)
                }
            }
        }
        let failure = {(error: AnyObject) -> Void in
            self.stopAnimating()
            self.showAlert(title: App_Title, msg: WrongMsg)
        }
        
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: DELETEJOBAPI as NSString, success: successed, failure: failure)
    }
}

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.jobList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblNotification.dequeueReusableCell(withIdentifier: "tblNotificationCell") as! tblNotificationCell
        let obj = self.jobList[indexPath.row]
        cell.lblTitle.text = obj.jobTitle
        cell.lblCompanyName.text = obj.company_name
        cell.lblSalary.text = "Salary/hourly wage: " + obj.salary!
        cell.lblDescr.text = obj.description
        
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
            cell.lblTime.text = "\(lastSeenString)"
        }
        
        cell.lblExpireAt.text = ""
        let expDate = obj.exp_date
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if expDate != "" {
            let exp = dateFormatter.date(from: expDate!)!
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
            dateFormatter.locale = tempLocale
            let expString = Date().expInDays(from: exp)
            print(expString)
            cell.lblExpireAt.text = "\(expString)"
        }
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            //let obj = self.jobList[indexPath.row]
            //self.deleteJobById(jobId: obj.jobId!, index: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (rowAction, indexPath) in
            //To edit the row at indexPath here
            print("Edit")
            let postVC = self.storyboard?.instantiateViewController(withIdentifier: "ProviderHomeViewController") as! ProviderHomeViewController
            postVC.isFrom = "Update"
            postVC.jobObj = self.jobList[indexPath.row]
            self.navigationController?.pushViewController(postVC, animated: true)
        }
        editAction.backgroundColor = .blue

        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
            //To Delete the row at indexPath here
            print("Delete")
            let obj = self.jobList[indexPath.row]
            self.deleteJobById(jobId: obj.jobId!, index: indexPath)
        }
        deleteAction.backgroundColor = .red

        return [deleteAction, editAction]
    }
}
