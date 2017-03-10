//
//  TripDay+CoreDataProperties.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 3/9/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import Foundation
import CoreData


extension TripDay {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TripDay> {
        return NSFetchRequest<TripDay>(entityName: "TripDay");
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var id: String?
    @NSManaged public var location: String?
    @NSManaged public var trip: Trip?
    @NSManaged public var tripVisits: NSSet?

}

// MARK: Generated accessors for tripVisits
extension TripDay {

    @objc(addTripVisitsObject:)
    @NSManaged public func addToTripVisits(_ value: TripVisit)

    @objc(removeTripVisitsObject:)
    @NSManaged public func removeFromTripVisits(_ value: TripVisit)

    @objc(addTripVisits:)
    @NSManaged public func addToTripVisits(_ values: NSSet)

    @objc(removeTripVisits:)
    @NSManaged public func removeFromTripVisits(_ values: NSSet)

}
