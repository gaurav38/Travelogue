//
//  ViewController.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 2/17/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseFacebookAuthUI
import CoreData

class HomeTableViewController: UIViewController, FUIAuthDelegate {

    @IBOutlet weak var tripTableView: UITableView!
    @IBOutlet weak var loadingIndicatorView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var ref: FIRDatabaseReference!
    var trips: [FIRDataSnapshot]! = []
    let delegate = UIApplication.shared.delegate as! AppDelegate
    fileprivate var _refHandle: FIRDatabaseHandle!
    fileprivate var _authHandle: FIRAuthStateDidChangeListenerHandle!
    fileprivate var firebaseService = FirebaseService.instance
    fileprivate let fourSquareApiHelper = FourSquareApiHelper.instance
    var dateFormatter = DateFormatter()
    var timeFormatter = DateFormatter()
    var displayName = "Anonymous"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tripTableView.delegate = self
        tripTableView.dataSource = self
        loadingIndicator.startAnimating()
        loadingIndicatorView.isHidden = false
        dateFormatter.dateFormat = "MMM dd, yyyy"
        timeFormatter.dateFormat = "h:mm a"
        configureAuth()
    }
    
    // MARK: Config
    
    func configureAuth() {
        let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
        FUIAuth.defaultAuthUI()?.providers = providers
        
        // listen for changes in the authentication state
        _authHandle = FIRAuth.auth()?.addStateDidChangeListener { (auth: FIRAuth, user: FIRUser?) in
            // refresh table state
            self.trips.removeAll(keepingCapacity: false)
            self.tripTableView.reloadData()
            
            // check if there is a current user
            if let activeUser = user {
                // check if the current app user is the current FIRUser
                if self.delegate.user != activeUser {
                    self.delegate.user = activeUser
                    let name = self.delegate.user!.email!.components(separatedBy: "@")[0]
                    self.displayName = name
                    self.configureDatabase()
                    self.firebaseService.configure(ref: self.ref)
                }
            } else {
                // user must sign in
                //self.signedInStatus(isSignedIn: false)
                self.loginSession()
            }
        }
        
    }
    
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
        self.firebaseService.configure(ref: ref)
        _refHandle = ref.child("trips").child((delegate.user?.uid)!).observe(.childAdded) { (snapshot: FIRDataSnapshot) in
            self.trips.append(snapshot)
            self.tripTableView.insertRows(at: [IndexPath(row: self.trips.count - 1, section: 0)], with: .automatic)
        }
    }
    
    func configureStorage() {
        // TODO: configure storage using your firebase storage
    }
    
    deinit {
        ref.child("trips").removeObserver(withHandle: _refHandle)
        FIRAuth.auth()?.removeStateDidChangeListener(_authHandle)
    }
    
    func loginSession() {
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        let authViewController = authUI?.authViewController()
        self.present(authViewController!, animated: true, completion: nil)
    }

    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return TravelogueAuthViewController(authUI: authUI)
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
    }
}

extension HomeTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        loadingIndicatorView.isHidden = true
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath)
        let tripSnapshot: FIRDataSnapshot = trips[indexPath.row]
        let trip = tripSnapshot.value as! [String: AnyObject]
        
        cell.textLabel?.text = trip["name"] as? String ?? ""
        
        let startDate = trip["startDate"] as! String
        let endDate = trip["endDate"] as! String
        
        if startDate.isEmpty && endDate.isEmpty {
            cell.detailTextLabel?.text = ""
        } else if endDate.isEmpty {
            cell.detailTextLabel?.text = "\(startDate) -"
        } else {
            cell.detailTextLabel?.text = "\(startDate) - \(endDate)"
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let favorite = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Favorite", handler: { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
            
            let tripSnapshot: FIRDataSnapshot = self.trips[indexPath.row]
            let trip = tripSnapshot.value as! [String: AnyObject]
            self.makeTripOffline(trip: trip)
            
        });
        favorite.backgroundColor = UIColor(red: 1.0, green: CGFloat(102)/255.0, blue: CGFloat(102)/255.0, alpha: 1.0)
        
        return [favorite]
    }
}

