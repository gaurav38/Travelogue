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

class HomeTableViewController: UITableViewController, FUIAuthDelegate {

    var ref: FIRDatabaseReference!
    var trips: [FIRDataSnapshot]! = []
    let delegate = UIApplication.shared.delegate as! AppDelegate
    fileprivate var _refHandle: FIRDatabaseHandle!
    fileprivate var _authHandle: FIRAuthStateDidChangeListenerHandle!
    fileprivate var firebaseService = FirebaseService.instance
    var displayName = "Anonymous"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAuth()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Config
    
    func configureAuth() {
        let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
        FUIAuth.defaultAuthUI()?.providers = providers
        
        // listen for changes in the authentication state
        _authHandle = FIRAuth.auth()?.addStateDidChangeListener { (auth: FIRAuth, user: FIRUser?) in
            // refresh table state
            self.trips.removeAll(keepingCapacity: false)
            self.tableView.reloadData()
            
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
            self.tableView.insertRows(at: [IndexPath(row: self.trips.count - 1, section: 0)], with: .automatic)
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

extension HomeTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath)
        let tripSnapshot: FIRDataSnapshot = trips[indexPath.row]
        let trip = tripSnapshot.value as! [String: AnyObject]
        
        print(trip)
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
}

//extension HomeTableViewController {
//    func fetchSavedTrips() {
//        
//        // Get the Stack
//        let stack = delegate.stack
//        
//        // Create the fetch request
//        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Trip")
//        fr.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
//        
//        // Create the FetchResultsController
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        // Find the notebook
//        let trip = fetchedResultsController!.object(at: indexPath) as! Trip
//        
//        // Create the cell
//        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath)
//        
//        // Sync trip -> cell
//        cell.textLabel?.text = trip.name!
//        if trip.startDate == nil && trip.endDate == nil {
//            cell.detailTextLabel?.text = ""
//        } else if trip.endDate == nil {
//            cell.detailTextLabel?.text = "\(trip.startDate!) -"
//        } else {
//            cell.detailTextLabel?.text = "\(trip.startDate!) - \(trip.endDate!)"
//        }
//        
//        print(trip.tripDay?.count ?? 0)
//        
//        return cell
//    }
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

