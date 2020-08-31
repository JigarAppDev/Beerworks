//
//  JobsModel.swift
//  BeerElite
//
//  Created by Jigar on 05/02/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import Foundation
import SwiftyJSON

class JobsModel {
    var msg: String?
    var status: String?
    var listData = [JobsDataModel]()
    
    init(jsonDic: JSON) {
        self.msg = jsonDic["message"].stringValue
        self.status = jsonDic["status"].stringValue
        let data = jsonDic["data"].arrayValue
        if data.count >  0 {
            for obj in data {
                self.listData.append(JobsDataModel.init(jsonDic: JSON(obj)))
            }
        }
    }
}

class JobsDataModel {
    var id: String?
    var jobId: String?
    var jobTitle: String?
    var company_name: String?
    var salary: String?
    var email: String?
    var login_type: String?
    var username: String?
    var job_added_by: String?
    var description: String?
    var user_type: String?
    var profile_pic: String?
    var company_id: String?
    var applied_by_me: String?
    var created_at: String?
    var isSaved: Int?
    var exp_date: String?

    init(jsonDic: JSON) {
        self.id = jsonDic["id"].stringValue
        self.jobId = jsonDic["job_id"].stringValue
        self.jobTitle = jsonDic["job_title"].stringValue
        self.company_name = jsonDic["company_name"].stringValue
        self.salary = jsonDic["salery"].stringValue
        self.email = jsonDic["email"].stringValue
        self.login_type = jsonDic["login_type"].stringValue
        self.username = jsonDic["username"].stringValue
        self.job_added_by = jsonDic["job_added_by"].stringValue
        self.description = jsonDic["description"].stringValue
        self.user_type = jsonDic["user_type"].stringValue
        self.profile_pic = jsonDic["profile_pic"].stringValue
        self.company_id = jsonDic["company_id"].stringValue
        self.applied_by_me = jsonDic["applied_by_me"].stringValue
        self.created_at = jsonDic["created_at"].stringValue
        self.isSaved = jsonDic["is_saved"].intValue
        self.exp_date = jsonDic["expire_at"].stringValue
    }
    
    public func dictionaryRepresentation() -> NSDictionary {

        let dictionary = NSMutableDictionary()

        dictionary.setValue(self.id, forKey: "id")
        dictionary.setValue(self.jobId, forKey: "job_id")
        dictionary.setValue(self.jobTitle, forKey: "job_title")
        dictionary.setValue(self.company_name, forKey: "company_name")
        dictionary.setValue(self.salary, forKey: "salery")
        dictionary.setValue(self.email, forKey: "email")
        dictionary.setValue(self.login_type, forKey: "login_type")
        dictionary.setValue(self.username, forKey: "username")
        dictionary.setValue(self.job_added_by, forKey: "job_added_by")
        dictionary.setValue(self.description, forKey: "description")
        dictionary.setValue(self.user_type, forKey: "user_type")
        dictionary.setValue(self.profile_pic, forKey: "profile_pic")
        dictionary.setValue(self.company_id, forKey: "company_id")
        dictionary.setValue(self.applied_by_me, forKey: "applied_by_me")
        dictionary.setValue(self.created_at, forKey: "created_at")
        dictionary.setValue(self.exp_date, forKey: "expire_at")
        return dictionary
    }
}
