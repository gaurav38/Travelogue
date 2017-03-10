//
//  Trip+CoreDataProperties.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 3/9/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import Foundation
import CoreData


extension Trip {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Trip> {
        return NSFetchRequest<Trip>(entityName: "Trip");
    }

    @NSManaged public var createByUseremail: String?
    @NSManaged public var createdByUsername: String?
    @NSManaged public var duration: Int16
    @NSManaged public var endDate: NSDate?
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var startDate: NSDate?
    @NSManaged public var tripDay: NSSet?

}

// MARK: Generated accessors for tripDay
extension Trip {

    @objc(addTripDayObject:)
    @NSManaged public func addToTripDay(_ value: TripDay)

    @objc(removeTripDayObject:)
    @NSManaged public func removeFromTripDay(_ value: TripDay)

    @objc(addTripDay:)
    @NSManaged public func addToTripDay(_ values: NSSet)

    @objc(removeTripDay:)
    @NSManaged public func removeFromTripDay(_ values: NSSet)

}
