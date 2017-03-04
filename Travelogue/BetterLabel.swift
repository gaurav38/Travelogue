//
//  BetterLabel.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 2/28/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import Foundation
import UIKit

class BetterLabel: UILabel {
    let padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10);
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, padding))
    }
}
