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
    
    override init(nibName: String?, bundle: Bundle?, authUI: FUIAuth) {
        super.init(nibName: "FUIAuthPickerViewController", bundle: bundle, authUI: authUI)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: CGFloat(239)/255, green: CGFloat(91)/255, blue: CGFloat(48)/255, alpha: 1.0)
    }
    
    override func cancelAuthorization() {
        super.cancelAuthorization()
    }
}
