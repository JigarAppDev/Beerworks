//
//  ResumeViewController.swift
//  BeerElite
//
//  Created by Jigar on 18/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import SideMenu
import NVActivityIndicatorView
import SwiftyJSON

class CertiLevelCell: UICollectionViewCell {
    @IBOutlet var lblName : UILabel!
    @IBOutlet var viewName : UIView!
}

class ProfileCell: UITableViewCell {
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblEmail: UILabel!
    @IBOutlet var btnCity: UIButton!
    @IBOutlet var imgProfile: UIImageView!
    
    override func awakeFromNib() {
        
    }
}

class LevelCell: UITableViewCell {
    @IBOutlet var btnEdit: UIButton!
    @IBOutlet var levelCollectionView : UICollectionView!
    @IBOutlet var levelCollectionViewHeight : NSLayoutConstraint!
    let columnLayout = FlowLayout(
        itemSize: CGSize(width: Int(MAXLOGNAME), height: 30),
        minimumInteritemSpacing: 12,
        minimumLineSpacing: 20,
        sectionInset: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    )
    
    override func awakeFromNib() {
        self.levelCollectionView.collectionViewLayout = columnLayout
        self.levelCollectionView.reloadData()
        let height = levelCollectionView.collectionViewLayout.collectionViewContentSize.height
        levelCollectionViewHeight.constant = height
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}

class ExpCell: UITableViewCell {
    @IBOutlet var btnAdd: UIButton!
    @IBOutlet var tblExp: UITableView!
    @IBOutlet var tblExpHeight: NSLayoutConstraint!
}

class BeerBioCell: UITableViewCell {
    @IBOutlet var btnEdit: UIButton!
    @IBOutlet var lblQue1: UILabel!
    @IBOutlet var lblAns1: UILabel!
    @IBOutlet var lblQue2: UILabel!
    @IBOutlet var lblAns2: UILabel!
    @IBOutlet var lblQue3: UILabel!
    @IBOutlet var lblAns3: UILabel!
    @IBOutlet var lblQue4: UILabel!
    @IBOutlet var lblAns4: UILabel!
    @IBOutlet var lblQue5: UILabel!
    @IBOutlet var lblAns5: UILabel!
    @IBOutlet var lblQue6: UILabel!
    @IBOutlet var lblAns6: UILabel!
    @IBOutlet var lblQue7: UILabel!
    @IBOutlet var lblAns7: UILabel!
    @IBOutlet var lblQue8: UILabel!
    @IBOutlet var lblAns8: UILabel!
    @IBOutlet var lblQue9: UILabel!
    @IBOutlet var lblAns9: UILabel!
    @IBOutlet var lblQue10: UILabel!
    @IBOutlet var lblAns10: UILabel!
    @IBOutlet var lblQue11: UILabel!
    @IBOutlet var lblAns11: UILabel!
    @IBOutlet var lblQue12: UILabel!
    @IBOutlet var lblAns12: UILabel!
    @IBOutlet var lblQue13: UILabel!
    @IBOutlet var lblAns13: UILabel!
}

class InterestCell: UITableViewCell {
    @IBOutlet var btnEdit: UIButton!
    @IBOutlet var interestCollectionView : UICollectionView!
    @IBOutlet var interestCollectionViewHeight : NSLayoutConstraint!
    let columnLayout = FlowLayout(
        itemSize: CGSize(width: Int(MAXLOGNAME), height: 30),
        minimumInteritemSpacing: 12,
        minimumLineSpacing: 20,
        sectionInset: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    )
    
    override func awakeFromNib() {
        self.interestCollectionView.collectionViewLayout = columnLayout
        self.interestCollectionView.reloadData()
        let height = interestCollectionView.collectionViewLayout.collectionViewContentSize.height
        interestCollectionViewHeight.constant = height
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}

class EducationCell: UITableViewCell {
    @IBOutlet var btnAdd: UIButton!
    @IBOutlet var tblEdu: UITableView!
    @IBOutlet var tblEduHeight: NSLayoutConstraint!
}

class TimePeriodSubCell: UITableViewCell {
    @IBOutlet var btnEdit: UIButton!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblBarName: UILabel!
    @IBOutlet var lblBarType: UILabel!
    @IBOutlet var lblDescr: UILabel!
}

class ResumeViewController: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet var tblResume: UITableView!
    @IBOutlet var btnUpdateBio: UIButton!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var btnMenu: UIButton!
    var selectedObj: UserDataModel!
    
