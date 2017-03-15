//
//  FavoriteTripsViewController.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 3/12/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import UIKit
import CoreData

class FavoriteTripsViewController: CoreDataTableViewController {

    fileprivate let dateFormatter = DateFormatter()
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        tableView.delegate = self
        tableView.dataSource = self
        
        // Get the Stack
        let stack = delegate.stack

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Trip")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true), NSSortDescriptor(key: "startDate", ascending: false)]
        
        // Create the FetchResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowFavoriteTripDetails" {
            let tripDetailsViewController = segue.destination as! TripDetailsViewController
            
            let indexPath = tableView.indexPathForSelectedRow!
            let trip = fetchedResultsController?.object(at: indexPath) as! Trip
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TripDay")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
            
            let predicate = NSPredicate(format: "trip = %@", trip)
            fetchRequest.predicate = predicate
            
            // Create the FetchResultsController
            let fc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: delegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
            
            tripDetailsViewController.isOfflineTrip = true
            tripDetailsViewController.tripName = trip.name!
            tripDetailsViewController.fetchedResultsController = fc
        }
    }
}

extension FavoriteTripsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let trip = fetchedResultsController?.object(at: indexPath) as! Trip
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteTripCell")!
        cell.textLabel?.text = trip.name!
        
        if let startDate = trip.startDate {
            if let endDate = trip.endDate {
                cell.detailTextLabel?.text = "\(dateFormatter.string(from: startDate as Date)) - \(dateFormatter.string(from: endDate as Date))"
            } else {
                cell.detailTextLabel?.text = "\(dateFormatter.string(from: startDate as Date))"
            }
        }
        return cell
    }
}
