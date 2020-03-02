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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tblJobsList.estimatedRowHeight = 150
        self.tblJobsList.rowHeight = UITableView.automaticDimension
        
        self.getAllJobsList()
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
