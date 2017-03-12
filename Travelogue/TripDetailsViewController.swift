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

class TripDetailsViewController: UIViewController {
    
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripDaysTableView: UITableView!
    @IBOutlet weak var loadingIndicatorView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var tripId: String!
    var tripName: String!
    var tripDays: [FIRDataSnapshot]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicatorView.isHidden = false
        loadingIndicator.startAnimating()
        tripDaysTableView.delegate = self
        tripDaysTableView.dataSource = self
        tripNameLabel.text = tripName
        configureDatabase()
    }
    
    func configureDatabase() {
        let ref = FIRDatabase.database().reference()
        print(tripId)
        ref.child("trip_days").child(tripId).observe(.childAdded) { (snapshot: FIRDataSnapshot) in
            self.tripDays.append(snapshot)
            self.tripDaysTableView.insertRows(at: [IndexPath(row: self.tripDays.count - 1, section: 0)], with: .automatic)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTripDayDetails" {
            let vc = segue.destination as! TripDayDetailsViewController
            
            let selectedIndex = tripDaysTableView.indexPathForSelectedRow!
            let selectedTripDay = tripDays[selectedIndex.row].value as! [String: String]
            vc.tripDayId = selectedTripDay["id"]
            vc.tripDayDate = selectedTripDay["date"]
            vc.tripDayLocation = selectedTripDay["location"]
        }
    }
}

extension TripDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        loadingIndicatorView.isHidden = true
        // Create the cell
        let cell = tripDaysTableView.dequeueReusableCell(withIdentifier: "TripDayCell", for: indexPath)
        
        // Sync tripDay -> cell
        let tripDay = tripDays[indexPath.row].value as! [String: String]
        print(tripDay)
        if let location = tripDay["location"] {
            cell.textLabel?.text = location
            cell.detailTextLabel?.text = tripDay["date"]
        } else {
            cell.textLabel?.text = tripDay["date"]
        }
        
        return cell
    }
}
