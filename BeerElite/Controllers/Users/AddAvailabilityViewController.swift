//
//  AddAvailabilityViewController.swift
//  BeerElite
//
//  Created by Jigar on 13/02/21.
//  Copyright © 2021 Jigar. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SwiftyJSON
import Kingfisher

class AddAvailabilityViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet var txtHours: UITextField!
    @IBOutlet var transportSwitch: UISwitch!
    @IBOutlet var mornigStack: UIStackView!
    @IBOutlet var noonStack: UIStackView!
    @IBOutlet var eveningStack: UIStackView!
    
    var isTransport = false
    var workingHour = ""
    var availArray = [JSON]()
    var monArr = [Bool]()
    var noonArr = [Bool]()
    var eveArr = [Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.txtHours.text = self.workingHour
        if self.isTransport {
            self.transportSwitch.setOn(true, animated: true)
        } else {
            self.transportSwitch.setOn(false, animated: true)
        }
        self.setUpValues()
    }
    
    func setUpValues() {
        //morning
        for (index, val) in self.monArr.enumerated() {
            let btn = self.mornigStack.subviews[index].subviews[0] as! UIButton
            if btn.tag == index + 1 {
                btn.isSelected = val
            }
        }
        
        //noon
        for (index, val) in self.noonArr.enumerated() {
            let btn = self.noonStack.subviews[index].subviews[0] as! UIButton
            if btn.tag == index + 1 {
                btn.isSelected = val
            }
        }
        
        //evening
        for (index, val) in self.eveArr.enumerated() {
            let btn = self.eveningStack.subviews[index].subviews[0] as! UIButton
            if btn.tag == index + 1 {
                btn.isSelected = val
            }
        }
    }

    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnTransportClick(sender: UISwitch) {
        self.isTransport = sender.isOn
    }
    
    @IBAction func btnWeekDaysClick(sender: UIButton) {
        if sender.isSelected {
            //Remove
            sender.isSelected = false
            if sender.superview?.superview as? UIStackView == self.mornigStack {
                self.monArr.remove(at: sender.tag - 1)
                self.monArr.insert(false, at: sender.tag - 1)
            } else if sender.superview?.superview as? UIStackView == self.noonStack {
                self.noonArr.remove(at: sender.tag - 1)
                self.noonArr.insert(false, at: sender.tag - 1)
            } else if sender.superview?.superview as? UIStackView == self.eveningStack {
                self.eveArr.remove(at: sender.tag - 1)
                self.eveArr.insert(false, at: sender.tag - 1)
            }
        } else {
            //Add
            sender.isSelected = true
            if sender.superview?.superview as? UIStackView == self.mornigStack {
                self.monArr.remove(at: sender.tag - 1)
                self.monArr.insert(true, at: sender.tag - 1)
            } else if sender.superview?.superview as? UIStackView == self.noonStack {
                self.noonArr.remove(at: sender.tag - 1)
                self.noonArr.insert(true, at: sender.tag - 1)
            } else if sender.superview?.superview as? UIStackView == self.eveningStack {
                self.eveArr.remove(at: sender.tag - 1)
                self.eveArr.insert(true, at: sender.tag - 1)
            }
        }
    }
    
    //MARK: API Calling on Submit Availability
    @IBAction func submitAvailability(sender: UIButton) {
        self.view.endEditing(true)
        if self.txtHours.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter Weekly Hours!")
            return
        }
        self.updateAvailability()
    }
    
    func updateAvailability() {
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        
        for (index, obj) in self.availArray.enumerated() {
            let dic = NSMutableDictionary()
            if self.isTransport == true {
                dic.setValue("1", forKey: "is_reliable_transportation")
            } else {
                dic.setValue("2", forKey: "is_reliable_transportation")
            }
            dic.setValue(self.txtHours.text!, forKey: "work_hour_per_week")
            dic.setValue(obj["id"].stringValue, forKey: "id")
            dic.setValue(obj["user_id"].stringValue, forKey: "user_id")
            dic.setValue(obj["day"].stringValue, forKey: "day")
            if self.monArr[index] == true {
                dic.setValue("1", forKey: "morning")
            } else {
                dic.setValue("2", forKey: "morning")
            }
            if self.noonArr[index] == true {
                dic.setValue("1", forKey: "afternoon")
            } else {
                dic.setValue("2", forKey: "afternoon")
            }
            if self.eveArr[index] == true {
                dic.setValue("1", forKey: "evening")
            } else {
                dic.setValue("2", forKey: "evening")
            }
            dic.setValue(obj["created_at"].stringValue, forKey: "created_at")
            self.availArray.remove(at: index)
            self.availArray.insert(JSON.init(dic), at: index)
        }
        
        let param : NSMutableDictionary =  NSMutableDictionary()
        param.setValue(JSON.init(self.availArray), forKey: "json")
        print(param)
        let successed = {(responseObject: AnyObject) -> Void in
            self.stopAnimating()
            if responseObject != nil{
                let dataObj : JSON = JSON.init(responseObject)
                if(dataObj["status"].stringValue == "1") {
                    self.showAlert(title: App_Title, msg: "Availability Submitted Successfully")
                    self.navigationController?.popViewController(animated: true)
                }else{
                    self.showAlert(title: App_Title, msg: responseObject.value(forKeyPath: "message") as! String)
                }
            }
        }
        let failure = {(error: AnyObject) -> Void in
            self.stopAnimating()
            self.showAlert(title: App_Title, msg: WrongMsg)
        }
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: "get_json_decode" as NSString, success: successed, failure: failure)
    }
}