    //Level
    var levelArray = ["BarTending","Bar-back","Bar Tending(Full Liquor)"]
    
    //Interest
    var interestArray = ["Certified","Advanced","BJCP Judge"]
    
    //QuesArray
    var quesArray = ["Tell me about yourself.","Favourite Brewery. Why?","Favourite Beer. Why?","Describe the vibe of your favourite brewery, bar or restaurant.","Outside of work, what type of creative activities do you like to do?","Your thoughts on independent Beer vs Big Beer?","What type of beers would you recommend to someone new to craft beer?","Your thoughts on the Haze Craze?","Describe your favlourite food and beer combo?","What would you do if one of your patrons has clearly had too much to drink?","How many hours are you looking for and what your availability?","Any days/nights you can not work?","Anything you'd like to add?"]
    var ansArray = ["Answer","Answer","Answer","Answer","Answer","Answer","Answer","Answer","Answer","Answer","Answer","Answer","Answer"]
    
    var eduArray = [JSON]()
    var expArray = [JSON]()
    var email = ""
    var address = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tblResume.estimatedRowHeight = 200
        self.tblResume.rowHeight = UITableView.automaticDimension
        if userType == "User" {
            self.btnMenu.isHidden = false
            self.btnBack.isHidden = true
            self.btnUpdateBio.isHidden = false
        } else {
            self.btnMenu.isHidden = true
            self.btnBack.isHidden = false
            self.btnUpdateBio.isHidden = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.createChatResponse(noti:)), name:
            NSNotification.Name(rawValue: "createChatResponse"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getProfileData()
        
        if SocketHelper.CheckSocketIsConnectOrNot() == false {
            //Connect to socket
            SocketHelper.connectSocket()
        }
    }
    
    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Side menu click
    @IBAction func btnSideMenuClick(sender: UIButton) {
        let userStoryBoard = UIStoryboard.init(name: "User", bundle: nil)
        let menu = userStoryBoard.instantiateViewController(withIdentifier: "LeftMenu") as! SideMenuNavigationController
        menu.statusBarEndAlpha = 0
        menu.menuWidth = self.view.frame.width - (self.view.frame.width / 3)
        menu.presentationStyle = .menuSlideIn
        present(menu, animated: true, completion: nil)
    }
    
    @objc func updateLevelClick(sender: UIButton) {
        let userStoryBoard = UIStoryboard.init(name: "User", bundle: nil)
        let levelVC = userStoryBoard.instantiateViewController(withIdentifier: "AddCertiLevelViewController") as! AddCertiLevelViewController
        levelVC.levelArray = self.levelArray
        self.navigationController?.pushViewController(levelVC, animated: true)
    }
    
    @objc func addWorkClick(sender: UIButton) {
        let userStoryBoard = UIStoryboard.init(name: "User", bundle: nil)
        let expVC = userStoryBoard.instantiateViewController(withIdentifier: "AddExperienceViewController") as! AddExperienceViewController
        self.navigationController?.pushViewController(expVC, animated: true)
    }
    
    @objc func updateBioClick(sender: UIButton) {
        let userStoryBoard = UIStoryboard.init(name: "User", bundle: nil)
        let bioVC = userStoryBoard.instantiateViewController(withIdentifier: "BeerBioViewController") as! BeerBioViewController
        bioVC.ansArray = self.ansArray
        self.navigationController?.pushViewController(bioVC, animated: true)
    }
    
    @objc func updateInterestClick(sender: UIButton) {
        let userStoryBoard = UIStoryboard.init(name: "User", bundle: nil)
        let interestVC = userStoryBoard.instantiateViewController(withIdentifier: "AddInterestViewController") as! AddInterestViewController
        interestVC.interestArray = self.interestArray
        self.navigationController?.pushViewController(interestVC, animated: true)
    }
    
