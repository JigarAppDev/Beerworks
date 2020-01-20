//
//  UserSelectionViewController.swift
//  BeerElite
//
//  Created by Jigar on 13/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit

class UserSelectionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: Select Type
    @IBAction func btnSelectUser(sender: UIButton) {
        if sender.tag == 101 {
            //User
            userType = "User"
        } else {
            //Employer
            userType = "Provider"
        }
        let onboradVC = self.storyboard?.instantiateViewController(identifier: "OnBoardingViewController") as! OnBoardingViewController
        self.navigationController?.pushViewController(onboradVC, animated: true)
    }

}
