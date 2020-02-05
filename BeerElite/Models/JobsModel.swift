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
    }
}


