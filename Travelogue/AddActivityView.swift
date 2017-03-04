//
//  AddActivityView.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 3/4/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import UIKit

@IBDesignable class AddActivityView: UIView {

    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var activityTextField: BetterTextField!
    // MARK: - Initializers
    
    // MARK: init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if self.subviews.count == 0 {
            setup()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        if let view = Bundle.main.loadNibNamed("AddActivityView", owner: self, options: nil)?.first as? AddActivityView {
            view.frame = bounds
            view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
            
            addSubview(view)
        }
    }

}
