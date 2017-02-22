//
//  TravelogueAuthViewController.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 2/21/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuthUI

class TravelogueAuthViewController: FUIAuthPickerViewController {
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor(red: CGFloat(239)/255, green: CGFloat(91)/255, blue: CGFloat(48)/255, alpha: 1.0)
    }
}
