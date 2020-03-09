//
//  SuperChatViewController.swift
//  BeerElite
//
//  Created by Jigar on 06/03/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import SwiftyJSON
import KSToastView

class SuperChatViewController: UIViewController {
    
    @IBOutlet var chatView: UIView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet weak var barImageView: UIImageView!
    @IBOutlet weak var lastSeenLBL: UILabel!
    @IBOutlet weak var onlineView: UIView!
    
    var userObj: JSON!
    var isFrom = ""
    var cid = ""
    var imcomingAvtar = ""
    var msgBy = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userid = Defaults.value(forKey: "user_id") as! String
        isFrom = "\(userid)"
        if cid == "" {
            if let cliendID: String = userObj["chat_id"].stringValue {
                cid = cliendID
            }
        }
        self.lblName.text = userObj["username"].stringValue
        if userObj["profile_pic"].stringValue != "" {
            //barImageView.kf.setImage(with: URL(string: userObj["profile_pic"].stringValue))
        }
        let lastSeen = userObj["last_seen"].stringValue
        let dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale // save locale temporarily
        // dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if lastSeen != "" {
            let date = dateFormatter.date(from: lastSeen)!
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
            dateFormatter.locale = tempLocale // reset the locale
            let lastSeenString = Date().timeAgo(from: date)
            print(lastSeenString)
            //lastSeenLBL.text = "last seen \(lastSeenString)"
        }
        
        //Add ChatView
        //onlineView.layer.cornerRadius = onlineView.frame.height / 2
        if userObj["socket_id"] != "" {
            //onlineView.backgroundColor = .green
            //lastSeenLBL.isHidden = true
        }else {
            //onlineView.backgroundColor = .lightGray
            //lastSeenLBL.isHidden = false
        }
        
        let chatVC = self.storyboard!.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatVC.isFrom = self.isFrom
        chatVC.userObj = self.userObj
        chatVC.cid = self.cid
        chatVC.msgBy = self.msgBy
        if userObj["profile_pic"].stringValue != "" {
            chatVC.incomingAvtar = userObj["profile_pic"].stringValue
        }
        chatVC.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 50)
        chatVC.willMove(toParent: self)
        self.chatView.addSubview(chatVC.view)
        self.addChild(chatVC)
        chatVC.didMove(toParent: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if SocketHelper.CheckSocketIsConnectOrNot() == false {
            //Connect to socket
            SocketHelper.connectSocket()
        }
        cid = self.userObj["chat_id"].stringValue
        self.joinChatRoom(cid: cid)
    }
    
    func joinChatRoom(cid: String) {
        let cid = self.userObj["chat_id"].stringValue
        let userid = Defaults.value(forKey: "user_id") as! String
        let token = Defaults.value(forKey: "token")as! String
        let param = ["en":JOINROOM,"user_id":"\(userid)", "user_token":"\(token)", "chat_id":cid] as [String : Any]
        SocketHelper.socket.emit("event", with: [param])
    }
    
    //MARK: Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.leftChatRoom()
        self.navigationController?.popViewController(animated: true)
    }
    
    //Left Chat Room
    func leftChatRoom() {
        let userid = Defaults.value(forKey: "user_id") as! String
        let token = Defaults.value(forKey: "token")as! String
        let param = ["en":LEFTROOM,"user_id":userid, "user_token":"\(token)"] as [String : Any]
        SocketHelper.socket.emit("event", with: [param])
    }
}

extension Date {
    // Returns the number of years
    func yearsCount(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    // Returns the number of months
    func monthsCount(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    // Returns the number of weeks
    func weeksCount(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    // Returns the number of days
    func daysCount(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    // Returns the number of hours
    func hoursCount(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    // Returns the number of minutes
    func minutesCount(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    // Returns the number of seconds
    func secondsCount(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    // Returns time ago by checking if the time differences between two dates are in year or months or weeks or days or hours or minutes or seconds
    func timeAgo(from date: Date) -> String {
        if yearsCount(from: date)   > 0 { return "\(yearsCount(from: date)) years ago"   }
        if monthsCount(from: date)  > 0 { return "\(monthsCount(from: date)) months ago"  }
        if weeksCount(from: date)   > 0 { return "\(weeksCount(from: date)) weeks ago"   }
        if daysCount(from: date)    > 0 { return "\(daysCount(from: date)) days ago"    }
        if hoursCount(from: date)   > 0 { return "\(hoursCount(from: date)) hours ago"   }
        if minutesCount(from: date) > 0 { return "\(minutesCount(from: date)) minutes ago" }
        if secondsCount(from: date) > 0 { return "\(secondsCount(from: date)) seconds ago" }
        return ""
    }
}

