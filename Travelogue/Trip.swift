//
//  Trip+CoreDataClass.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 3/12/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import Foundation
import CoreData


public class Trip: NSManagedObject {

    convenience init(tripId: String, tripName: String, userName: String, userEmail: String, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "Trip", in: context) {
            self.init(entity: ent, insertInto: context)
            self.id = tripId
            self.name = tripName
            self.createdByUsername = userName
            self.createByUseremail = userEmail
        } else {
            fatalError("Unable to find Entity name Trip!")
        }
    }
}
