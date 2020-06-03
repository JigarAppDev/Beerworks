//
//  SocketIOManager.swift
//  MatesRates
//
//  Created by Cube Infotech on 24/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import SwiftyJSON
import SocketIO
import Alamofire
import KSToastView

struct SocketHelper {
    
    static let sharedInstance = SocketHelper()
    static let manager = SocketManager.init(socketURL: URL(string: SOCKETURL)!, config: [.log(true), .compress])
    static var socket: SocketIOClient!
    
    static func connectSocket() {
        socket = manager.defaultSocket
        guard socket.status != .connected else { return }
        socket.removeAllHandlers()
        registerHandler()
        socket.connect()
    }
    
    static func registerHandler() {
        
        socket.on(clientEvent: .connect) {data, ack in
            print("Socket Connected")
            self.registerSocket()
        }
        
        socket.on(clientEvent: .disconnect) { (data, ack) in
            self.connectSocket()
            print("Socket Disconnected")
        }
        
        socket.on(clientEvent: .error) { (data, ack) in
            print("Socket error")
            self.connectSocket()
        }
        
        socket.on("event") { (data, ack) in
            print(data.first)
            let responseObj = JSON.init(data.first as Any)
            
            //SOCKET REGISTER
            if responseObj["en"].stringValue == REGISTERSOCKET && responseObj["status_code"].stringValue == "1" {
                self.getUserList()
                //Join Room
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "joinRoomforUser"), object: nil)
            }
             
            //USER LISTS
            if responseObj["en"].stringValue == GETCHATUSERSLIST && responseObj["status_code"].stringValue == "1" {
                let dataObj = responseObj["info"].arrayValue
                print(dataObj)
                allUserChatListGL = dataObj
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateList"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GetUnreadCount"), object: nil)
            }
            
            //JOIN ROOM
            if responseObj["en"].stringValue == JOINROOM && responseObj["status_code"].stringValue == "1" {
                //
                print(responseObj)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getAllMsgs"), object: nil)
                //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "joinRoomResponse"), object: nil, userInfo: responseObj["info"] as [String:Any])
            }
            
            //LEFT ROOM
            if responseObj["en"].stringValue == LEFTROOM && responseObj["status_code"].stringValue == "1" {
                //
            }
            
            //GET ALL CHAT MESSAGES
            if responseObj["en"].stringValue == GETCHATMSG && responseObj["status_code"].stringValue == "1" {
                let dataObj = responseObj["info"].arrayValue
                print(dataObj)
                lastUserChatMsgGL = dataObj
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadAllChats"), object: nil)
            }
            
            //LAST SEND CHAT MESSAGES UPDATES
            //BADGE COUNT New Message
            if responseObj["en"].stringValue == SENDMSGUPDATE && responseObj["status_code"].stringValue == "1" {
                let dataObj = JSON.init(responseObj)
                print(dataObj)
                lastSentMsgGL = dataObj
            }
            
            //SEND MESSAGES UPDATES
            if responseObj["en"].stringValue == SENDMSG && responseObj["status_code"].stringValue == "1" {
                let dataObj = JSON.init(responseObj)
                print(dataObj)
                let isread = dataObj["is_read"].stringValue
                if isread == "1" {
                    if Defaults.value(forKey: "total_message_count") != nil {
                        TOTALMESSAGECOUNT = Defaults.value(forKey: "total_message_count")as! Int
                        TOTALMESSAGECOUNT = TOTALMESSAGECOUNT + 1
                        Defaults.setValue(TOTALMESSAGECOUNT, forKeyPath: "total_message_count")
                    }
                }
                lastSentMsgGL = dataObj
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "appendLastMessage"), object: nil)
            } else if responseObj["en"].stringValue == SENDMSG && responseObj["status_code"].stringValue == "2" {
                //Not Join Room
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "joinRoomforUser"), object: nil)
            }
            
            //CREATE CHAT
            if responseObj["en"].stringValue == CREATECHAT && responseObj["status_code"].stringValue == "1" {
                print(responseObj)
                if ISCHATBOOL == false {
                let dataObj = JSON.init(responseObj)
                let obj = ["chat_id":dataObj["chat_id"].stringValue]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "createChatResponse"), object: nil, userInfo: obj)
                    ISCHATBOOL = true
                }
            }
        }
    }
    
    static func registerSocket() {
        let userid = Defaults.value(forKey: "user_id") as! String
        let token = Defaults.value(forKey: "token") as! String
        
        let param = ["en":REGISTERSOCKET,"user_id":"\(userid)", "user_token":"\(token)"] as [String : Any]
        socket.emit("event", with: [param])
    }
    
    static func getUserList() {
        let userid = Defaults.value(forKey: "user_id") as! String
        let token = Defaults.value(forKey: "token")as! String
        
        let param = ["en":GETCHATUSERSLIST,"user_id":"\(userid)", "user_token":"\(token)"] as [String : Any]
        socket.emit("event", with: [param])
    }
    
    static func emitWithAck(name: String, param: [String : Any], completion: @escaping (Any) -> ()) {
        if SocketHelper.CheckSocketIsConnectOrNot(){ //socket.status == .connected
            socket.emitWithAck(name, with: [param]).timingOut(after: 3) { (data) in
                print(data)
                guard let dataF = (data).first else { return }
                let strResponse = dataF as! String
                completion(strResponse)
            }
        }
    }
    
    static func disconnectSocket() {
        socket.disconnect()
        socket.removeAllHandlers()
    }
    
    static func connectToServerWithNickname(nickname: String, completionHandler: @escaping (_ userList: [[String: AnyObject]]?) -> Void) {
        
        socket.emit("connectUser", nickname)
        
        socket.on("get_list_chat_user") { ( dataArray, ack) -> Void in
            completionHandler(dataArray[0] as? [[String: AnyObject]])
        }
        listenForOtherMessages()
    }
    
    static func CheckSocketIsConnectOrNot() -> Bool{
        if(SocketHelper.socket == nil){
            return false
        }else if SocketHelper.socket.status != .connected{
            return false
        }else{
            return true
        }
    }
    
    static func listenForOtherMessages() {
        socket.on("userConnectUpdate") { (dataArray, socketAck) -> Void in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userWasConnectedNotification"), object: dataArray[0] as! [String: AnyObject])
        }
        
        socket.on("userExitUpdate") { (dataArray, socketAck) -> Void in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userWasDisconnectedNotification"), object: dataArray[0] as! String)
        }
        
        socket.on("userTypingUpdate") { (dataArray, socketAck) -> Void in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userTypingNotification"), object: dataArray[0] as? [String: AnyObject])
        }
    }
    
    static func exitChatWithNickname(nickname: String, completionHandler: () -> Void) {
        socket.emit("exitUser", nickname)
        completionHandler()
    }
    
    static func sendMessage(message: String, withNickname nickname: String) {
        socket.emit("chatMessage", nickname, message)
    }
    
    static func getChatMessage(completionHandler: @escaping (_ messageInfo: [String: AnyObject]) -> Void) {
        socket.on("newChatMessage") { (dataArray, socketAck) -> Void in
            var messageDictionary = [String: AnyObject]()
            messageDictionary["nickname"] = dataArray[0] as! String as AnyObject
            messageDictionary["message"] = dataArray[1] as! String as AnyObject
            messageDictionary["date"] = dataArray[2] as! String as AnyObject
            
            completionHandler(messageDictionary)
        }
    }
    
    static func sendStartTypingMessage(nickname: String) {
        socket.emit("startType", nickname)
    }
    
    static func sendStopTypingMessage(nickname: String) {
        socket.emit("stopType", nickname)
    }
}
