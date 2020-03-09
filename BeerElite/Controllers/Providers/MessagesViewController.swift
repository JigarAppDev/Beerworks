//
//  MessagesViewController.swift
//  BeerElite
//
//  Created by Jigar on 18/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import SideMenu
import SwiftyJSON
import Kingfisher

class tblMessageCell: UITableViewCell {
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblDescr: UILabel!
    @IBOutlet var lblTimeAgo: UILabel!
    @IBOutlet var onlineView: UIView!
    @IBOutlet var lblUnreadCount: UILabel!
}

class MessagesViewController: UIViewController {
    
    @IBOutlet var tblMessage: UITableView!
    var allUserData = [JSON]()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblMessage.estimatedRowHeight = 90
        self.tblMessage.rowHeight = UITableView.automaticDimension
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateList(noti:)), name:
            NSNotification.Name(rawValue: "updateList"), object: nil)
        
        //Pull to refresh
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...")
        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
        self.tblMessage.addSubview(refreshControl)
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
    
    @objc func refresh(sender:AnyObject) {
        if SocketHelper.CheckSocketIsConnectOrNot() == false {
            //Connect to socket
            SocketHelper.connectSocket()
        }
        self.loadAllChatList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if SocketHelper.CheckSocketIsConnectOrNot() == false {
            //Connect to socket
            SocketHelper.connectSocket()
        }
        self.loadAllChatList()
    }
    
    //MARK: Load all chat list
    func loadAllChatList() {
        /*let userid = Defaults.value(forKey: "user_id") as! String
        let token = Defaults.value(forKey: "token")as! String
        let param = ["en":GETCHATUSERSLIST,"user_id":"\(userid)", "user_token":"\(token)"] as [String : Any]
        if SocketHelper.socket != nil {
            SocketHelper.socket.emit("event", with: [param])
            if allUserChatListGL != nil {
                allUserData = allUserChatListGL
            }
        }*/
        if allUserChatListGL != nil {
            allUserData = allUserChatListGL
        }
        self.refreshControl.endRefreshing()
        self.tblMessage.reloadData()
    }
    
    @objc func updateList(noti: NSNotification) {
        if allUserChatListGL != nil {
            allUserData = allUserChatListGL
        }
        self.tblMessage.reloadData()
    }
}

extension MessagesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allUserData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblMessage.dequeueReusableCell(withIdentifier: "tblMessageCell") as! tblMessageCell
        cell.lblUnreadCount.isHidden = true
        cell.lblUnreadCount.layer.masksToBounds = true
        cell.lblUnreadCount.layer.cornerRadius = cell.lblUnreadCount.frame.height / 2
        let data = allUserChatListGL[indexPath.row]
        let userName = data["username"].stringValue
        let profilePic = data["profile_pic"].stringValue
        let lastMessage = data["message"].stringValue
        let unreadCount = data["unread_count"].intValue
        if unreadCount != 0 {
            cell.lblUnreadCount.text = "\(unreadCount)"
            cell.lblUnreadCount.isHidden = false
        }
        
        //Check for msg count visibility
        let userid = Defaults.value(forKey: "user_id") as! String
        if let msgBy: String = data["message_by"].stringValue {
            if userid == msgBy {
                cell.lblUnreadCount.isHidden = true
            } else {
                if unreadCount != 0 {
                    cell.lblUnreadCount.isHidden = false
                }
            }
        }
        
        cell.lblName.text = userName
        cell.lblDescr.text = lastMessage
        if data["socket_id"].stringValue != "" {
            cell.onlineView.backgroundColor = .green
        }
        
        if profilePic != "" {
            cell.imgProfile.kf.setImage(with: URL(string: profilePic))
        }
        
        let msgTime = data["created_date"].stringValue
        let dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale // save locale temporarily
        // dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if msgTime != "" {
            let date = dateFormatter.date(from: msgTime)!
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
            dateFormatter.locale = tempLocale // reset the locale
            let lastSeenString = Date().timeAgo(from: date)
            print(lastSeenString)
            cell.lblTimeAgo.text = "\(lastSeenString)"
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let proStoryBoard = UIStoryboard.init(name: "Provider", bundle: nil)
        let chatVC = proStoryBoard.instantiateViewController(withIdentifier: "SuperChatViewController") as! SuperChatViewController
        let data = allUserData[indexPath.row]
        chatVC.userObj = data
        if let msgBy: String = data["message_by"].stringValue {
            chatVC.msgBy = msgBy
        }
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
}
