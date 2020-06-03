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
    var is_favorite: Int?

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
        self.is_favorite = jsonDic["is_favorite"].intValue
    }
    
    public func dictionaryRepresentation() -> NSDictionary {

        let dictionary = NSMutableDictionary()

        dictionary.setValue(self.id, forKey: "id")
        dictionary.setValue(self.address, forKey: "address")
        dictionary.setValue(self.occupation, forKey: "occupation")
        dictionary.setValue(self.user_resume, forKey: "user_resume")
        dictionary.setValue(self.user_id, forKey: "user_id")
        dictionary.setValue(self.username, forKey: "username")
        dictionary.setValue(self.profile_pic, forKey: "profile_pic")
        dictionary.setValue(self.job_id, forKey: "job_id")
        dictionary.setValue(self.first_name, forKey: "first_name")
        dictionary.setValue(self.user_image, forKey: "user_image")
        dictionary.setValue(self.last_name, forKey: "last_name")
        dictionary.setValue(self.is_favorite, forKey: "is_favorite")

        return dictionary
    }
}