    @objc func addEducationClick(sender: UIButton) {
        let userStoryBoard = UIStoryboard.init(name: "User", bundle: nil)
        let eduVC = userStoryBoard.instantiateViewController(withIdentifier: "AddEducationViewController") as! AddEducationViewController
        self.navigationController?.pushViewController(eduVC, animated: true)
    }
    
    @objc func editWorkClick(sender: UIButton) {
        let userStoryBoard = UIStoryboard.init(name: "User", bundle: nil)
        let expVC = userStoryBoard.instantiateViewController(withIdentifier: "AddExperienceViewController") as! AddExperienceViewController
        expVC.selectedObj = self.expArray[sender.tag]
        self.navigationController?.pushViewController(expVC, animated: true)
    }
    
    @objc func editEducationClick(sender: UIButton) {
        let userStoryBoard = UIStoryboard.init(name: "User", bundle: nil)
        let eduVC = userStoryBoard.instantiateViewController(withIdentifier: "AddEducationViewController") as! AddEducationViewController
        eduVC.selectedObj = self.eduArray[sender.tag]
        self.navigationController?.pushViewController(eduVC, animated: true)
    }
    
    //MARK: Get Full Resume Data
    func getProfileData() {
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let param : NSMutableDictionary =  NSMutableDictionary()
        if userType == "User" {
            let uid = Defaults.value(forKey: "user_id") as? String
            param.setValue(uid, forKey: "user_id")
        } else {
            param.setValue(self.selectedObj.user_id!, forKey: "user_id")
        }
        let successed = {(responseObject: AnyObject) -> Void in
            self.stopAnimating()
            if responseObject != nil{
                let dataObj : JSON = JSON.init(responseObject)
                if(dataObj["status"].stringValue == "1") {
                    let data = dataObj["data"].dictionaryValue
                    print(data)
                    let bioData = data["beer_bio"]?.dictionaryValue
                    let certiLevel = data["certification_level"]?.dictionaryValue
                    let eduData = data["user_education"]?.arrayValue
                    let expData = data["work_experience"]?.arrayValue
                    let intData = data["user_interest"]?.dictionaryValue
                    self.email = data["email"]!.stringValue
                    self.address = data["city"]!.stringValue
                    
                    if bioData!.count > 0 {
                        //Set All Ques & Answers for Beer Bio
                        self.ansArray.removeAll()
                        for i in 1...self.quesArray.count {
                            let ans = bioData!["question_\(i)"]?.stringValue
                            self.ansArray.append(ans!)
                        }
                    }
                    
                    //Set Level Data
                    self.levelArray.removeAll()
                    for (key,val) in certiLevel! {
                        if val.intValue  == 1 {
                            let k = key.replacingOccurrences(of: "_", with: " ")
                            self.levelArray.append(k.capitalized)
                        }
                    }
                    
                    //Set Interest
                    self.interestArray.removeAll()
                    for (key,val) in intData! {
                        if val.intValue == 1 {
                            let k = key.replacingOccurrences(of: "_", with: " ")
                            self.interestArray.append(k.capitalized)
                        }
                    }
                    
                    //Set Education & Exp data
                    self.eduArray = eduData!
                    self.expArray = expData!
                    self.tblResume.reloadData()
                    
                }else{
                    self.showAlert(title: App_Title, msg: responseObject.value(forKeyPath: "message") as! String)
                }
            }
        }
        let failure = {(error: AnyObject) -> Void in
            self.stopAnimating()
            self.showAlert(title: App_Title, msg: WrongMsg)
        }
        service.PostWithAlamofireHeader(Parameters: param as? [String : AnyObject], action: GETMYPROFILEAPI as NSString, success: successed, failure: failure)
    }
    
