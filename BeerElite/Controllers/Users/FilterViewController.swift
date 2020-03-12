//
//  FilterViewController.swift
//  BeerElite
//
//  Created by Jigar on 16/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import SideMenu
import fluid_slider

class FilterViewController: UIViewController {

    @IBOutlet var slider: Slider!
    var selectedValue = "50"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupFilterUI()
    }
    
    //MARK: Setup Filter UI
    func setupFilterUI() {
        slider.attributedTextForFraction = { fraction in
            let formatter = NumberFormatter()
            formatter.maximumIntegerDigits = 3
            formatter.maximumFractionDigits = 0
            let string = formatter.string(from: (fraction * 100) as NSNumber) ?? ""
            return NSAttributedString(string: string)
        }
        /*slider.didBeginTracking = { [weak self] _ in
            
        }
        slider.didEndTracking = { [weak self] _ in
            
        }*/
        slider.setMinimumLabelAttributedText(NSAttributedString(string: "0"))
        slider.setMaximumLabelAttributedText(NSAttributedString(string: "100"))
        slider.fraction = 0.5
        slider.shadowOffset = CGSize(width: 0, height: 10)
        slider.shadowBlur = 5
        slider.shadowColor = UIColor(white: 0, alpha: 0.1)
        slider.contentViewColor = UIColor(red: 223/255.0, green: 167/255.0, blue: 72/255.0, alpha: 1)
        slider.valueViewColor = .white
        slider.addTarget(self, action: #selector(sliderValueChanged(sender:)), for: .valueChanged)
    }
    
    @objc func sliderValueChanged(sender: Slider) {
        let formatter = NumberFormatter()
        formatter.maximumIntegerDigits = 3
        formatter.maximumFractionDigits = 0
        self.selectedValue = formatter.string(from: (slider.fraction * 100) as NSNumber) ?? ""
        filterDistance = self.selectedValue
    }
    
    //MARK: Close Button Click
    @IBAction func btnCloseClick(sender: UIButton) {
        IsJobFilter = false
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Apply Filter
    @IBAction func btnApplyFilter(sender: UIButton) {
        if IsJobFilter {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GetJobsByFilter"), object: nil)
            dismiss(animated: true, completion: nil)
        }
    }

}
