//
//  TripDay.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 3/5/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import Foundation
import CoreData


public class TripDay: NSManagedObject {

    convenience init(dayId: String, date: String, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "TripDay", in: context) {
            self.init(entity: ent, insertInto: context)
            self.id = dayId
            self.date = date
        } else {
            fatalError("Unable to find Entity name TripDay!")
        }
    }
}
