//
//  ApplyViewController.swift
//  BeerElite
//
//  Created by Jigar on 21/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SwiftyJSON
import Kingfisher
import CoreServices

class ApplyViewController: UIViewController, NVActivityIndicatorViewable, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {

    @IBOutlet var txtFirstName: UITextField!
    @IBOutlet var txtLastName: UITextField!
    @IBOutlet var txtCurOccupation: UITextField!
    @IBOutlet var txtCityState: UITextField!
    @IBOutlet var lblImageName: UILabel!
    @IBOutlet var lblFileName: UILabel!
    
    var dataObj: JobsDataModel!
    var selectedImage = UIImage()
    var selectedFileData = Data()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Add Button Click
    @IBAction func btnAddInfo(sender: UIButton) {
        if self.validateUser() {
            self.applyForJob()
        }
    }
    
    //MARK: - Validate Data Method
    func validateUser() -> Bool {
        var boolVal : Bool = true
        if txtFirstName.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter FirstName")
            boolVal = false
        }else if txtLastName.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter LastName")
            boolVal = false
        }else if txtCurOccupation.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter Current Occupation")
            boolVal = false
        }else if txtCityState.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            showAlert(title: App_Title, msg: "Please Enter Current City,State & Zip")
            boolVal = false
        }
        return boolVal
    }
    
    //MARK: API Calling
    func applyForJob() {
        if dataObj.applied_by_me == "1" {
            self.showAlert(title: App_Title, msg: "You have applied for this job already.")
            return
        }
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        param.setValue(self.dataObj.jobId, forKey: "job_id")
        param.setValue(self.txtFirstName.text!, forKey: "first_name")
        param.setValue(self.txtLastName.text!, forKey: "last_name")
        param.setValue(self.txtCurOccupation.text!, forKey: "occupation")
        param.setValue(self.txtCityState.text!, forKey: "address")
        //image
        let profileArray : NSMutableDictionary =  NSMutableDictionary()
        if self.selectedImage != nil {
            profileArray.setValue(self.selectedImage, forKey: "user_image")
        }
        //file
        let fileArray : NSMutableDictionary =  NSMutableDictionary()
        if self.selectedFileData != nil {
            fileArray.setValue(self.selectedFileData, forKey: "user_resume")
        }
        
        let successed = {(responseObject: AnyObject) -> Void in
            self.stopAnimating()
            if responseObject != nil{
                let dataObj : JSON = JSON.init(responseObject)
                if(dataObj["status"].stringValue == "1") {
                    //self.showAlert(title: App_Title, msg: dataObj["message"].stringValue)
                    self.showAlert(title: App_Title, msg: "Applied! Good Luck!")
                }else{
                    self.showAlert(title: App_Title, msg: responseObject.value(forKeyPath: "message") as! String)
                }
            }
        }
        let failure = {(error: AnyObject) -> Void in
            self.stopAnimating()
            self.showAlert(title: App_Title, msg: WrongMsg)
        }
        
        service.uploadWithAlamofire(Parameters: param as? [String : AnyObject], ImageParameters: profileArray as [NSObject : AnyObject], VideoParameters: nil, FileParameters: fileArray as [NSObject : AnyObject], Action: APPLYFORJOBAPI as NSString, success: successed, failure: failure)
    }
    
    //MARK: Upload picture to attach
    @IBAction func clkAddImages(sender : UIButton){
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
    
    @IBAction func clkAddFiles(sender : UIButton){
        let actionSheetControllerIOS8: UIAlertController = UIAlertController(title: "Upload Resume", message: "Select your option!", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheetControllerIOS8.addAction(cancelActionButton)
        
        let iCloudActionButton = UIAlertAction(title: "PDF File", style: .default) { _ in
            let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String], in: UIDocumentPickerMode.import)
            documentPicker.delegate = self
            documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            self.present(documentPicker, animated: true, completion: nil)
        }
        actionSheetControllerIOS8.addAction(iCloudActionButton)
        self.present(actionSheetControllerIOS8, animated: true, completion: nil)
    }
    
    //MARK: - Image Picker Delegate Method
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let tempImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        //guard let imageData = tempImage.jpegData(compressionQuality: 0.75) else { return }
        self.selectedImage = tempImage
        if let url: NSURL = info[UIImagePickerController.InfoKey.imageURL] as? NSURL {
            self.lblImageName.text = url.lastPathComponent
        } else {
            let identifier = UUID()
            self.lblImageName.text = identifier.uuidString + ".png"
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        do {
            let filePath = urls[0]
            let fileData = try Data.init(contentsOf: filePath)
            self.selectedFileData = fileData
            self.lblFileName.text = urls[0].lastPathComponent
        } catch let error {
            self.showAlert(title: App_Title, msg: error.localizedDescription)
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("dismiss files")
    }
}
