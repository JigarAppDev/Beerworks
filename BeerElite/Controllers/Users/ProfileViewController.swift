//
//  ProfileViewController.swift
//  BeerElite
//
//  Created by Jigar on 04/03/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SwiftyJSON
import Kingfisher

class ProfileViewController: UIViewController, NVActivityIndicatorViewable, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var lblName: UILabel!
    @IBOutlet var txtName: UITextField!
    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var txtPhone: UITextField!
    @IBOutlet var txtCity: UITextField!
    @IBOutlet var txtCurrOcupation: UITextField!
    @IBOutlet var userProfile: UIImageView!
    @IBOutlet var userProButton: UIButton!
    @IBOutlet var updateButton: UIButton!
    
    var selectedImage = UIImage()
    var isFrom = ""
    var userId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if self.isFrom == "Chat" {
            self.txtName.placeholder = "Name (First and Last)"
            self.lblName.text = "Name (First and Last)"
            self.updateButton.isHidden = true
            self.userProButton.isHidden = true
            self.txtName.isUserInteractionEnabled = false
            self.txtEmail.isUserInteractionEnabled = false
            self.txtPhone.isUserInteractionEnabled = false
            self.txtCity.isUserInteractionEnabled = false
            self.txtCurrOcupation.isUserInteractionEnabled = false
        } else {
            self.userId = Defaults.value(forKey: "user_id") as! String
            if userType == "Provider" {
                self.txtName.placeholder = "Business Name"
                self.lblName.text = "Business Name"
            } else {
                self.txtName.placeholder = "Name (First and Last)"
                self.lblName.text = "Name (First and Last)"
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.getProfileInfo(uid: self.userId)
    }
    
    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Get Profile Info
    func getProfileInfo(uid: String) {
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        param.setValue(uid, forKey: "user_id")
        let successed = {(responseObject: AnyObject) -> Void in
            self.stopAnimating()
            if responseObject != nil{
                let dataObj : JSON = JSON.init(responseObject)
                if(dataObj["status"].stringValue == "1") {
                    let data = dataObj["data"].dictionaryValue
                    self.txtName.text = data["username"]!.stringValue
                    self.txtEmail.text = data["email"]!.stringValue
                    self.txtCity.text = data["city"]!.stringValue
                    if data["phone_number"]?.stringValue != "" {
                        self.txtPhone.text = data["phone_number"]?.stringValue
                    }
                    self.txtCurrOcupation.text = data["current_occupation"]!.stringValue
                    let pic = data["profile_pic"]!.stringValue
                    if pic == "" {
                        self.userProfile.image = nil //UIImage.init(named: "ios_icon")
                    } else {
                        self.userProfile.kf.setImage(with: URL(string: pic))
                    }
                }else{
                    self.showAlert(title: App_Title, msg: responseObject.value(forKeyPath: "message") as! String)
                }
            }
        }
        let failure = {(error: AnyObject) -> Void in
            self.stopAnimating()
            self.showAlert(title: App_Title, msg: WrongMsg)
        }
        
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: GETUSERPROFILEAPI as NSString, success: successed, failure: failure)
    }
    
    //MARK: Update Click
    @IBAction func btnUpdateClick(sender: UIButton) {
        if self.validateUser() {
            self.updateProfileAPI()
        }
    }
    
    //MARK: - Validate Signup Data Method
    func validateUser() -> Bool {
        var boolVal : Bool = true
        if self.selectedImage == nil {
            showAlert(title: App_Title, msg: "Please Select Your Profile Image")
            boolVal = false
        } else if txtName.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            if userType == "Provider" {
                showAlert(title: App_Title, msg: "Please Enter Business Name")
            } else {
                showAlert(title: App_Title, msg: "Please Enter Name (First and Last)")
            }
            boolVal = false
        }else if txtEmail.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter Email Address")
            boolVal = false
        }else if AppUtilities.sharedInstance.isValidEmail(emailAddressString: txtEmail.text!) == false {
            showAlert(title: App_Title, msg: "Please Enter Valid Email")
            boolVal = false
        }else if txtPhone.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter Phone Number")
            boolVal = false
        }else if txtCity.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter City, State & Zip")
            boolVal = false
        }else if txtCurrOcupation.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter Your Current Occupation")
            boolVal = false
        }
        return boolVal
    }
    
    //MARK: - Make Update Profile
    func updateProfileAPI() {
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        param.setValue(self.txtName.text!, forKey: "username")
        param.setValue(self.txtEmail.text!, forKey: "email")
        param.setValue(self.txtCity.text!, forKey: "city")
        param.setValue(self.txtPhone.text!, forKey: "phone_number")
        param.setValue(self.txtCurrOcupation.text!, forKey: "current_occupation")
        
        let profileArray : NSMutableDictionary =  NSMutableDictionary()
        if self.selectedImage != nil {
            profileArray.setValue(self.selectedImage, forKey: "profile_pic")
        }
        
        let successed = {(responseObject: AnyObject) -> Void in
            self.stopAnimating()
            if responseObject != nil{
                let dataObj : JSON = JSON.init(responseObject)
                if(dataObj["status"].stringValue == "1") {
                    if (responseObject.value(forKeyPath: "data")) != nil{
                        self.setDefaultData(responseObject: responseObject)
                    }
                    self.showAlert(title: App_Title, msg: "My Profile Saved!")
                }else{
                    self.showAlert(title: App_Title, msg: responseObject.value(forKeyPath: "message") as! String)
                }
            }
        }
        let failure = {(error: AnyObject) -> Void in
            self.stopAnimating()
            self.showAlert(title: App_Title, msg: WrongMsg)
        }
        
        service.uploadWithAlamofire(Parameters: param as? [String : AnyObject], ImageParameters: profileArray as [NSObject : AnyObject], VideoParameters: nil, FileParameters: nil, Action: UPDATEPROFILEAPI as NSString, success: successed, failure: failure)
        
    }
    
    func setDefaultData(responseObject : AnyObject) {
        
        let dataFull : JSON = JSON.init(responseObject)
        let data : JSON = JSON.init(dataFull["data"])
        userData = data
        let user_Email = data["email"].stringValue
        Defaults.setValue(user_Email, forKey: "user_email")
        let profilePic = data["profile_pic"].stringValue
        if profilePic != "" {
            Defaults.setValue(profilePic, forKey: "profile_pic")
        }
        let user_Name = data["username"].stringValue
        Defaults.setValue(user_Name, forKey: "user_name")
        if userType == "User" {
            Defaults.setValue(data["city"].stringValue, forKey: "user_city")
        }
        Defaults.synchronize()
    }
    
    //MARK: Upload picture to attach
    @IBAction func clkAddFiles(sender : UIButton){
        let actionSheetControllerIOS8: UIAlertController = UIAlertController(title: "Upload Image", message: "Select your option!", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheetControllerIOS8.addAction(cancelActionButton)
        
        let saveActionButton = UIAlertAction(title: "Camera", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                let imag = UIImagePickerController()
                imag.delegate = self
                imag.sourceType = UIImagePickerController.SourceType.camera;
                imag.allowsEditing = true
                self.present(imag, animated: true, completion: nil)
            } else {
                self.showAlert(title: App_Title, msg: "Device has no camera!")
            }
        }
        actionSheetControllerIOS8.addAction(saveActionButton)
        
        let deleteActionButton = UIAlertAction(title: "Library", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
                let imag = UIImagePickerController()
                imag.delegate = self
                imag.sourceType = UIImagePickerController.SourceType.photoLibrary
                imag.allowsEditing = true
                self.present(imag, animated: true, completion: nil)
            }
        }
        actionSheetControllerIOS8.addAction(deleteActionButton)
        self.present(actionSheetControllerIOS8, animated: true, completion: nil)
    }
    
    //MARK: - Image Picker Delegate Method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let tempImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        //guard let imageData = tempImage.jpegData(compressionQuality: 0.75) else { return }
        self.selectedImage = tempImage
        self.userProfile.image = tempImage
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
