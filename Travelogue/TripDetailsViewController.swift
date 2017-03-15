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
import Firebase
import ReachabilitySwift

class TripDetailsViewController: UIViewController {
    
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripDaysTableView: UITableView!
    @IBOutlet weak var loadingIndicatorView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    
    // These properties will be injected by the parent VC
    var tripId: String!
    var tripName: String!
    var tripDays: [FIRDataSnapshot]! = []
    
    // These properties will be used to reuse this VC for offline trips.
    var isOfflineTrip: Bool?
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    fileprivate let dateFormatter = DateFormatter()
    var delegate = UIApplication.shared.delegate as! AppDelegate
    let firebaseService = FirebaseService.instance
    let reachability = Reachability()!
    var ref: FIRDatabaseReference!
    fileprivate var _refHandle: FIRDatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        if isOfflineTrip == nil {
            configureDatabase()
            loadingIndicatorView.isHidden = false
            loadingIndicator.startAnimating()
        } else if let fc = fetchedResultsController {
            loadingIndicatorView.isHidden = true
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
        reachability.whenUnreachable = { reachability in
            DispatchQueue.main.async {
                self.showErrorToUser(title: "No internet!", message: "You are offline.")
                self.loadingIndicatorView.isHidden = true
            }
        }
    }
    
    func configureUI() {
        tripNameLabel.text = tripName
        tripDaysTableView.delegate = self
        tripDaysTableView.dataSource = self
        dateFormatter.dateFormat = "MMM dd, yyyy"
    }
    
    func configureDatabase() {
        ref.child("trip_days").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            if snapshot.hasChild(self.tripId) {
                self.emptyStateLabel.isHidden = true
            } else {
                self.emptyStateLabel.isHidden = false
                self.loadingIndicatorView.isHidden = true
                self.loadingIndicator.stopAnimating()
            }
        }
        _refHandle = ref.child("trip_days").child(tripId).observe(.childAdded) { (snapshot: FIRDataSnapshot) in
            self.emptyStateLabel.isHidden = true
            self.tripDays.append(snapshot)
            self.tripDaysTableView.insertRows(at: [IndexPath(row: self.tripDays.count - 1, section: 0)], with: .automatic)
        }
    }
    
    deinit {
        ref.child("trip_days").removeObserver(withHandle: _refHandle!)
        reachability.stopNotifier()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTripDayDetails" {
            let tripDayDetailsViewController = segue.destination as! TripDayDetailsViewController
            let indexPath = tripDaysTableView.indexPathForSelectedRow!
            
            if isOfflineTrip == nil {
                let selectedTripDay = tripDays[indexPath.row].value as! [String: String]
                tripDayDetailsViewController.tripDayId = selectedTripDay["id"]
                tripDayDetailsViewController.tripDayDate = selectedTripDay["date"]
                tripDayDetailsViewController.tripDayLocation = selectedTripDay["location"]
                tripDayDetailsViewController.ref = ref
            } else if let fc = fetchedResultsController {
                let tripDay = fc.object(at: indexPath) as! TripDay
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TripVisit")
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
                
                let predicate = NSPredicate(format: "tripDay = %@", tripDay)
                fetchRequest.predicate = predicate
                
                let fc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: delegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
                tripDayDetailsViewController.tripDayDate = dateFormatter.string(from: tripDay.date! as Date)
                tripDayDetailsViewController.tripDayLocation = tripDay.location ?? ""
                tripDayDetailsViewController.isOfflineTrip = true
                tripDayDetailsViewController.fetchedResultsController = fc
            }
        }
    }
}

extension TripDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isOfflineTrip == nil {
            return tripDays.count
        } else if let fc = fetchedResultsController {
            return fc.sections![section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tripDaysTableView.dequeueReusableCell(withIdentifier: "TripDayCell", for: indexPath)
        
        if isOfflineTrip == nil {
            loadingIndicatorView.isHidden = true
            let tripDay = tripDays[indexPath.row].value as! [String: String]
            
            if let location = tripDay["location"] {
                cell.textLabel?.text = location
                cell.detailTextLabel?.text = tripDay["date"]
            } else {
                cell.textLabel?.text = tripDay["date"]
            }
        } else if let fc = fetchedResultsController {
            let tripDay = fc.object(at: indexPath) as! TripDay
            
            if let location = tripDay.location {
                cell.textLabel?.text = location
                cell.detailTextLabel?.text = dateFormatter.string(from: tripDay.date as! Date)
            } else {
                cell.detailTextLabel?.text = dateFormatter.string(from: tripDay.date as! Date)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if isOfflineTrip == nil {
            if reachability.isReachable {
                let tripDay = tripDays[indexPath.row].key
                firebaseService.deleteTripDay(for: tripId, id: tripDay)
            } else {
                showErrorToUser(title: "No internet!", message: "Trips cannot be edited when offline.")
            }
        } else {
            showErrorToUser(title: "Favorite trip!", message: "Editing a favorite trip is not allowed.")
        }
    }
}
