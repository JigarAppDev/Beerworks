//
//  GlobalConstant.swift
//  BeerElite
//
//  Created by Jigar on 12/06/18.
//  Copyright © 2018 Jigar. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

var BASEURL: String = "http://159.89.236.101/beer_elite/api/"
var SOCKETURL: String = "http://159.89.236.101:8001/"
let App_Title: String = "Beer Elite"

var LoaderType:Int = 14
let Defaults = UserDefaults.standard
let Loadersize = CGSize(width: 40, height: 40)
var ToastDuration:TimeInterval = 2.0
var InternetMessage:String = "No internet connection, please try again later"
var WrongMsg:String = "Something went wrong, please try again"

//MARK: API list
let LOGINAPI                       = "login"
let SIGNAPI                        = "register"
let LOGINBYSOCIAL                  = "login_by_thirdparty"
let RESETPASSWORD                  = "reset_password"
let FORGOTPASSWORD                 = "forgotPassword"
let LOGOUT                         = "logout"

//Provider
let POSTJOBAPI                     = "add_job"
let ADDCOMPANYPAGEAPI              = "add_company_page"
let GETUSERPROFILEAPI              = "get_users_profile"
let LISTAPPLIEDUSERSAPI            = "list_applied_users_list"
let VIEWCOMPANYBYPROAPI            = "view_company_by_provider"
let UPDATECOMPANYAPI               = "update_company_page"
let UPDATEPROFILEAPI               = "update_profile"
let LISTMYPOSTSAPI                 = "list_jobs_company"
let DELETEJOBAPI                   = "delete_job"

//Users
let GETJOBLIST                     = "list_jobs"
let GETJOBLISTBYJOBIDAPI           = "get_jobs_list"
let VIEWCOMPANYAPI                 = "view_company"
let APPLYFORJOBAPI                 = "apply_job_user"
let GETJOBSBYFILTERAPI             = "get_jobs_list_by_filter"
let ADDBEERBIOAPI                  = "add_beer_bio"
let ADDINTERESTAPI                 = "add_interest"
let ADDEXPERIENCEAPI               = "add_experiance"
let ADDCERTILEVELAPI               = "add_certification_level"
let GETJOBDETIALSAPI               = "get_jobs_detail"
let ADDEDUCATIONAPI                = "add_education"
let GETMYPROFILEAPI                = "get_my_profile"
let APPLYFORJOBBYUSERAPI           = "apply_job_user"
let ADDSUPPORTAPI                  = "add_support_mail"
let EDITEDUCATIONAPI               = "edit_education"
let EDITEXPERIENCEAPI              = "edit_experiance"

//MARK: Global Variables
var userType = ""
var userData: JSON = []
var deviceTokenClientGL = ""
var APIdeviceTokenGL = ""
var IsJobFilter = false
var filterDistance = "50"

//MARK:- CHAT
var deviceTokenGL = ""
var fcmTokenGL = ""
var apiTokenGL = ""
var TOTALMESSAGECOUNT = 0
var allUserChatListGL = [JSON]()
var lastUserChatMsgGL: [JSON]!
var lastSentMsgGL: JSON!

//SOCKET API
let REGISTERSOCKET                 = "socket_register"
let GETCHATUSERSLIST               = "get_list_chat_user"
let JOINROOM                       = "join_room"
let CREATECHAT                     = "create_chat"
let GETCHATMSG                     = "get_chat_messages"
let SENDMSG                        = "send_msg"
let LEFTROOM                       = "room_user_left"
let SENDMSGUPDATE                  = "real_chat_update"

var chatId = ""
var DEVICETOKEN = ""

//MARK:- Notification Type
var NOTIFICATION_TYPE = "0"

//MARK:- BADGES COUNT
var badgeCount = 0

//MARK: Web Service Hendler
let service: ServiceCall = ServiceCall()

//MARK: storyBoard Id
let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

//MARK: Color
let BACKGROUND_COLOR                =   UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
let CELL_BORDER_COLOR               =   UIColor(red:0.39, green:0.44, blue:0.69, alpha:0.14)
let CELL_Top_Border                 =   UIColor(red: 239/255, green: 71/255, blue: 159/255, alpha: 1.0)
let CELL_Middle_Border              =   UIColor(red: 31/255, green: 194/255, blue: 235/255, alpha: 1.0)
let CELL_Bottom_Border              =   UIColor(red: 93/255, green: 55/255, blue: 255/255, alpha: 1.0)
