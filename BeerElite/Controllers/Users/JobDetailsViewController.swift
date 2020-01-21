//
//  JobDetailsViewController.swift
//  BeerElite
//
//  Created by Jigar on 21/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit

class JobDetailsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Chat button click
    @IBAction func btnChatClick(sender: UIButton) {
        let proStoryBoard = UIStoryboard.init(name: "Provider", bundle: nil)
        let chatVC = proStoryBoard.instantiateViewController(identifier: "ChatViewController") as! ChatViewController
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    //MARK: Apply Click
    @IBAction func btnApplyClick(sender: UIButton) {
        let applyVC = self.storyboard?.instantiateViewController(identifier: "ApplyViewController") as! ApplyViewController
        self.navigationController?.pushViewController(applyVC, animated: true)
    }
    
    //MARK: View Company Click
    @IBAction func btnViewCompanyClick(sender: UIButton) {
        let proStoryBoard = UIStoryboard.init(name: "Provider", bundle: nil)
        let compVC = proStoryBoard.instantiateViewController(identifier: "CompanyPageViewController") as! CompanyPageViewController
        self.navigationController?.pushViewController(compVC, animated: true)
    }
}
