//
//  BeerBioViewController.swift
//  BeerElite
//
//  Created by Jigar on 21/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SwiftyJSON
import Kingfisher

class tblBeerBioCell: UITableViewCell {
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var txtAnswer: UITextField!
}

class BeerBioViewController: UIViewController, NVActivityIndicatorViewable, UITextFieldDelegate {
    
    @IBOutlet var tblBeerBio: UITableView!
    var quesArray = ["Favorite Brewery? What makes it so special?","Favorite Beer? How would you recommend it to someone?","How would you explain the difference between an ale and a lager?","Favorite style of IPA? Name and describe two of your favorite hops from that style.","Describe the vibe of your favorite brewery, bar or restaurant?","What made you want to work in craft beer?","Your thoughts on independent craft vs Big Beer?","What styles would you recommend to someone who doesn't like IPAs?","Describe your favorite food and beer combo?","What would you do if one of your patrons has clearly had too much to drink?","Describe your personality.","How well do you work in a fast-paced environment?","How many hours are you looking for and what's your availability?","Any days/nights you can't work?","Anything you'd like to add?"]
    var ansArray = ["","","","","","","","","","","","","","",""]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tblBeerBio.estimatedRowHeight = 123
        self.tblBeerBio.rowHeight = UITableView.automaticDimension
    }
    
    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    //MARK: API Calling on Submit
    @IBAction func submitBioAns(sender: UIButton) {
        self.view.endEditing(true)
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        //let uid = Defaults.value(forKey: "user_id") as? String
        param.setValue(self.ansArray[0], forKey: "question_1")
        param.setValue(self.ansArray[1], forKey: "question_2")
        param.setValue(self.ansArray[2], forKey: "question_3")
        param.setValue(self.ansArray[3], forKey: "question_4")
        param.setValue(self.ansArray[4], forKey: "question_5")
        param.setValue(self.ansArray[5], forKey: "question_6")
        param.setValue(self.ansArray[6], forKey: "question_7")
        param.setValue(self.ansArray[7], forKey: "question_8")
        param.setValue(self.ansArray[8], forKey: "question_9")
        param.setValue(self.ansArray[9], forKey: "question_10")
        param.setValue(self.ansArray[10], forKey: "question_11")
        param.setValue(self.ansArray[11], forKey: "question_12")
        param.setValue(self.ansArray[12], forKey: "question_13")
        param.setValue(self.ansArray[13], forKey: "question_14")
        param.setValue(self.ansArray[14], forKey: "question_15")
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
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: ADDBEERBIOAPI as NSString, success: successed, failure: failure)
    }
    
    //MARK: Textfield Delegate Method
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            self.ansArray.insert(textField.text!, at: 0)
        } else if textField.tag == 2 {
            self.ansArray.insert(textField.text!, at: 1)
        } else if textField.tag == 3 {
            self.ansArray.insert(textField.text!, at: 2)
        } else if textField.tag == 4 {
            self.ansArray.insert(textField.text!, at: 3)
        } else if textField.tag == 5 {
            self.ansArray.insert(textField.text!, at: 4)
        } else if textField.tag == 6 {
            self.ansArray.insert(textField.text!, at: 5)
        } else if textField.tag == 7 {
            self.ansArray.insert(textField.text!, at: 6)
        } else if textField.tag == 8 {
            self.ansArray.insert(textField.text!, at: 7)
        } else if textField.tag == 9 {
            self.ansArray.insert(textField.text!, at: 8)
        } else if textField.tag == 10 {
            self.ansArray.insert(textField.text!, at: 9)
        } else if textField.tag == 11 {
            self.ansArray.insert(textField.text!, at: 10)
        } else if textField.tag == 12 {
            self.ansArray.insert(textField.text!, at: 11)
        } else if textField.tag == 13 {
            self.ansArray.insert(textField.text!, at: 12)
        } else if textField.tag == 14 {
            self.ansArray.insert(textField.text!, at: 13)
        } else if textField.tag == 15 {
            self.ansArray.insert(textField.text!, at: 14)
        }
    }
}

//MARK: Table Delegate Methods
extension BeerBioViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.quesArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblBeerBio.dequeueReusableCell(withIdentifier: "tblBeerBioCell") as! tblBeerBioCell
        cell.lblTitle.text = self.quesArray[indexPath.row]
        cell.txtAnswer.tag = indexPath.row + 1
        cell.txtAnswer.delegate = self
        cell.txtAnswer.placeholder = "Answer"
        if self.ansArray[indexPath.row] != "Answer" {
            cell.txtAnswer.text = self.ansArray[indexPath.row]
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
