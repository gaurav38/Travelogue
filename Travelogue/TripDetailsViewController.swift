//
//  TripDetailsViewController.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 3/6/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TripDetailsViewController: CoreDataTableViewController {
    
    var trip: Trip?
    var dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "MMM dd, yyyy"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.title = trip?.name ?? ""
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Find the notebook
        let tripDay = fetchedResultsController!.object(at: indexPath) as! TripDay
        
        // Create the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripDayCell", for: indexPath)
        
        // Sync tripDay -> cell
        print(tripDay.location!)
        print(tripDay.date!)
        cell.textLabel?.text = tripDay.location!
        cell.detailTextLabel?.text = dateFormatter.string(from: tripDay.date! as Date)
        
        return cell
    }
}
