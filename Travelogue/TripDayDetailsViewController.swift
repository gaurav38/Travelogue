//
//  TripDayDetailsViewController.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 3/11/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import UIKit
import Firebase
import CoreData
import ReachabilitySwift

class TripDayDetailsViewController: UIViewController {

    @IBOutlet weak var locationLabel: BetterLabel!
    @IBOutlet weak var dateLabel: BetterLabel!
    @IBOutlet weak var yearLabel: BetterLabel!
    @IBOutlet weak var tripDayVisitsTableView: UITableView!
    @IBOutlet weak var loadingIndicatorView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var tripDayId: String!
    var tripDayLocation: String!
    var tripDayDate: String!
    var tripDayVisits: [FIRDataSnapshot] = []
    var downloadedImages = [String: Data]()
    let fourSquareApiHelper = FourSquareApiHelper.instance
    let firebaseService = FirebaseService.instance
    let reachability = Reachability()!
    
    var isOfflineTrip: Bool?
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    var ref: FIRDatabaseReference!
    fileprivate var _refHandle: FIRDatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        
        if isOfflineTrip == nil {
            loadingIndicatorView.isHidden = false
            loadingIndicator.startAnimating()
        } else if let fc = fetchedResultsController {
            loadingIndicatorView.isHidden = true
            do {
                try fc.performFetch()
                if let results = fc.fetchedObjects {
                    print(results.count)
                }
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
        reachability.whenReachable = { reachability in
            DispatchQueue.main.async {
                if reachability.isReachable {
                    if self.isOfflineTrip == nil {
                        self.tripDayVisits.removeAll(keepingCapacity: false)
                        self.tripDayVisitsTableView.reloadData()
                        self.loadingIndicatorView.isHidden = false
                        self.loadingIndicator.startAnimating()
                        self.configureDatabase()
                    }
                }
            }
        }
        reachability.whenUnreachable = { reachability in
            DispatchQueue.main.async {
                self.loadingIndicatorView.isHidden = true
                self.loadingIndicator.stopAnimating()
                self.showErrorToUser(title: "No internet!", message: "You are offline.")
                if let refHandle = self._refHandle {
                    self.ref.child("trip_visits").removeObserver(withHandle: refHandle)
                }
            }
        }
    }
    
    func configureUI() {
        tripDayVisitsTableView.delegate = self
        tripDayVisitsTableView.dataSource = self
        locationLabel.text = tripDayLocation
        let splittedDate = tripDayDate.components(separatedBy: ",")
        dateLabel.text = splittedDate[0]
        yearLabel.text = splittedDate[1]
    }
    
    func configureDatabase() {
        _refHandle = ref.child("trip_visits").child(tripDayId).observe(.childAdded) { (snapshot: FIRDataSnapshot) in
            self.tripDayVisits.append(snapshot)
            self.tripDayVisitsTableView.insertRows(at: [IndexPath(row: self.tripDayVisits.count - 1, section: 0)], with: .automatic)
        }
    }
}

extension TripDayDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isOfflineTrip == nil {
            return tripDayVisits.count
        } else if let fc = fetchedResultsController {
            return fc.sections![section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if isOfflineTrip == nil {
            if reachability.isReachable {
                let tripVisitId = tripDayVisits[indexPath.row].key
                firebaseService.deleteTripDayVisit(for: tripDayId, id: tripVisitId)
            } else {
                showErrorToUser(title: "No internet!", message: "Trips cannot be edited when offline.")
            }
        } else {
            showErrorToUser(title: "Favorite trip!", message: "Editing a favorite trip is not allowed.")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        loadingIndicatorView.isHidden = true
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripDayDetailsCell") as! TripDayDetailsTableViewCell
        
        if isOfflineTrip == nil {
            let tripDayVisit = tripDayVisits[indexPath.row].value as! [String: String]
            
            let startTime = tripDayVisit["startTime"]!
            let endTime = tripDayVisit["endTime"]!
            let photoUrl = tripDayVisit["photoUrl"]!
            let place = tripDayVisit["place"]
            var time = ""
            
            if !startTime.isEmpty && !endTime.isEmpty {
                time = "\(startTime) - \(endTime)"
            }
            else if !startTime.isEmpty {
                time = "\(startTime) - "
            }
            else {
                time = ""
            }
            cell.placeLabel.text = place
            cell.timeLabel.text = time
            
            if photoUrl.isEmpty {
                cell.photoView.image = #imageLiteral(resourceName: "PlaceholderImage")
            } else {
                if let savedImage = downloadedImages[photoUrl] {
                    cell.photoView.image = UIImage(data: savedImage)
                } else {
                    fourSquareApiHelper.downloadFoursquarePhoto(imagePath: photoUrl) { (photo, error) in
                        if let error = error {
                            print("Error: \(error)")
                        } else {
                            self.downloadedImages[photoUrl] = photo!
                            DispatchQueue.main.async {
                                cell.photoView.image = UIImage(data: photo!)
                            }
                        }
                    }
                }
            }
        } else if let fc = fetchedResultsController {
            let tripDayVisit = fc.object(at: indexPath) as! TripVisit
            var time = ""
            
            if !(tripDayVisit.startTime!.isEmpty) && !(tripDayVisit.endTime!.isEmpty) {
                time = "\(tripDayVisit.startTime!) - \(tripDayVisit.endTime!)"
            }
            else if !(tripDayVisit.startTime!.isEmpty) {
                time = "\(tripDayVisit.startTime!) - "
            }
            else {
                time = ""
            }
            
            cell.timeLabel.text = time
            if let place = tripDayVisit.place {
                cell.placeLabel.text = place
            }
            
            if let photo = tripDayVisit.photo {
                cell.photoView.image = UIImage(data: photo as Data)
            }
        }
        
        
        return cell
    }
}
