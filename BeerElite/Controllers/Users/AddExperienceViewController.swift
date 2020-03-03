//
//  AddExperienceViewController.swift
//  BeerElite
//
//  Created by Jigar on 21/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SwiftyJSON
import Kingfisher

class AddExperienceViewController: UIViewController, NVActivityIndicatorViewable, SBPickerSelectorDelegate, UITextViewDelegate {

    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var btnAdd: UIButton!
    @IBOutlet var btnFrom: UIButton!
    @IBOutlet var btnUpto: UIButton!
    @IBOutlet var txtCompany: UITextField!
    @IBOutlet var txtPosition: UITextField!
    @IBOutlet var txvDetails: UITextView!
    var fromDate: Date!
    var upToDate: Date!
    var selectedObj: JSON!
    var formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.txvDetails.delegate = self
        
        if self.selectedObj != nil {
            self.lblTitle.text = "Update Experience"
            self.btnAdd.setTitle("Update Experience", for: .normal)
            formatter.dateFormat = "yyyy-MM-dd"
            let dtFrom = formatter.date(from: self.selectedObj["work_period_from"].stringValue)
            self.fromDate = dtFrom
            let dtupTo = formatter.date(from: self.selectedObj["work_period_to"].stringValue)
            self.upToDate = dtupTo
            self.btnFrom.setTitle(self.selectedObj["work_period_from"].stringValue, for: .normal)
            self.btnUpto.setTitle(self.selectedObj["work_period_to"].stringValue, for: .normal)
            self.txtCompany.text = self.selectedObj["company"].stringValue
            self.txtPosition.text = self.selectedObj["position"].stringValue
            self.txvDetails.text = self.selectedObj["jobs_detail"].stringValue
        }
    }
    
    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    //MARK:- Select From date
    @IBAction func btnFromClick(sender: UIButton) {
        self.view.endEditing(true)
        let picker = SBPickerSelector()
        picker.tag = 101
        picker.delegate = self
        picker.pickerType = SBPickerSelectorType.date
        picker.datePickerType = .onlyDay
        picker.doneButtonTitle = "Done"
        picker.cancelButtonTitle = "Cancel"
        picker.doneButton?.tintColor = .black
        picker.cancelButton?.tintColor = .black
        picker.datePickerView.backgroundColor = UIColor.init(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
        picker.datePickerView.setValue(UIColor.white, forKeyPath: "textColor")
        picker.optionsToolBar?.barTintColor = UIColor(red: 223/255, green: 167/255, blue: 72/255, alpha: 1.0)
        picker.showPickerOver(self)
    }
    
    //MARK:- Select Upto date
    @IBAction func btnUpToClick(sender: UIButton) {
        self.view.endEditing(true)
        if self.fromDate == nil {
            self.showAlert(title: App_Title, msg: "Select from date first!")
            return
        }
        let picker = SBPickerSelector()
        picker.tag = 102
        picker.delegate = self
        picker.pickerType = SBPickerSelectorType.date
        picker.datePickerType = .onlyDay
        picker.doneButtonTitle = "Done"
        picker.cancelButtonTitle = "Cancel"
        picker.doneButton?.tintColor = .black
        picker.cancelButton?.tintColor = .black
        picker.datePickerView.backgroundColor = UIColor.init(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
        picker.datePickerView.setValue(UIColor.white, forKeyPath: "textColor")
        picker.optionsToolBar?.barTintColor = UIColor(red: 223/255, green: 167/255, blue: 72/255, alpha: 1.0)
        picker.datePickerView.minimumDate = self.fromDate
        picker.showPickerOver(self)
    }
    
    //MARK:- Picker delegate methods
    func pickerSelector(_ selector: SBPickerSelector, dateSelected date: Date) {
        print(date)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if selector.tag == 101 {
            //From
            self.fromDate = date
            self.btnFrom.setTitle(dateFormatter.string(from: date), for: .normal)
        } else {
            //Upto
            self.upToDate = date
            self.btnUpto.setTitle(dateFormatter.string(from: date), for: .normal)
        }
    }
    
    //MARK: - Validate Data Method
    func validateData() -> Bool {
        var boolVal : Bool = true
        if self.fromDate == nil {
            showAlert(title: App_Title, msg: "Please Select From Date")
            boolVal = false
        }else if self.upToDate == nil {
            showAlert(title: App_Title, msg: "Please Select UpTo Date")
            boolVal = false
        }else if txtCompany.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter Company Name")
            boolVal = false
        }else if txtPosition.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter Position")
            boolVal = false
        }else if txvDetails.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter Some Details")
            boolVal = false
        }
        return boolVal
    }
    
    
    //MARK: API Calling on Submit
    @IBAction func submitExp(sender: UIButton) {
        self.view.endEditing(true)
        if self.selectedObj.isNull == false {
            //Update API
            self.updateExpAPI()
            return
        }
        if self.validateData() == false {
            return
        }
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        //let uid = Defaults.value(forKey: "user_id") as? String
        param.setValue(self.btnFrom.titleLabel?.text!, forKey: "work_period_from")
        param.setValue(self.btnUpto.titleLabel?.text!, forKey: "work_period_to")
        param.setValue(self.txtCompany.text!, forKey: "company")
        param.setValue(self.txtPosition.text!, forKey: "position")
        param.setValue(self.txvDetails.text!, forKey: "jobs_detail")
        print(param)
        let successed = {(responseObject: AnyObject) -> Void in
            self.stopAnimating()
            if responseObject != nil{
                let dataObj : JSON = JSON.init(responseObject)
                if(dataObj["status"].stringValue == "1") {
                    self.showAlert(title: App_Title, msg: dataObj["message"].stringValue)
                }else{
                    self.showAlert(title: App_Title, msg: responseObject.value(forKeyPath: "message") as! String)
                }
            }
        }
        let failure = {(error: AnyObject) -> Void in
            self.stopAnimating()
            self.showAlert(title: App_Title, msg: WrongMsg)
        }
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: ADDEXPERIENCEAPI as NSString, success: successed, failure: failure)
    }
    
    func updateExpAPI() {
        self.view.endEditing(true)
        if self.validateData() == false {
            return
        }
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        param.setValue(self.selectedObj["id"].stringValue, forKey: "id")
        param.setValue(self.btnFrom.titleLabel?.text!, forKey: "work_period_from")
        param.setValue(self.btnUpto.titleLabel?.text!, forKey: "work_period_to")
        param.setValue(self.txtCompany.text!, forKey: "company")
        param.setValue(self.txtPosition.text!, forKey: "position")
        param.setValue(self.txvDetails.text!, forKey: "jobs_detail")
        print(param)
        let successed = {(responseObject: AnyObject) -> Void in
            self.stopAnimating()
            if responseObject != nil{
                let dataObj : JSON = JSON.init(responseObject)
                if(dataObj["status"].stringValue == "1") {
                    self.showAlert(title: App_Title, msg: dataObj["message"].stringValue)
                }else{
                    self.showAlert(title: App_Title, msg: responseObject.value(forKeyPath: "message") as! String)
                }
            }
        }
        let failure = {(error: AnyObject) -> Void in
            self.stopAnimating()
            self.showAlert(title: App_Title, msg: WrongMsg)
        }
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: EDITEXPERIENCEAPI as NSString, success: successed, failure: failure)
    }
    
    //MARK: Textfield delegate methods
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Enter job details" {
           textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Enter job details"
        }
    }
    
}
