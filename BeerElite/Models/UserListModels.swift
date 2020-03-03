//
//  UserListModels.swift
//  BeerElite
//
//  Created by Jigar on 03/03/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import Foundation
import SwiftyJSON

class UserListModels {
    var msg: String?
    var status: String?
    var listData = [UserDataModel]()
    
    init(jsonDic: JSON) {
        self.msg = jsonDic["message"].stringValue
        self.status = jsonDic["status"].stringValue
        let data = jsonDic["data"].arrayValue
        if data.count >  0 {
            for obj in data {
                self.listData.append(UserDataModel.init(jsonDic: JSON(obj)))
            }
        }
    }
}

class UserDataModel {
    var id: String?
    var address: String?
    var occupation: String?
    var user_resume: String?
    var user_id: String?
    var username: String?
    var profile_pic: String?
    var job_id: String?
    var first_name: String?
    var user_image: String?
    var last_name: String?

    init(jsonDic: JSON) {
        self.id = jsonDic["id"].stringValue
        self.address = jsonDic["address"].stringValue
        self.occupation = jsonDic["occupation"].stringValue
        self.user_resume = jsonDic["user_resume"].stringValue
        self.user_id = jsonDic["user_id"].stringValue
        self.username = jsonDic["username"].stringValue
        self.profile_pic = jsonDic["profile_pic"].stringValue
        self.job_id = jsonDic["job_id"].stringValue
        self.first_name = jsonDic["first_name"].stringValue
        self.user_image = jsonDic["user_image"].stringValue
        self.last_name = jsonDic["last_name"].stringValue
    }
}


