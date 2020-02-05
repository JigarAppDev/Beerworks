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

        //Checked for already login user with type of user
        let isLoggedIn = Defaults.bool(forKey: "is_logged_in")
        if isLoggedIn {
            //Navigate to home
            let uType = Defaults.value(forKey: "user_type") as! String //user_type = 1 = user , 2 = provider
            if uType == "1" {
                userType = "User"
                let userStoryBoard = UIStoryboard.init(name: "User", bundle: nil)
                let userHomeVC = userStoryBoard.instantiateViewController(withIdentifier: "UserHomeViewController") as! UserHomeViewController
                self.navigationController?.pushViewController(userHomeVC, animated: true)
            } else {
                userType = "Provider"
                let proStoryBoard = UIStoryboard.init(name: "Provider", bundle: nil)
                let proHomeVC = proStoryBoard.instantiateViewController(withIdentifier: "ProviderHomeViewController") as! ProviderHomeViewController
                self.navigationController?.pushViewController(proHomeVC, animated: true)
            }
        }
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
        let onboradVC = self.storyboard?.instantiateViewController(withIdentifier: "OnBoardingViewController") as! OnBoardingViewController
        self.navigationController?.pushViewController(onboradVC, animated: true)
    }

}
