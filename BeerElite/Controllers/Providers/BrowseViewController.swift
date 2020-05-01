//
//  BrowseViewController.swift
//  BeerElite
//
//  Created by Jigar on 18/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import SideMenu
import NVActivityIndicatorView
import SwiftyJSON
import Kingfisher

class tblBrowseCell: UITableViewCell {
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblDescr: UILabel!
}

class BrowseViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet var tblBrowse: UITableView!
    var userList = [UserDataModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tblBrowse.estimatedRowHeight = 100
        self.tblBrowse.rowHeight = UITableView.automaticDimension
        
        self.getJobsList()
    }

    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Get Jobs List
    func getJobsList() {
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        let successed = {(responseObject: AnyObject) -> Void in
            self.stopAnimating()
            if responseObject != nil {
                let dataObj : JSON = JSON.init(responseObject)
                if(dataObj["status"].stringValue == "1") {
                    let dataModel = UserListModels.init(jsonDic: dataObj)
                    self.userList = [UserDataModel]()
                    self.userList = dataModel.listData
                    self.tblBrowse.reloadData()
                }else{
                    if dataObj["message"].stringValue == "No Jobs Found" {
                        self.showAlert(title: App_Title, msg: "No Applicants Yet!")
                    } else {
                        self.showAlert(title: App_Title, msg: dataObj["message"].stringValue)
                    }
                }
            }
        }
        let failure = {(error: AnyObject) -> Void in
            self.stopAnimating()
            self.showAlert(title: App_Title, msg: WrongMsg)
        }
        
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: LISTAPPLIEDUSERSAPI as NSString, success: successed, failure: failure)
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
    
    //MARK: Filter Click
    @IBAction func btnFilterClick(sender: UIButton) {
        let userStoryBoard = UIStoryboard.init(name: "User", bundle: nil)
        let menu = userStoryBoard.instantiateViewController(withIdentifier: "FilterVC") as! SideMenuNavigationController
        menu.statusBarEndAlpha = 0
        menu.menuWidth = self.view.frame.width - (self.view.frame.width / 3)
        menu.presentationStyle = .menuSlideIn
        present(menu, animated: true, completion: nil)
    }
}

extension BrowseViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblBrowse.dequeueReusableCell(withIdentifier: "tblBrowseCell") as! tblBrowseCell
        let obj = self.userList[indexPath.row]
        if obj.profile_pic == "" {
            cell.imgProfile.image = UIImage.init(named: "ios_icon")
        } else {
            cell.imgProfile.kf.setImage(with: URL(string: obj.profile_pic!))
        }
        cell.lblName.text = obj.first_name! + " " + obj.last_name!
        cell.lblDescr.text = obj.occupation?.capitalized
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userStoryBoard = UIStoryboard.init(name: "User", bundle: nil)
        let resumeVC = userStoryBoard.instantiateViewController(withIdentifier: "ResumeViewController") as! ResumeViewController
        resumeVC.selectedObj = self.userList[indexPath.row]
        self.navigationController?.pushViewController(resumeVC, animated: true)
    }
}
