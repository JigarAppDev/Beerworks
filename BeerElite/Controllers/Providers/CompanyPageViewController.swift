//
//  CompanyPageViewController.swift
//  BeerElite
//
//  Created by Jigar on 18/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SwiftyJSON
import Kingfisher
import MapKit

class CompanyPageViewController: UIViewController, NVActivityIndicatorViewable, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {
    
    @IBOutlet var btnUpdateInfo: UIButton!
    @IBOutlet var btnUpdateAbout: UIButton!
    @IBOutlet var btnUpdateAddress: UIButton!
    @IBOutlet var btnUpdateImage: UIButton!
    @IBOutlet var txvAbout: UITextView!
    @IBOutlet var lblAddress: UILabel!
    @IBOutlet var lblWebsite: UILabel!
    @IBOutlet var lblCompanyName: UILabel!
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblEmail: UILabel!
    @IBOutlet var btnMessage: UIButton!
    @IBOutlet var mapKitView: MKMapView!
    @IBOutlet var companyProfile: UIImageView!
    var companyId = ""
    var selectedImage = UIImage()
    var isFrom = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapKitView.delegate = self
        self.mapKitView.isUserInteractionEnabled = false
        
        if self.isFrom == "SignUp" {
            self.showAlert(title: App_Title, msg: "You're one step closer to hiring an elite beer staff! Please complete company profile before posting your first job!")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if userType == "User" {
            self.btnUpdateInfo.isHidden = true
            self.btnUpdateAbout.isHidden = true
            self.btnUpdateAddress.isHidden = true
            self.btnUpdateImage.isHidden = true
            self.getCompanyInfo()
        } else {
            self.btnUpdateInfo.isHidden = false
            self.btnUpdateAbout.isHidden = false
            self.btnUpdateAddress.isHidden = false
            self.btnUpdateImage.isHidden = false
            self.getCompanyInfoByPro()
        }
    }
    
    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Get Lat long to show marker on map
    func showMarkerOnMap(address: String) {
        
        if address == "" {
            return
        }
        self.mapKitView.removeAnnotations(self.mapKitView.annotations)
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    // handle no location found
                    return
            }
            let coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            let annotation = MKPointAnnotation()
            annotation.title = address
            annotation.coordinate = coordinate
            self.mapKitView.addAnnotation(annotation)
        }
        
        self.mapKitView.fitAllAnnotations()
    }
    
    //MARK: Edit Company Name
    @IBAction func btnAddCName(sender: UIButton) {
        let nameVC = self.storyboard?.instantiateViewController(withIdentifier: "AddCompanyNameViewController") as! AddCompanyNameViewController
        nameVC.companyId = self.companyId
        nameVC.cname = self.lblCompanyName.text!
        self.navigationController?.pushViewController(nameVC, animated: true)
    }
    
    //MARK: Edit Company Info
    @IBAction func btnAddAboutUs(sender: UIButton) {
        let aboutVC = self.storyboard?.instantiateViewController(withIdentifier: "AddAboutCompanyViewController") as! AddAboutCompanyViewController
        aboutVC.companyId = self.companyId
        aboutVC.about = self.txvAbout.text
        self.navigationController?.pushViewController(aboutVC, animated: true)
    }
    
    //MARK: Edit Location & URL
    @IBAction func btnEditWebLocation(sender: UIButton) {
        let webVC = self.storyboard?.instantiateViewController(withIdentifier: "AddWebLocationViewController") as! AddWebLocationViewController
        webVC.companyId = self.companyId
        webVC.addr = self.lblAddress.text!
        webVC.web = self.lblWebsite.text!
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    //MARK: Get Company Info
    func getCompanyInfo() {
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        param.setValue(self.companyId, forKey: "company_id")
        let successed = {(responseObject: AnyObject) -> Void in
            self.stopAnimating()
            if responseObject != nil{
                let dataObj : JSON = JSON.init(responseObject)
                if(dataObj["status"].stringValue == "1") {
                    let data = dataObj["data"].arrayValue
                    let cData = data[0]
                    self.txvAbout.text = cData["company_about"].stringValue
                    self.lblWebsite.text = cData["company_website"].stringValue
                    self.lblAddress.text = cData["company_address"].stringValue
                    self.lblName.text = cData["username"].stringValue
                    self.lblCompanyName.text = cData["company_name"].stringValue
                    self.lblEmail.text = cData["email"].stringValue
                    self.companyId = cData["company_id"].stringValue
                    let pic = cData["profile_pic"].stringValue
                    if pic == "" {
                        self.imgProfile.image = UIImage.init(named: "ios_icon")
                    } else {
                        self.imgProfile.kf.setImage(with: URL(string: pic))
                    }
                    let compPic = cData["company_image"].stringValue
                    if compPic == "" {
                        self.companyProfile.image = nil //UIImage.init(named: "ios_icon")
                    } else {
                        self.companyProfile.kf.setImage(with: URL(string: compPic))
                    }
                    self.showMarkerOnMap(address: cData["company_address"].stringValue)
                    let city = cData["city"].stringValue
                    self.btnMessage.setTitle(city, for: .normal)
                }else{
                    self.showAlert(title: App_Title, msg: responseObject.value(forKeyPath: "message") as! String)
                }
            }
        }
        let failure = {(error: AnyObject) -> Void in
            self.stopAnimating()
            self.showAlert(title: App_Title, msg: WrongMsg)
        }
        
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: VIEWCOMPANYAPI as NSString, success: successed, failure: failure)
    }
    
    //MARK: Get Company Info by Pro
    func getCompanyInfoByPro() {
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        let uid = Defaults.value(forKey: "user_id") as? String
        param.setValue(uid, forKey: "user_id")
        let successed = {(responseObject: AnyObject) -> Void in
            self.stopAnimating()
            if responseObject != nil{
                let dataObj : JSON = JSON.init(responseObject)
                if(dataObj["status"].stringValue == "1") {
                    let data = dataObj["data"]
                    self.txvAbout.text = data["company_about"].stringValue
                    self.lblWebsite.text = data["company_website"].stringValue
                    self.lblAddress.text = data["company_address"].stringValue
                    self.lblName.text = data["username"].stringValue
                    self.lblCompanyName.text = data["company_name"].stringValue
                    self.lblEmail.text = data["email"].stringValue
                    self.companyId = data["company_id"].stringValue
                    let pic = data["profile_pic"].stringValue
                    if pic == "" {
                        self.imgProfile.image = UIImage.init(named: "ios_icon")
                    } else {
                        self.imgProfile.kf.setImage(with: URL(string: pic))
                    }
                    let compPic = data["company_image"].stringValue
                    if compPic == "" {
                        self.companyProfile.image = UIImage.init(named: "ios_icon")
                    } else {
                        self.companyProfile.kf.setImage(with: URL(string: compPic))
                    }
                    self.showMarkerOnMap(address: data["company_address"].stringValue)
                    let city = data["city"].stringValue
                    self.btnMessage.setTitle(city, for: .normal)
                }else{
                    self.showAlert(title: App_Title, msg: responseObject.value(forKeyPath: "message") as! String)
                }
            }
        }
        let failure = {(error: AnyObject) -> Void in
            self.stopAnimating()
            self.showAlert(title: App_Title, msg: WrongMsg)
        }
        
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: VIEWCOMPANYBYPROAPI as NSString, success: successed, failure: failure)
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
        self.companyProfile.image = tempImage
        self.updateComapnyImage()
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Update company profile image
    func updateComapnyImage() {
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        param.setValue(self.companyId, forKey: "company_id")
        let profileArray : NSMutableDictionary =  NSMutableDictionary()
        if self.selectedImage != nil {
            profileArray.setValue(self.selectedImage, forKey: "company_image")
        }
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
        
        service.uploadWithAlamofire(Parameters: param as? [String : AnyObject], ImageParameters: profileArray as [NSObject : AnyObject], VideoParameters: nil, FileParameters: nil, Action: UPDATECOMPANYAPI as NSString, success: successed, failure: failure)
    }
}

extension CompanyPageViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = MKMarkerAnnotationView()
        guard let annotation = annotation as? MKPointAnnotation else {return nil}
        let identifier = ""
        annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        annotationView.markerTintColor = .gray
        //annotationView.glyphImage = UIImage(named: "map_pin_icon")
        annotationView.clusteringIdentifier = identifier
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print(view.annotation!.title)
    }
}

extension MKMapView {
    func fitAllAnnotations() {
        
        guard annotations.count > 0 else {
            return
        }
        var topLeftCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        topLeftCoord.latitude = -90
        topLeftCoord.longitude = 180
        var bottomRightCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        bottomRightCoord.latitude = 90
        bottomRightCoord.longitude = -180
        for annotation: MKAnnotation in annotations {
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude)
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude)
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude)
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude)
        }
        
        var region: MKCoordinateRegion = MKCoordinateRegion()
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.4
        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.4
        region = regionThatFits(region)
        setRegion(region, animated: true)
    }
}
