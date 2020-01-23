//
//  CompanyPageViewController.swift
//  BeerElite
//
//  Created by Jigar on 18/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit

class CompanyPageViewController: UIViewController {

    @IBOutlet var btnUpdateInfo: UIButton!
    @IBOutlet var btnUpdateAbout: UIButton!
    @IBOutlet var btnUpdateAddress: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if userType == "User" {
            self.btnUpdateInfo.isHidden = true
            self.btnUpdateAbout.isHidden = true
            self.btnUpdateAddress.isHidden = true
        } else {
            self.btnUpdateInfo.isHidden = false
            self.btnUpdateAbout.isHidden = false
            self.btnUpdateAddress.isHidden = false
        }
    }
    
    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    //MARK: Edit Company Info
    @IBAction func btnAddAboutUs(sender: UIButton) {
        let aboutVC = self.storyboard?.instantiateViewController(withIdentifier: "AddAboutCompanyViewController") as! AddAboutCompanyViewController
        self.navigationController?.pushViewController(aboutVC, animated: true)
    }
    
    //MARK: Edit Location & URL
    @IBAction func btnEditWebLocation(sender: UIButton) {
        let webVC = self.storyboard?.instantiateViewController(withIdentifier: "AddWebLocationViewController") as! AddWebLocationViewController
        self.navigationController?.pushViewController(webVC, animated: true)
    }
}
