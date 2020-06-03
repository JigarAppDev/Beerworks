//
//  FavoriteViewController.swift
//  BeerElite
//
//  Created by Jigar on 01/06/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import SideMenu
import NVActivityIndicatorView
import SwiftyJSON

class tblFavCell: UITableViewCell {
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblBarName: UILabel!
    @IBOutlet var lblImage: UIImageView!
}

class FavoriteViewController: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet var tblFav: UITableView!
    var favList = [UserDataModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblFav.estimatedRowHeight = 90
        self.tblFav.rowHeight = UITableView.automaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getMyFavList()
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
    func getMyFavList() {
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        let successed = {(responseObject: AnyObject) -> Void in
            self.stopAnimating()
            if responseObject != nil {
                let dataObj : JSON = JSON.init(responseObject)
                if(dataObj["status"].stringValue == "1") {
                    let dataModel = UserListModels.init(jsonDic: dataObj)
                    self.favList = [UserDataModel]()
                    self.favList = dataModel.listData
                    self.tblFav.reloadData()
                }else{
                    self.showAlert(title: App_Title, msg: responseObject.value(forKeyPath: "message") as! String)
                }
            }
        }
        let failure = {(error: AnyObject) -> Void in
            self.stopAnimating()
            self.showAlert(title: App_Title, msg: WrongMsg)
        }
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: LISTFAVORITEAPI as NSString, success: successed, failure: failure)
    }
    
    //MARK: Remove from Favorite
    func removeFavorite(row: Int) {
        let obj = self.favList[row]
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        param.setValue(obj.user_id, forKey: "favorite_to")
        
        let successed = {(responseObject: AnyObject) -> Void in
            self.stopAnimating()
            if responseObject != nil{
                let dataObj : JSON = JSON.init(responseObject)
                if(dataObj["status"].stringValue == "1") {
                    self.showAlert(title: App_Title, msg: "Removed from Favorite!")
                    self.favList.remove(at: row)
                    self.tblFav.reloadData()
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

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblFav.dequeueReusableCell(withIdentifier: "tblFavCell") as! tblFavCell
        let obj = self.favList[indexPath.row]
        if obj.profile_pic == "" {
            cell.lblImage.image = UIImage.init(named: "ios_icon")
        } else {
            cell.lblImage.kf.setImage(with: URL(string: obj.profile_pic!))
        }
        cell.lblName.text = obj.username
        cell.lblBarName.text = obj.occupation?.capitalized
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userStoryBoard = UIStoryboard.init(name: "User", bundle: nil)
        let resumeVC = userStoryBoard.instantiateViewController(withIdentifier: "ResumeViewController") as! ResumeViewController
        resumeVC.selectedObj = self.favList[indexPath.row]
        self.navigationController?.pushViewController(resumeVC, animated: true)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            self.removeFavorite(row: indexPath.row)
        }
    }
}
