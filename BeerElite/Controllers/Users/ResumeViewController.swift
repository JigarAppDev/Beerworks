//
//  ResumeViewController.swift
//  BeerElite
//
//  Created by Jigar on 18/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import SideMenu

class ProfileCell: UITableViewCell {
    
}
class LevelCell: UITableViewCell {
    @IBOutlet var btnEdit: UIButton!
}
class ExpCell: UITableViewCell {
    @IBOutlet var btnAdd: UIButton!
}
class BeerBioCell: UITableViewCell {
    @IBOutlet var btnEdit: UIButton!
}
class InterestCell: UITableViewCell {
    @IBOutlet var btnEdit: UIButton!
}
class EducationCell: UITableViewCell {
    @IBOutlet var btnAdd: UIButton!
}

class ResumeViewController: UIViewController {

    @IBOutlet var tblResume: UITableView!
    @IBOutlet var btnUpdateBio: UIButton!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var btnMenu: UIButton!
    
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
        let levelVC = userStoryBoard.instantiateViewController(identifier: "AddCertiLevelViewController") as! AddCertiLevelViewController
        self.navigationController?.pushViewController(levelVC, animated: true)
    }
    
    @objc func addWorkClick(sender: UIButton) {
        let userStoryBoard = UIStoryboard.init(name: "User", bundle: nil)
        let expVC = userStoryBoard.instantiateViewController(identifier: "AddExperienceViewController") as! AddExperienceViewController
        self.navigationController?.pushViewController(expVC, animated: true)
    }
    
    @objc func updateBioClick(sender: UIButton) {
        let userStoryBoard = UIStoryboard.init(name: "User", bundle: nil)
        let bioVC = userStoryBoard.instantiateViewController(identifier: "BeerBioViewController") as! BeerBioViewController
        self.navigationController?.pushViewController(bioVC, animated: true)
    }
    
    @objc func updateInterestClick(sender: UIButton) {
        let userStoryBoard = UIStoryboard.init(name: "User", bundle: nil)
        let interestVC = userStoryBoard.instantiateViewController(identifier: "AddInterestViewController") as! AddInterestViewController
        self.navigationController?.pushViewController(interestVC, animated: true)
    }
    
    @objc func addEducationClick(sender: UIButton) {
        let userStoryBoard = UIStoryboard.init(name: "User", bundle: nil)
        let eduVC = userStoryBoard.instantiateViewController(identifier: "AddEducationViewController") as! AddEducationViewController
        self.navigationController?.pushViewController(eduVC, animated: true)
    }
}

extension ResumeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let profCell = self.tblResume.dequeueReusableCell(withIdentifier: "ProfileCell") as! ProfileCell
        let levelCell = self.tblResume.dequeueReusableCell(withIdentifier: "LevelCell") as! LevelCell
        let expCell = self.tblResume.dequeueReusableCell(withIdentifier: "ExpCell") as! ExpCell
        let beerCell = self.tblResume.dequeueReusableCell(withIdentifier: "BeerBioCell") as! BeerBioCell
        let interestCell = self.tblResume.dequeueReusableCell(withIdentifier: "InterestCell") as! InterestCell
        let eduCell = self.tblResume.dequeueReusableCell(withIdentifier: "EducationCell") as! EducationCell
        if indexPath.row == 0 {
            return profCell
        } else if indexPath.row == 1 {
            if userType == "User" { levelCell.btnEdit.isHidden = false } else { levelCell.btnEdit.isHidden = true }
            levelCell.btnEdit.addTarget(self, action: #selector(self.updateLevelClick(sender:)), for: .touchUpInside)
            return levelCell
        } else if indexPath.row == 2 {
            if userType == "User" { expCell.btnAdd.isHidden = false } else { expCell.btnAdd.isHidden = true }
            expCell.btnAdd.addTarget(self, action: #selector(self.addWorkClick(sender:)), for: .touchUpInside)
            return expCell
        } else if indexPath.row == 3 {
            if userType == "User" { beerCell.btnEdit.isHidden = false } else { beerCell.btnEdit.isHidden = true }
            beerCell.btnEdit.addTarget(self, action: #selector(self.updateBioClick(sender:)), for: .touchUpInside)
            return beerCell
        } else if indexPath.row == 4 {
            if userType == "User" { interestCell.btnEdit.isHidden = false } else { interestCell.btnEdit.isHidden = true }
            interestCell.btnEdit.addTarget(self, action: #selector(self.updateInterestClick(sender:)), for: .touchUpInside)
            return interestCell
        }
        if userType == "User" { eduCell.btnAdd.isHidden = false } else { eduCell.btnAdd.isHidden = true }
        eduCell.btnAdd.addTarget(self, action: #selector(self.addEducationClick(sender:)), for: .touchUpInside)
        return eduCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
