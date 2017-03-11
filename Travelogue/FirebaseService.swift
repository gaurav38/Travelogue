//
//  FirebaseService.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 3/7/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import Foundation
import Firebase

class FirebaseService {
    
    static let instance = FirebaseService()
    static let TRIPS_NODE = "trips"
    static let TRIPDAYS_NODE = "trip_days"
    static let TRIPVISITS_NODE = "trip_visits"
    
    fileprivate var ref: FIRDatabaseReference!
    fileprivate let dateFormatter = DateFormatter()
    fileprivate let timeFormatter = DateFormatter()
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    init() {
        dateFormatter.dateFormat = "MMM d, yyyy"
        timeFormatter.dateFormat = "h:mm a"
    }
    
    func configure(ref: FIRDatabaseReference) {
        self.ref = ref
    }
    
    func createTrip(id : String, name: String) {
        let mdata = ["id" : id,
                     "name" : name,
                     "createdByUsername" : delegate.user?.displayName ?? "",
                     "createdByUseremail" : delegate.user?.email ?? "",
                     "startDate" : "",
                     "endDate" : ""]
        ref.child(FirebaseService.TRIPS_NODE).child((delegate.user?.uid)!).child(id).setValue(mdata);
        print("Trip added: \(id)")
    }
    
    func updateTripStartDate(for tripId: String, startDate: Date) {
        ref.child("trips").child((delegate.user?.uid)!).child(tripId).child("startDate").setValue(dateFormatter.string(from: startDate))
    }
    
    func updateTripEndDate(for tripId: String, endDate: Date) {
        ref.child("trips").child((delegate.user?.uid)!).child(tripId).child("endDate").setValue(dateFormatter.string(from: endDate))
    }
    
    func createTripDay(for trip: String, id: String, location: String, date: Date) {
        let mdata = ["id" : id,
                     "date" : dateFormatter.string(from: date),
                     "location" : location]
        ref.child(FirebaseService.TRIPDAYS_NODE).child(trip).child(id).setValue(mdata)
    }
    
    func updateTripDayLocation(for trip: String, tripDayId: String, location: String) {
        ref.child(FirebaseService.TRIPDAYS_NODE).child(trip).child(tripDayId).child("location").setValue(location)
    }
    
    func createTripDayVisit(for tripDay: String, id: String, location: String, place: String, startTime: Date, endTime: Date) {
        let mdata = ["id" : id,
                     "location" : location,
                     "place" : place,
                     "startTime" : timeFormatter.string(from: startTime),
                     "endTime" : timeFormatter.string(from: endTime)]
        ref.child(FirebaseService.TRIPVISITS_NODE).child(tripDay).child(id).setValue(mdata)
    }
}
