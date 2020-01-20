//
//  FilterViewController.swift
//  BeerElite
//
//  Created by Jigar on 16/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import SideMenu

class FilterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: Close Button Click
    @IBAction func btnCloseClick(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