extension HomeTableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTripDetails" {
            let vc = segue.destination as! TripDetailsViewController
            
            let indexPath = tripTableView.indexPathForSelectedRow!
            let trip = trips[indexPath.row].value as! [String: AnyObject]
            vc.tripId = trip["id"] as! String
            vc.tripName = trip["name"] as! String
        }
    }
}

extension HomeTableViewController {
    func makeTripOffline(trip: [String: AnyObject]) {
        
        var tripDayIdToModelMap = [String: TripDay]()
        // Create Trip model
        print(trip)
        let tripModel = Trip(tripId: trip["id"] as! String,
                        tripName: trip["name"] as! String,
                        userName: trip["createdByUsername"] as! String,
                        userEmail: trip["createdByUseremail"] as! String,
                        context: delegate.stack.context)
        let startDate = trip["startDate"] as! String
        if !startDate.isEmpty {
            tripModel.startDate = dateFormatter.date(from: startDate) as NSDate?
        }
        let endDate = trip["endDate"] as! String
        if !endDate.isEmpty {
            tripModel.endDate = dateFormatter.date(from: endDate) as NSDate?
        }
        delegate.stack.save()
        
        // Create TripDay models for Trip
        ref.child("trip_days").child(tripModel.id!).observe(.childAdded) { (snapshot: FIRDataSnapshot) in
            
            // Create TripDay model and then create all TripVisit models for a TripDay
            let tripDay = snapshot.value as! [String: String]
            let tripDayDate = tripDay["date"]!
            let tripDayModel = TripDay(dayId: tripDay["id"]!,
                                       date: self.dateFormatter.date(from: tripDayDate)!,
                                       context: self.delegate.stack.context)
            tripDayModel.trip = tripModel
            tripDayIdToModelMap[tripDayModel.id!] = tripDayModel
            self.delegate.stack.save()
            
            self.ref.child("trip_visits").child(tripDayModel.id!).observe(.childAdded) { (snapshot: FIRDataSnapshot) in
                
                let tripDayVisit = snapshot.value as! [String: String]
                let tripDayVisitModel = TripVisit(id: tripDayVisit["id"]!,
                                                  place: tripDayVisit["place"]!,
                                                  startTime: tripDayVisit["startTime"]!,
                                                  endTime: tripDayVisit["endTime"]!,
                                                  context: self.delegate.stack.context)
                tripDayVisitModel.location = tripDayVisit["location"]!
                tripDayVisitModel.photoUrl = tripDayVisit["photoUrl"]!
                //tripDayVisitModel.tripDay = tripDayIdToModelMap[tripDayModel.id!]
                tripDayVisitModel.tripDay = tripDayModel
                self.delegate.stack.save()
                
                if !(tripDayVisitModel.photoUrl!.isEmpty) {
                    self.fourSquareApiHelper.downloadFoursquarePhoto(imagePath: tripDayVisitModel.photoUrl!) { (photo, error) in
                        if let error = error {
                            print("Error: \(error)")
                        } else {
                            DispatchQueue.main.async {
                                tripDayVisitModel.photo = photo! as NSData?
                                self.delegate.stack.save()
                            }
                        }
                    }
                }
            }
        }
        
        firebaseService.updateTripFavorite(for: trip["id"] as! String, isFavorite: true)
    }
}

//extension HomeTableViewController {
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ShowTripDetails" {
//            if let tripDetailsVC = segue.destination as? TripDetailsViewController {
//                
//                // Create Fetch Request
//                let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "TripDay")
//                fr.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
//                
//                let indexPath = tableView.indexPathForSelectedRow!
//                let selectedTrip = fetchedResultsController?.object(at: indexPath) as! Trip
//                
//                let predicate = NSPredicate(format: "trip = %@", [selectedTrip])
//                fr.predicate = predicate
//                
//                for tripDay in selectedTrip.tripDay! {
//                    let tripD = tripDay as! TripDay
//                    print(tripD.date!)
//                    print(tripD.location!)
//                }
//                
//                // Create FetchResultsController
//                let fc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: fetchedResultsController!.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
//                
//                // Inject it into the notesVC
//                tripDetailsVC.fetchedResultsController = fc
//                
//                tripDetailsVC.trip = selectedTrip
//            }
//        }
//    }
//}

