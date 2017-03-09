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
    
    fileprivate var ref: FIRDatabaseReference!
    fileprivate let dateFormatter = DateFormatter()
    
    init() {
        dateFormatter.dateFormat = "MMM d, yyyy"
    }
    
    func configure(ref: FIRDatabaseReference) {
        self.ref = ref
    }
    
    func save(dataContainer: NewTripDataContainer) {
        save(trip: dataContainer.trip!)
        
        if dataContainer.tripDays.count > 0 {
            save(tripDays: dataContainer.tripDays)
        }
        
        if dataContainer.tripVisits.count > 0 {
            save(tripVisits: dataContainer.tripVisits)
        }
    }
    
    fileprivate func save(trip: Trip) {
        let startDateMillis = Int(((dateFormatter.date(from: trip.startDate!)?.timeIntervalSince1970)! * 1000).rounded())
        var mdata = [String: AnyObject]()
        mdata["id"] = trip.id! as AnyObject
        mdata["name"] = trip.name! as AnyObject
        mdata["startDate"] = trip.startDate! as AnyObject
        mdata["endDate"] = trip.endDate! as AnyObject
        mdata["createdByUsername"] = trip.createdByUsername! as AnyObject
        mdata["createdByUseremail"] = trip.createByUseremail! as AnyObject
        mdata["startDateMillis"] = startDateMillis as AnyObject
        
        var dataForFirebase = [String: AnyObject]()
        dataForFirebase[trip.id!] = mdata as AnyObject?
        print(dataForFirebase)
        ref.child("trips").childByAutoId().setValue(dataForFirebase)
    }
    
    fileprivate func save(tripDays: [TripDay]) {
        for tripDay in tripDays {
            let tripId = tripDay.trip?.id!
            var mdata = [String: String]()
            mdata["id"] = tripDay.id!
            mdata["date"] = tripDay.date!
            ref.child("trip_days").child(tripId!).child(tripDay.id!).setValue(mdata)
        }
    }
    
    fileprivate func save(tripVisits: [TripVisit]) {
        for tripVisit in tripVisits {
            let tripDayId = tripVisit.tripDay!.id!
            let tripVisitId = tripVisit.id!
            
            var mdata = [String: String]()
            mdata["id"] = tripVisitId
            mdata["location"] = tripVisit.tripDay!.location!
            mdata["place"] = tripVisit.place!
            mdata["startTime"] = tripVisit.startTime ?? ""
            mdata["endTime"] = tripVisit.endTime ?? ""
            ref.child("trip_visits").child(tripDayId).child(tripVisitId).setValue(mdata)
        }
    }
}
