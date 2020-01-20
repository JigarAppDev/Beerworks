//
//  AddWebLocationViewController.swift
//  BeerElite
//
//  Created by Jigar on 20/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit

class AddWebLocationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}