    //MARK:- Chat
    @IBAction func btnCreateChat(sender: UIButton) {
        let userid = Defaults.value(forKey: "user_id") as! String
        let token = Defaults.value(forKey: "token")as! String
        var providertID = ""
        providertID = self.selectedObj.user_id!
        print(allUserChatListGL.count)
        var obj = allUserChatListGL.filter { (json) -> Bool in
            return json["other_user_id"].stringValue == providertID
        }
        if obj.count == 0 {
            obj = allUserChatListGL.filter { (json) -> Bool in
                return json["chat_created_to"].stringValue == providertID
            }
        }
        if obj.count > 0 {
            let sb = UIStoryboard.init(name: "Provider", bundle: nil)
            let nextVC = sb.instantiateViewController(withIdentifier: "SuperChatViewController")as! SuperChatViewController
            nextVC.userObj = obj[0] //cData
            self.navigationController?.pushViewController(nextVC, animated: true)
        } else {
            if SocketHelper.CheckSocketIsConnectOrNot() {
                //CreateChat Room
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let dt = dateFormatter.string(from: Date())
                let param = ["en":CREATECHAT,"user_id":"\(userid)", "user_token":"\(token)",
                    "other_user_id":"\(providertID)","chat_created_time":dt] as [String : Any]
                SocketHelper.socket.emit("event", with: [param])
            } else {
                SocketHelper.connectSocket()
            }
        }
    }
    
