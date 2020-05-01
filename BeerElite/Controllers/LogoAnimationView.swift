//
//  LogoAnimationView.swift
//  AnimatedGif
//
//  Created by Jigar.
//  Copyright © 2020 Jigar. All rights reserved.
//

import UIKit
import SwiftyGif

class LogoAnimationView: UIView {
    
    let logoGifImageView: UIImageView = {
        guard let gifImage = try? UIImage(gifName: "newgiflogo.gif") else {
            return UIImageView()
        }
        return UIImageView(gifImage: gifImage, loopCount: 2)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = UIColor.clear //(white: 246.0 / 255.0, alpha: 1)
        addSubview(logoGifImageView)
        logoGifImageView.translatesAutoresizingMaskIntoConstraints = false
        logoGifImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        logoGifImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        logoGifImageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        logoGifImageView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
    }
}
