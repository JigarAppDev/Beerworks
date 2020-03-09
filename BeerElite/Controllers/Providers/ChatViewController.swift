//
//  ChatViewController.swift
//  BeerElite
//
//  Created by Jigar on 20/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import SwiftyJSON

class ChatViewController: JSQMessagesViewController {
    
    var name = ""
    var messages = [JSQMessage]()
    var userObj: JSON!
    var isFrom = ""
    var uid = ""
    var cid = ""
    var isToday = true
    var isYesterday = true
    var dateArray = NSMutableArray()
    var lastDate = Date()
    var incomingAvtar = ""
    var msgBy = "0"
    
    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory.init(bubble: .jsq_bubbleRegularTailless(), capInsets: UIEdgeInsets.zero)?.outgoingMessagesBubbleImage(with: UIColor.init(red: 223/255, green: 167/255, blue: 72/255, alpha: 1.0))
        }()!
    
    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory.init(bubble: .jsq_bubbleRegularTailless(), capInsets: UIEdgeInsets.zero)?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        }()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.name
        self.view.backgroundColor = .clear
        
        let userid = Defaults.value(forKey: "user_id") as! String
        self.senderId = "\(userid)"
        self.senderDisplayName = userObj["username"].stringValue
        
        collectionView.backgroundColor = UIColor.clear
        //collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        //collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        //Left button - Attchment
        inputToolbar.contentView.leftBarButtonItem.isHidden = true
        inputToolbar.contentView.backgroundColor = .white
        inputToolbar.contentView.leftBarButtonItemWidth = 0
        //inputToolbar.contentView.leftBarButtonItem.setImage(UIImage(named: "ic_add"), for: .normal)
        
        //Remove profile image
        //collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        //Textview for text
        inputToolbar.contentView.backgroundColor = UIColor.lightGray
        inputToolbar.contentView.textView.backgroundColor = UIColor.init(red: 247/255, green: 247/255, blue: 248/255, alpha: 1.0)
        inputToolbar.contentView.textView.layer.cornerRadius = inputToolbar.contentView.textView.frame.height / 2
        inputToolbar.contentView.textView.layer.borderWidth = 0
        inputToolbar.contentView.textView.font = UIFont.systemFont(ofSize: 15)
        inputToolbar.contentView.textView.placeHolder = "Write your message"
        
        //Right button - Send
        inputToolbar.contentView.rightBarButtonItemWidth = 35
        //inputToolbar.contentView.rightBarButtonItem.setTitle("Send", for: .normal)
        inputToolbar.contentView.rightBarButtonItem.setImage(UIImage.init(named: "send"), for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadAllChats), name: NSNotification.Name(rawValue: "loadAllChats"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appendLastMessage), name: NSNotification.Name(rawValue: "appendLastMessage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.joinRoomforUser), name: NSNotification.Name(rawValue: "joinRoomforUser"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.getAllMsgs), name: NSNotification.Name(rawValue: "getAllMsgs"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Load chats
        //joinRoomforUser()
        //self.getAllMessages(page: "1")
    }
    
    @objc func joinRoomforUser() {
        cid = self.userObj["chat_id"].stringValue
        self.joinChatRoom(cid: cid)
    }
    
    @objc func getAllMsgs() {
        self.getAllMessages(page: "1")
    }
    
    func joinChatRoom(cid: String) {
        let cid = self.userObj["chat_id"].stringValue
        let userid = Defaults.value(forKey: "user_id") as! String
        let token = Defaults.value(forKey: "token")as! String
        let param = ["en":JOINROOM,"user_id":"\(userid)", "user_token":"\(token)", "chat_id":cid] as [String : Any]
        SocketHelper.socket.emit("event", with: [param])
    }
    
    //Get Chat Messages
    func getAllMessages(page: String) {
        cid = self.userObj["chat_id"].stringValue
        let userid = Defaults.value(forKey: "user_id") as! String
        let token = Defaults.value(forKey: "token") as! String
        var cnt = "1"
        if userid == msgBy {
            cnt = "0"
        }
        let param = ["en":GETCHATMSG,"user_id":"\(userid)", "user_token":"\(token)", "chat_id":cid,"page_no":page,"reset_count":cnt] as [String : Any]
        SocketHelper.socket.emit("event", with: [param])
    }
    
    @objc func loadAllChats() {
        self.loadAllChatList()
    }
    
    //Send Messages
    func sendMessages(msg: String) {
        
        var oid = ""
        if oid == "" {
            oid = self.userObj["other_user_id"].stringValue
            //oid = self.userObj["message_by"].stringValue
        }
        if oid == "" {
            oid = self.userObj["user_id"].stringValue
        }
        let userid = Defaults.value(forKey: "user_id") as! String
        if oid == "\(userid)" {
            oid = self.userObj["chat_created_to"].stringValue
        }
        let token = Defaults.value(forKey: "token")as! String
        cid = self.userObj["chat_id"].stringValue
        let param = ["en":SENDMSG,"user_id":"\(userid)", "user_token":"\(token)", "chat_id":cid,"other_id":oid,"msg":msg,"msg_type":1] as [String : Any]
        print(param)// 1 = text, 2 = image
        SocketHelper.socket.emit("event", with: [param])
    }
    
    //Show Full Chat
    func loadAllChatList() {
        self.dateArray.removeAllObjects()
        self.messages.removeAll()
        self.isToday = true
        for obj in lastUserChatMsgGL.reversed() {
            let sid = obj["message_by"].stringValue
            let sname = obj["first_name"].stringValue
            let msg = obj["message"].stringValue
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let dt = inputFormatter.date(from: obj["created_date"].stringValue)
            let chatMsg = JSQMessage.init(senderId: sid, senderDisplayName: sname, date: dt, text: msg)
            self.setupDatesOfMsgs(dt: dt!)
            self.messages.append(chatMsg!)
        }
        self.finishReceivingMessage()
    }
    
    //Append Last Msg in Chat
    @objc func appendLastMessage() {
        
        let userid = Defaults.value(forKey: "user_id") as! String
        cid = self.userObj["chat_id"].stringValue
        var sid = ""
        if lastSentMsgGL["user_id"].stringValue == self.senderId {
            sid = self.senderId
        } else {
            sid = lastSentMsgGL["other_id"].stringValue
        }
        let sname = senderDisplayName
        let messagType = lastSentMsgGL["msg_type"].stringValue
        var chatMsg : JSQMessage?
        var msg = lastSentMsgGL["msg"].stringValue
        if msg == "" {
            msg = lastSentMsgGL["msg2"].stringValue
        }
        //        if messagType == "0" { //Receiver
        //            chatMsg = JSQMessage.init(senderId: "\(sid)", senderDisplayName: sname, date: Date(), text: msg)
        //        }else { //Sender
        chatMsg = JSQMessage.init(senderId: "\(sid)", senderDisplayName: sname, date: Date(), text: msg)
        //}
        if self.isToday {
            self.isToday = false
            self.dateArray.add("Today")
        } else {
            self.dateArray.add("")
        }
        self.messages.append(chatMsg!)
        self.finishReceivingMessage()
    }
    
    //Manage Date Titles
    func setupDatesOfMsgs(dt: Date) {
        //Date Array
        let calendar = Calendar.current
        
        //Top Label
        let formatter = DateFormatter()
        
        if calendar.isDateInToday(dt) {
            if self.isToday {
                self.isToday = false
                self.dateArray.add("Today")
            } else {
                self.dateArray.add("")
            }
        } else if calendar.isDateInYesterday(dt) {
            if self.isYesterday {
                self.isYesterday = false
                self.dateArray.add("Yesterday")
            } else {
                self.dateArray.add("")
            }
        } else if calendar.isDate(Date(), equalTo: dt, toGranularity: .weekOfMonth) {
            formatter.dateFormat = "EEEE hh:mm a"
            let strDate = formatter.string(from: dt)
            if self.dateArray.count > 0 {
                if self.dateArray.contains(strDate) {
                    self.dateArray.add("")
                } else {
                    
                    formatter.dateFormat = "EEEE"
                    let newStrDate = formatter.string(from: dt)
                    let preStrDate = formatter.string(from: self.lastDate)
                    if preStrDate == newStrDate {
                        self.dateArray.add("")
                    } else {
                        self.dateArray.add(strDate)
                    }
                }
            } else {
                self.dateArray.add(strDate)
            }
        } else {
            formatter.dateFormat = "dd MMM yyyy hh:mm a"
            let strDate = formatter.string(from: dt)
            if self.dateArray.count > 0 {
                if self.dateArray.contains(strDate) {
                    self.dateArray.add("")
                } else {
                    formatter.dateFormat = "dd MMM yyyy"
                    let newStrDate = formatter.string(from: dt)
                    let preStrDate = formatter.string(from: self.lastDate)
                    if preStrDate == newStrDate {
                        self.dateArray.add("")
                    } else {
                        self.dateArray.add(strDate)
                    }
                }
            } else {
                self.dateArray.add(strDate)
            }
        }
        self.lastDate = dt
    }
    
    //JSQ COLLECTION DELEGATE METHODS
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData!
    {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource!
    {
        return messages[indexPath.item].senderId == senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, at indexPath: IndexPath!) {
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource!
    {
        return nil
    }
    
    //Cell Bottom label - Seen-Unseen
    /*override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
     
     //Bottom Label
     let dt = self.messages[indexPath.item].date
     let formatter = DateFormatter()
     formatter.dateFormat = "hh:mm a"
     let strDate = formatter.string(from: dt!)
     if messages[indexPath.item].senderId == senderId {            //Right side space
     //return NSAttributedString(string: "\(strDate)\t")
     
     //Text with image
     let fullString = NSMutableAttributedString(string: "\(strDate)")
     let image1Attachment = NSTextAttachment()
     let img = UIImageView.init()
     if self.allMsgSeenArray.count > 0 {
     if self.allMsgSeenArray[indexPath.item] as! Bool == true {
     img.image = UIImage(named: "ic_seenTick")
     } else {
     img.image = UIImage(named: "ic_unseenTick")
     }
     } else {
     img.image = UIImage(named: "ic_unseenTick")
     }
     img.contentMode = .scaleAspectFit
     image1Attachment.image = img.image
     image1Attachment.bounds = CGRect.init(x: 5, y: -3, width: 15, height: 15)
     let image1String = NSAttributedString(attachment: image1Attachment)
     fullString.append(image1String)
     fullString.append(NSAttributedString(string: "\t"))
     return fullString
     }
     //Left side space
     return NSAttributedString(string: "   \(strDate)")
     }*/
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return messages[indexPath.item].senderId == senderId ? 15 : 15
    }
    
    //Cell Top label - Date
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        return NSAttributedString(string: self.dateArray[indexPath.item] as! String)
    }
    
    //Date label height
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        let dateStr = self.dateArray[indexPath.item] as! String
        if dateStr == "" {
            return 0
        }
        return 15
    }
    
    //TOP Bubble Message Label
    /*override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!
     {
     
     }
     
     override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
     {
     return messages[indexPath.item].senderId == senderId ? 15 : 15
     }*/
    
    //Tap on message
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        // messages to show
        let msg = messages[indexPath.row]
        
        if !msg.isMediaMessage {
            if msg.senderId! == senderId {
                cell.textView.textColor = UIColor.white
            }else{
                cell.textView.textColor = UIColor.black
                if incomingAvtar != "" {
                    cell.avatarImageView.layer.masksToBounds = true
                    cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.height / 2
                    cell.avatarImageView.kf.setImage(with: URL(string: "\(incomingAvtar)"))
                }
            }
            cell.textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: cell.textView.textColor ?? UIColor.white]
            //cell.textView.font = UIFont(name: "SFProText-Regular", size: 15)
        }
        
        cell.cellTopLabel.textAlignment = .center
        
        return cell
    }
    
    //Send message
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!)
    {
        self.sendMessages(msg: text)
        self.finishSendingMessage()
    }
}

extension JSQMessagesInputToolbar {
    override open func didMoveToWindow() {
        super.didMoveToWindow()
        guard let window = window else { return }
        if #available(iOS 11.0, *) {
            let anchor = window.safeAreaLayoutGuide.bottomAnchor
            bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: anchor, multiplier: 1.0).isActive = true
        }
    }
}

