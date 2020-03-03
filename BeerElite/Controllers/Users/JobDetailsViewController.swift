//
//  JobDetailsViewController.swift
//  BeerElite
//
//  Created by Jigar on 21/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import SwiftyJSON

class JobDetailsViewController: UIViewController {

    @IBOutlet var imgBar: UIImageView!
    @IBOutlet var lblBarName: UILabel!
    @IBOutlet var lblSubName: UILabel!
    @IBOutlet var lblSalary: UILabel!
    @IBOutlet var lblDescr: UILabel!
    
    var dataObj: JobsDataModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupData()
    }
    
    func setupData() {
        if self.dataObj.profile_pic == "" {
            self.imgBar.image = UIImage.init(named: "ios_icon")
        } else {
            self.imgBar.kf.setImage(with: URL(string: self.dataObj.profile_pic!))
        }
        self.lblBarName.text = self.dataObj.jobTitle
        self.lblDescr.text = self.dataObj.description
        self.lblSubName.text = self.dataObj.company_name
        self.lblSalary.text = "Salary/hourly wage " + self.dataObj.salary!
    }

    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Chat button click
    @IBAction func btnChatClick(sender: UIButton) {
        let proStoryBoard = UIStoryboard.init(name: "Provider", bundle: nil)
        let chatVC = proStoryBoard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    //MARK: Apply Click
    @IBAction func btnApplyClick(sender: UIButton) {
        let applyVC = self.storyboard?.instantiateViewController(withIdentifier: "ApplyViewController") as! ApplyViewController
        applyVC.dataObj = self.dataObj
        self.navigationController?.pushViewController(applyVC, animated: true)
    }
    
    //MARK: View Company Click
    @IBAction func btnViewCompanyClick(sender: UIButton) {
        let proStoryBoard = UIStoryboard.init(name: "Provider", bundle: nil)
        let compVC = proStoryBoard.instantiateViewController(withIdentifier: "CompanyPageViewController") as! CompanyPageViewController
        compVC.companyId = self.dataObj.company_id!
        self.navigationController?.pushViewController(compVC, animated: true)
    }
}
