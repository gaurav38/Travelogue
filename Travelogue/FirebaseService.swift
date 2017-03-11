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
    
    func save(dataContainer: NewTripDataContainer) {
        save(trip: dataContainer.trip!)
        
        if dataContainer.tripDays.count > 0 {
            save(tripDays: dataContainer.tripDays)
        }
        
        if dataContainer.tripVisits.count > 0 {
            save(tripVisits: dataContainer.tripVisits)
        }
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
        ref.child("trips").observe(.childAdded) { (snapshot: FIRDataSnapshot) in
            let tripDict = snapshot.value as! [String: AnyObject]
            
            if tripDict.keys.first == tripId {
                print(tripDict)
                let trip = tripDict.values.first as! [String: AnyObject]
                print(trip)
                print(snapshot.key)
                self.ref.child(FirebaseService.TRIPS_NODE).child(snapshot.key).child(tripId).child("startDate").setValue(self.dateFormatter.string(from: startDate))
            }
        }
    }
    
    func updateTripEndDate(for tripId: String, endDate: Date) {
        ref.child("trips").observe(.childAdded) { (snapshot: FIRDataSnapshot) in
            let tripDict = snapshot.value as! [String: AnyObject]
            
            if tripDict.keys.first == tripId {
                print(tripDict)
                let trip = tripDict.values.first as! [String: AnyObject]
                print(trip)
                self.ref.child(FirebaseService.TRIPS_NODE).child(snapshot.key).child(tripId).child("endDate").setValue(self.dateFormatter.string(from: endDate))
            }
        }
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
    
    fileprivate func save(trip: Trip) {
        var mdata = [String: AnyObject]()
        mdata["id"] = trip.id! as AnyObject
        mdata["name"] = trip.name! as AnyObject
        if let startDate = trip.startDate {
            mdata["startDate"] = dateFormatter.string(from: startDate as Date) as AnyObject
            let startDateMillis = Int((trip.startDate!.timeIntervalSince1970 * 1000).rounded())
            mdata["startDateMillis"] = startDateMillis as AnyObject
        } else {
            mdata["startDate"] = "" as AnyObject
        }
        if let endDate = trip.endDate {
            mdata["endDate"] = dateFormatter.string(from: endDate as Date) as AnyObject
        } else {
            mdata["endDate"] = "" as AnyObject
        }
        mdata["createdByUsername"] = trip.createdByUsername! as AnyObject
        mdata["createdByUseremail"] = trip.createByUseremail! as AnyObject
        
        var dataForFirebase = [String: AnyObject]()
        dataForFirebase[trip.id!] = mdata as AnyObject?
        ref.child("trips").childByAutoId().setValue(dataForFirebase)
    }
    
    fileprivate func save(tripDays: [TripDay]) {
        for tripDay in tripDays {
            let tripId = tripDay.trip?.id!
            var mdata = [String: String]()
            mdata["id"] = tripDay.id!
            mdata["date"] = dateFormatter.string(from: tripDay.date! as Date)
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