    @objc func createChatResponse(noti: NSNotification) {
        print(noti)
        //Chat Created
        if let dic: NSDictionary = noti.userInfo as NSDictionary? {
            let json = JSON.init(dic)
            let cid = json["chat_id"].stringValue
            chatId = cid
            let sb = UIStoryboard.init(name: "Provider", bundle: nil)
            let contactVC = sb.instantiateViewController(withIdentifier: "SuperChatViewController") as! SuperChatViewController
            contactVC.cid = chatId
            self.navigationController?.pushViewController(contactVC, animated: true)
        }
    }
}

extension ResumeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 111 {
            //Exp
            return self.expArray.count
        } else if tableView.tag == 222 {
            //Edu
            return self.eduArray.count
        }
        return 6
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 111 {
            //Exp Table
            let timeCell = tableView.dequeueReusableCell(withIdentifier: "TimePeriodSubCell") as! TimePeriodSubCell
            if userType == "User" { timeCell.btnEdit.isHidden = false } else { timeCell.btnEdit.isHidden = true }
            let obj = self.expArray[indexPath.row]
            timeCell.lblTitle.text = AppUtilities.sharedInstance.formattedDateFromString(dateString: obj["work_period_from"].stringValue, withFormat: "MMM yyyy")! + " - " + AppUtilities.sharedInstance.formattedDateFromString(dateString: obj["work_period_to"].stringValue, withFormat: "MMM yyyy")!
            timeCell.lblBarName.text = obj["company"].stringValue
            timeCell.lblBarType.text = obj["position"].stringValue
            timeCell.lblDescr.text = obj["jobs_detail"].stringValue
            timeCell.btnEdit.tag = indexPath.row
            timeCell.btnEdit.addTarget(self, action: #selector(self.editWorkClick(sender:)), for: .touchUpInside)
            return timeCell
        } else if tableView.tag == 222 {
            //Edu Table
            let timeCell = tableView.dequeueReusableCell(withIdentifier: "TimePeriodSubCell") as! TimePeriodSubCell
            if userType == "User" { timeCell.btnEdit.isHidden = false } else { timeCell.btnEdit.isHidden = true }
            let obj = self.eduArray[indexPath.row]
            timeCell.lblTitle.text = AppUtilities.sharedInstance.formattedDateFromString(dateString: obj["study_period_from"].stringValue, withFormat: "MMM yyyy")! + " - " + AppUtilities.sharedInstance.formattedDateFromString(dateString: obj["study_period_to"].stringValue, withFormat: "MMM yyyy")!
            timeCell.lblBarName.text = obj["university_name"].stringValue
            timeCell.lblBarType.text = obj["education_type"].stringValue
            timeCell.lblDescr.text = obj["education_detail"].stringValue
            timeCell.btnEdit.tag = indexPath.row
            timeCell.btnEdit.addTarget(self, action: #selector(self.editEducationClick(sender:)), for: .touchUpInside)
            return timeCell
        }
        let profCell = self.tblResume.dequeueReusableCell(withIdentifier: "ProfileCell") as! ProfileCell
        let levelCell = self.tblResume.dequeueReusableCell(withIdentifier: "LevelCell") as! LevelCell
        let expCell = self.tblResume.dequeueReusableCell(withIdentifier: "ExpCell") as! ExpCell
        let beerCell = self.tblResume.dequeueReusableCell(withIdentifier: "BeerBioCell") as! BeerBioCell
        let interestCell = self.tblResume.dequeueReusableCell(withIdentifier: "InterestCell") as! InterestCell
        let eduCell = self.tblResume.dequeueReusableCell(withIdentifier: "EducationCell") as! EducationCell
        if indexPath.row == 0 {
            if userType == "User" {
                let name = Defaults.value(forKey: "user_name") as! String
                let email = Defaults.value(forKey: "user_email") as! String
                if let picUrl: String = Defaults.value(forKey: "profile_pic") as? String, picUrl != "" {
                    profCell.imgProfile.kf.setImage(with: URL(string: picUrl))
                } else {
                    profCell.imgProfile.image = UIImage.init(named: "ios_icon")
                }
                profCell.lblName.text = name
                profCell.lblEmail.text = email
                profCell.btnCity.setTitle(self.address, for: .normal)
            } else {
                let name = self.selectedObj.username
                let email = self.email
                if let picUrl: String = self.selectedObj.profile_pic, picUrl != "" {
                    profCell.imgProfile.kf.setImage(with: URL(string: picUrl))
                } else {
                    profCell.imgProfile.image = UIImage.init(named: "ios_icon")
                }
                profCell.lblName.text = name
                profCell.lblEmail.text = email
                profCell.btnCity.setTitle(self.address, for: .normal)
            }
            return profCell
        } else if indexPath.row == 1 {
            if userType == "User" { levelCell.btnEdit.isHidden = false } else { levelCell.btnEdit.isHidden = true }
            levelCell.btnEdit.addTarget(self, action: #selector(self.updateLevelClick(sender:)), for: .touchUpInside)
            levelCell.levelCollectionView.tag = 101
            levelCell.levelCollectionView.delegate = self
            levelCell.levelCollectionView.dataSource = self
            levelCell.levelCollectionView.reloadData()
            let height = levelCell.levelCollectionView.collectionViewLayout.collectionViewContentSize.height
            levelCell.levelCollectionViewHeight.constant = height
            return levelCell
        } else if indexPath.row == 2 {
            if userType == "User" { expCell.btnAdd.isHidden = false } else { expCell.btnAdd.isHidden = true }
            expCell.btnAdd.addTarget(self, action: #selector(self.addWorkClick(sender:)), for: .touchUpInside)
            expCell.tblExp.delegate = self
            expCell.tblExp.dataSource = self
            expCell.tblExp.tag = 111
            expCell.tblExpHeight.constant = CGFloat(110 * self.expArray.count)
            expCell.tblExp.reloadData()
            return expCell
        } else if indexPath.row == 3 {
            if userType == "User" { beerCell.btnEdit.isHidden = false } else { beerCell.btnEdit.isHidden = true }
            beerCell.btnEdit.addTarget(self, action: #selector(self.updateBioClick(sender:)), for: .touchUpInside)
            beerCell.lblQue1.text = self.quesArray[0]
            beerCell.lblAns1.text = self.ansArray[0]
            beerCell.lblQue2.text = self.quesArray[1]
            beerCell.lblAns2.text = self.ansArray[1]
            beerCell.lblQue3.text = self.quesArray[2]
            beerCell.lblAns3.text = self.ansArray[2]
            beerCell.lblQue4.text = self.quesArray[3]
            beerCell.lblAns4.text = self.ansArray[3]
            beerCell.lblQue5.text = self.quesArray[4]
            beerCell.lblAns5.text = self.ansArray[4]
            beerCell.lblQue6.text = self.quesArray[5]
            beerCell.lblAns6.text = self.ansArray[5]
            beerCell.lblQue7.text = self.quesArray[6]
            beerCell.lblAns7.text = self.ansArray[6]
            beerCell.lblQue8.text = self.quesArray[7]
            beerCell.lblAns8.text = self.ansArray[7]
            beerCell.lblQue9.text = self.quesArray[8]
            beerCell.lblAns9.text = self.ansArray[8]
            beerCell.lblQue10.text = self.quesArray[9]
            beerCell.lblAns10.text = self.ansArray[9]
            beerCell.lblQue11.text = self.quesArray[10]
            beerCell.lblAns11.text = self.ansArray[10]
            beerCell.lblQue12.text = self.quesArray[11]
            beerCell.lblAns12.text = self.ansArray[11]
            beerCell.lblQue13.text = self.quesArray[12]
            beerCell.lblAns13.text = self.ansArray[12]
            return beerCell
        } else if indexPath.row == 4 {
            if userType == "User" { interestCell.btnEdit.isHidden = false } else { interestCell.btnEdit.isHidden = true }
            interestCell.btnEdit.addTarget(self, action: #selector(self.updateInterestClick(sender:)), for: .touchUpInside)
            interestCell.interestCollectionView.tag = 102
            interestCell.interestCollectionView.delegate = self
            interestCell.interestCollectionView.dataSource = self
            interestCell.interestCollectionView.reloadData()
            let height = interestCell.interestCollectionView.collectionViewLayout.collectionViewContentSize.height
            interestCell.interestCollectionViewHeight.constant = height
            return interestCell
        }
        if userType == "User" { eduCell.btnAdd.isHidden = false } else { eduCell.btnAdd.isHidden = true }
        eduCell.btnAdd.addTarget(self, action: #selector(self.addEducationClick(sender:)), for: .touchUpInside)
        eduCell.tblEdu.delegate = self
        eduCell.tblEdu.dataSource = self
        eduCell.tblEdu.tag = 222
        eduCell.tblEduHeight.constant = CGFloat(110 * self.eduArray.count)
        eduCell.tblEdu.reloadData()
        return eduCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 111 {
            return 110
        } else if tableView.tag == 222 {
            return 110
        }
        return UITableView.automaticDimension
    }
}

//MARK:- Collection View Delegate And Data Source
extension ResumeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 102 {
            return self.interestArray.count
        }
        return self.levelArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CertiLevelCell", for: indexPath) as! CertiLevelCell
        if collectionView.tag == 102 {
            cell.lblName.text = self.interestArray[indexPath.row]
        } else {
            cell.lblName.text = self.levelArray[indexPath.row]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var skill = ""
        if collectionView.tag == 102 {
            skill = self.interestArray[indexPath.row]
        } else {
            skill = self.levelArray[indexPath.row]
        }
        let size = skill.size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15)])
        return CGSize.init(width: size.width + 30, height: 30)
    }
}

class FlowLayout: UICollectionViewFlowLayout {
    
    required init(itemSize: CGSize, minimumInteritemSpacing: CGFloat = 0, minimumLineSpacing: CGFloat = 0, sectionInset: UIEdgeInsets = .zero) {
        super.init()
        
        self.itemSize = itemSize
        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.minimumLineSpacing = minimumLineSpacing
        self.sectionInset = sectionInset
        sectionInsetReference = .fromSafeArea
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)!.map { $0.copy() as! UICollectionViewLayoutAttributes }
        guard scrollDirection == .vertical else { return layoutAttributes }
        
        // Filter attributes to compute only cell attributes
        let cellAttributes = layoutAttributes.filter({ $0.representedElementCategory == .cell })
        
        // Group cell attributes by row (cells with same vertical center) and loop on those groups
        for (_, attributes) in Dictionary(grouping: cellAttributes, by: { ($0.center.y / 10).rounded(.up) * 10 }) {
            // Set the initial left inset
            var leftInset = sectionInset.left
            
            // Loop on cells to adjust each cell's origin and prepare leftInset for the next cell
            for attribute in attributes {
                attribute.frame.origin.x = leftInset
                leftInset = attribute.frame.maxX + minimumInteritemSpacing
            }
        }
        
        return layoutAttributes
    }
    
}

extension UILabel {
    public var requiredHeight: CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.attributedText = attributedText
        label.sizeToFit()
        return label.frame.height
    }
}

extension Dictionary where Value: Equatable {
    func getKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}
