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
    @IBOutlet var imgFavIcon: UIImageView!
    @IBOutlet var btnFav: UIButton!
}

class BrowseViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet var tblBrowse: UITableView!
    var userList = [UserDataModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tblBrowse.estimatedRowHeight = 100
        self.tblBrowse.rowHeight = UITableView.automaticDimension
        NotificationCenter.default.addObserver(self, selector: #selector(self.getUsersByFilter), name: NSNotification.Name(rawValue: "getUsersByFilter"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if IsUserFilter {
            self.getUsersByFilter()
        } else {
            self.getJobsList()
        }
    }

    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Get Jobs List
    func getJobsList() {
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        param.setValue("0", forKey: "distance")
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
    
    //MARK: Filter User List
    @objc func getUsersByFilter() {
        IsUserFilter = false
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        param.setValue(filterDistance, forKey: "distance")
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
        IsJobFilter = false
        present(menu, animated: true, completion: nil)
    }
    
    //MARK: Filter Click
    @IBAction func btnFilterClick(sender: UIButton) {
        let userStoryBoard = UIStoryboard.init(name: "User", bundle: nil)
        let menu = userStoryBoard.instantiateViewController(withIdentifier: "FilterVC") as! SideMenuNavigationController
        menu.statusBarEndAlpha = 0
        menu.menuWidth = self.view.frame.width - (self.view.frame.width / 3)
        menu.presentationStyle = .menuSlideIn
        menu.enableSwipeToDismissGesture = false
        present(menu, animated: true, completion: nil)
    }
    
    //MARK: Add to Fav Lis
    @objc func addToFavorite(sender: UIButton) {
        let obj = self.userList[sender.tag]
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        param.setValue(obj.user_id, forKey: "favorite_to")
        
        let successed = {(responseObject: AnyObject) -> Void in
            self.stopAnimating()
            if responseObject != nil{
                let dataObj : JSON = JSON.init(responseObject)
                if(dataObj["status"].stringValue == "1") {
                    if obj.is_favorite == 0 {
                        //add
                        obj.is_favorite = 1
                        self.showAlert(title: App_Title, msg: "Added to Favorite!")
                    } else {
                        //remove
                        obj.is_favorite = 0
                        self.showAlert(title: App_Title, msg: "Removed from Favorite!")
                    }
                    self.userList.remove(at: sender.tag)
                    self.userList.insert(obj, at: sender.tag)
                    self.tblBrowse.reloadData()
                }else{
                    self.showAlert(title: App_Title, msg: responseObject.value(forKeyPath: "message") as! String)
                }
            }
        }
        let failure = {(error: AnyObject) -> Void in
            self.stopAnimating()
            self.showAlert(title: App_Title, msg: WrongMsg)
        }
        
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: ADDTOFAVORITEAPI as NSString, success: successed, failure: failure)
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
        if obj.is_favorite == 1 {
            cell.imgFavIcon.image = UIImage.init(named: "ic_selectedFav")
        } else {
            cell.imgFavIcon.image = UIImage.init(named: "ic_fav")
        }
        cell.lblName.text = obj.first_name! + " " + obj.last_name!
        cell.lblDescr.text = obj.occupation?.capitalized
        cell.btnFav.tag = indexPath.row
        cell.btnFav.addTarget(self, action: #selector(self.addToFavorite(sender:)), for: .touchUpInside)
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
