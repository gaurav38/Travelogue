//
//  TripActivity.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 3/4/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import Foundation

class TripActivity {
    var activityId: String!
    var activityTime: String!
    var activityDescription: String!
    
    init(time: String, description: String) {
        self.activityTime = time
        self.activityDescription = description
        self.activityId = "ACTIVITY1234567890"
    }
}
