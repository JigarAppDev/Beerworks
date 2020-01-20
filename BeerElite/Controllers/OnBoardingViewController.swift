//
//  OnBoardingViewController.swift
//  BeerElite
//
//  Created by Jigar on 13/01/20.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit

class SliderCollectionCell: UICollectionViewCell {
    @IBOutlet var lblSteps: UILabel!
    @IBOutlet var lblSteps2: UILabel!
    @IBOutlet var lblStepsText: UILabel!
    @IBOutlet var sliderImage: UIImageView!
    @IBOutlet var btnSetWakeSleepTime: UIButton!
    @IBOutlet var viewTopGestureLayer: UIView!
}

class OnBoardingViewController: UIViewController {

    @IBOutlet var sliderCollection: UICollectionView!
    @IBOutlet var pagerConrol: UIPageControl!
    @IBOutlet var btnNext: UIButton!
    
    var selectedIndex = 0
    var titleArray = ["Create your profile","Search craft beer jobs","Let employers find you"]
    var textArray = ["You're commited to your craft. We're commited to finding you the best jobs in the industry. Complete your Beer Elite profile and interview to begin!","Browse local craft beer postings and have new jobs delivered straight to your inbox.","Don't see you're favorite brewery? Don't worry, they can see you! Employers browse Beer Elite profile daily!"]
    var lastContentOffset: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if userType == "Provider" {
            self.titleArray = ["Unlimited job postings","Find Talent","Connect and hire"]
            self.textArray = ["Post jobs for hundreds of local craft beer professionals.","Beer elite profiles offer insight on beer knowledge and personality.","Instantly connect with candidates through messaging and live chat."]
        }
    }

    //MARK:- Skip button click
    @IBAction func skipClick(sender: UIButton) {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    //MARK:- Next button click
    @IBAction func nextClick(sender: UIButton) {
        if self.selectedIndex < 2 {
            self.selectedIndex = self.selectedIndex + 1
            self.sliderCollection.selectItem(at: IndexPath(item: self.selectedIndex, section: 0), animated: true, scrollPosition: .centeredHorizontally)
            self.pagerConrol.currentPage = self.selectedIndex
        } else {
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.navigationController?.pushViewController(loginVC, animated: true)
        }
    }
}

//MARK:- Slider Collection Delegate and Datasource Methods
extension OnBoardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.titleArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.sliderCollection.dequeueReusableCell(withReuseIdentifier: "SliderCollectionCell", for: indexPath) as! SliderCollectionCell
        cell.lblSteps.text = self.titleArray[indexPath.row].capitalized
        cell.sliderImage.image = UIImage.init(named: "get_in_started\(indexPath.row)")
        cell.lblStepsText.text = self.textArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.sliderCollection.frame.width , height: self.sliderCollection.frame.height)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        if translation.x > 0 {
            // swipes from left to right
            if self.selectedIndex == 0 {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            // swipes from Right to left
            if self.selectedIndex == 2 {
                let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.navigationController?.pushViewController(loginVC, animated: true)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let center = CGPoint(x: scrollView.contentOffset.x + (scrollView.frame.width / 2), y: (scrollView.frame.height / 2))
        if let ip = self.sliderCollection.indexPathForItem(at: center) {
            self.selectedIndex = ip.row
            self.pagerConrol.currentPage = ip.row
        }
    }
    
}
