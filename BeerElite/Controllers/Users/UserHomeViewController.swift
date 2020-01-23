//
//  UserHomeViewController.swift
//  BeerElite
//
//  Created by Jigar on 16/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import SideMenu

class tblJobsListCell: UITableViewCell {
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblSubTitle: UILabel!
    @IBOutlet var lblDescr: UILabel!
    @IBOutlet var lblWages: UILabel!
    @IBOutlet var btnChat: UIButton!
}

class UserHomeViewController: UIViewController {

    @IBOutlet var tblJobsList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tblJobsList.estimatedRowHeight = 150
        self.tblJobsList.rowHeight = UITableView.automaticDimension
    }
    
    //MARK: Side menu click
    @IBAction func btnSideMenuClick(sender: UIButton) {
        let menu = storyboard!.instantiateViewController(withIdentifier: "LeftMenu") as! SideMenuNavigationController
        menu.statusBarEndAlpha = 0
        menu.menuWidth = self.view.frame.width - (self.view.frame.width / 3)
        menu.presentationStyle = .menuSlideIn
        present(menu, animated: true, completion: nil)
    }
    
    //MARK: Filter Click
    @IBAction func btnFilterClick(sender: UIButton) {
        let menu = storyboard!.instantiateViewController(withIdentifier: "FilterVC") as! SideMenuNavigationController
        menu.statusBarEndAlpha = 0
        menu.menuWidth = self.view.frame.width - (self.view.frame.width / 3)
        menu.presentationStyle = .menuSlideIn
        present(menu, animated: true, completion: nil)
    }
}

extension UserHomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblJobsList.dequeueReusableCell(withIdentifier: "tblJobsListCell") as! tblJobsListCell
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsVC = self.storyboard?.instantiateViewController(withIdentifier: "JobDetailsViewController") as! JobDetailsViewController
        self.navigationController?.pushViewController(detailsVC, animated: true)
    }
}
