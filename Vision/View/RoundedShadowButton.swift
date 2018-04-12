//
//  RoundedShadowButton.swift
//  Vision
//
//  Created by Marlon Avery on 4/5/18.
//  Copyright © 2018 Marlon Avery. All rights reserved.
//

import UIKit

class RoundedShadowButton: UIButton {
    
    override func awakeFromNib() {
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.75
        self.layer.cornerRadius = self.layer.frame.height / 2
    }
    
}
