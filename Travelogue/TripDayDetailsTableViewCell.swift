//
//  TripDayDetailsTableViewCell.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 3/11/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import UIKit

class TripDayDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
