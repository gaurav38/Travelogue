//
//  TripVisit+CoreDataClass.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 3/9/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import Foundation
import CoreData


public class TripVisit: NSManagedObject {

    convenience init(id: String, place: String, startTime: String, endTime: String, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "TripVisit", in: context) {
            self.init(entity: ent, insertInto: context)
            self.id = id
            self.place = place
            self.startTime = startTime
            self.endTime = endTime
        } else {
            fatalError("Unable to find Entity name TripVisit!")
        }
    }
}
