//
//  BeerBioViewController.swift
//  BeerElite
//
//  Created by Jigar on 21/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit

class tblBeerBioCell: UITableViewCell {
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var txtAnswer: UITextField!
}

class BeerBioViewController: UIViewController {
    
    @IBOutlet var tblBeerBio: UITableView!
    var quesArray = ["Tell me about yourself.","Favourite Brewery. Why?","Favourite Beer. Why?","Describe the vibe of your favourite brewery, bar or restaurant.","Outside of work, what type of creative activities do you like to do?","Your thoughts on independent Beer vs Big Beer?","What type of beers would you recommend to someone new to craft beer?","Your thoughts on the Haze Craze?","Describe your favlourite food and beer combo?","What would you do if one of your patrons has clearly had too much to drink?","How many hours are you looking for and what your availability?","Any days/nights you can not work?","Anything you'd like to add?"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tblBeerBio.estimatedRowHeight = 123
        self.tblBeerBio.rowHeight = UITableView.automaticDimension
    }
    
    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension BeerBioViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.quesArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblBeerBio.dequeueReusableCell(withIdentifier: "tblBeerBioCell") as! tblBeerBioCell
        cell.lblTitle.text = self.quesArray[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
