//
//  TripDayDetailsViewController.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 3/11/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import UIKit
import Firebase

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadingIndicatorView.isHidden = false
        loadingIndicator.startAnimating()
        configureDatabase()
        tripDayVisitsTableView.delegate = self
        tripDayVisitsTableView.dataSource = self
        locationLabel.text = tripDayLocation
        let splittedDate = tripDayDate.components(separatedBy: ",")
        dateLabel.text = splittedDate[0]
        yearLabel.text = splittedDate[1]
    }
    
    func configureDatabase() {
        let ref = FIRDatabase.database().reference()
        print(tripDayId)
        ref.child("trip_visits").child(tripDayId).observe(.childAdded) { (snapshot: FIRDataSnapshot) in
            self.tripDayVisits.append(snapshot)
            self.tripDayVisitsTableView.insertRows(at: [IndexPath(row: self.tripDayVisits.count - 1, section: 0)], with: .automatic)
        }
    }
}

extension TripDayDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripDayVisits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        loadingIndicatorView.isHidden = true
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripDayDetailsCell") as! TripDayDetailsTableViewCell
        
        let tripDayVisit = tripDayVisits[indexPath.row].value as! [String: String]
        
        let startTime = tripDayVisit["startTime"]!
        let endTime = tripDayVisit["endTime"]!
        let photoUrl = tripDayVisit["photoUrl"]!
        let place = tripDayVisit["place"]
        var time = ""
        
        if !startTime.isEmpty && !endTime.isEmpty {
            time = "\(startTime) - \(endTime)"
        }
        else if !startTime.isEmpty && endTime.isEmpty {
            time = "\(startTime) - "
        }
        else if startTime.isEmpty && endTime.isEmpty {
            time = ""
        }
        
        if photoUrl.isEmpty {
            cell.photoView.image = #imageLiteral(resourceName: "PlaceholderImage")
            cell.placeLabel.text = place
            cell.timeLabel.text = time
        } else {
            if let savedImage = downloadedImages[photoUrl] {
                cell.photoView.image = UIImage(data: savedImage)
                cell.placeLabel.text = place
                cell.timeLabel.text = time
            } else {
                fourSquareApiHelper.downloadFoursquarePhoto(imagePath: photoUrl) { (photo, error) in
                    if let error = error {
                        print("Error: \(error)")
                    } else {
                        self.downloadedImages[photoUrl] = photo!
                        DispatchQueue.main.async {
                            cell.photoView.image = UIImage(data: photo!)
                            cell.placeLabel.text = place
                            cell.timeLabel.text = time
                        }
                    }
                }
            }
        }
        
        return cell
    }
}
