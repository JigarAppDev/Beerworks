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
let App_Title: String = "Beer Elite"

var LoaderType:Int = 14
let Defaults = UserDefaults.standard
let Loadersize = CGSize(width: 40, height: 40)
var ToastDuration:TimeInterval = 2.0
var InternetMessage:String = "No internet connection, please try again later"
var WrongMsg:String = "Something went wrong, please try again"

//MARK: Api list
let LOGINAPI                       = "login"
let SIGNAPI                        = "register"
let LOGINBYSOCIAL                  = "login_by_thirdparty"
let RESETPASSWORD                  = "reset_password"
let FORGOTPASSWORD                 = "forgotPassword"
let LOGOUT                         = "logout"

//MARK: Global Variables
var userType = ""
var userData: JSON = []
var deviceTokenClientGL = ""
var APIdeviceTokenGL = ""

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
