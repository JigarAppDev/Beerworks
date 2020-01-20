//
//  CompanyPageViewController.swift
//  BeerElite
//
//  Created by Jigar on 18/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit

class CompanyPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    //MARK: Edit Company Info
    @IBAction func btnAddAboutUs(sender: UIButton) {
        let aboutVC = self.storyboard?.instantiateViewController(identifier: "AddAboutCompanyViewController") as! AddAboutCompanyViewController
        self.navigationController?.pushViewController(aboutVC, animated: true)
    }
    
    //MARK: Edit Location & URL
    @IBAction func btnEditWebLocation(sender: UIButton) {
        let webVC = self.storyboard?.instantiateViewController(identifier: "AddWebLocationViewController") as! AddWebLocationViewController
        self.navigationController?.pushViewController(webVC, animated: true)
    }
}
