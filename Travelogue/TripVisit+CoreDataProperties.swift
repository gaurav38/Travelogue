//
//  TripVisit+CoreDataProperties.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 3/12/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import Foundation
import CoreData


extension TripVisit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TripVisit> {
        return NSFetchRequest<TripVisit>(entityName: "TripVisit");
    }

    @NSManaged public var endTime: String?
    @NSManaged public var id: String?
    @NSManaged public var place: String?
    @NSManaged public var startTime: String?
    @NSManaged public var location: String?
    @NSManaged public var photoUrl: String?
    @NSManaged public var photo: NSData?
    @NSManaged public var tripDay: TripDay?

}
