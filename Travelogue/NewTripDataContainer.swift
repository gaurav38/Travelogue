//
//  NewTripDataContainer.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 2/26/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import Foundation

class NewTripDataContainer {
    static let instance = NewTripDataContainer()
    
    // These will be used to do some fancy UI work
    var selectedDates = [String]()
    var selectedLocations = [String]()
    
    // These will hold references to all the models created and will be used to sync new trip to Firebase at the end
    var trip: Trip?
    var tripDays = [TripDay]()
    var tripVisits = [TripVisit]()
    
    func reset() {
        trip = nil
        tripDays.removeAll()
        tripVisits.removeAll()
    }
}
