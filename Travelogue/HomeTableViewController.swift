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
import ReachabilitySwift

class HomeTableViewController: UIViewController, FUIAuthDelegate {

    @IBOutlet weak var tripTableView: UITableView!
    @IBOutlet weak var loadingIndicatorView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var noTripsLabel: UILabel!
    @IBOutlet weak var signOutSignInButton: UIButton!
    @IBOutlet weak var addTripButton: UIBarButtonItem!
    var ref: FIRDatabaseReference!
    var trips: [FIRDataSnapshot]! = []
    let delegate = UIApplication.shared.delegate as! AppDelegate
    fileprivate var _refHandle: FIRDatabaseHandle?
    fileprivate var _authHandle: FIRAuthStateDidChangeListenerHandle!
    fileprivate var firebaseService = FirebaseService.instance
    fileprivate let fourSquareApiHelper = FourSquareApiHelper.instance
    var dateFormatter = DateFormatter()
    var timeFormatter = DateFormatter()
    var displayName = "Anonymous"
    let reachability = Reachability()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
        configureUI()
        configureAuth()
        
        reachability.whenUnreachable = { reachability in
            DispatchQueue.main.async {
                self.showErrorToUser(title: "No internet!", message: "You are offline.")
                self.loadingIndicatorView.isHidden = true
            }
        }
    }
    
    func configureUI() {
        tripTableView.delegate = self
        tripTableView.dataSource = self
        dateFormatter.dateFormat = "MMM dd, yyyy"
        timeFormatter.dateFormat = "h:mm a"
    }
    
    // MARK: Config
    
    func configureAuth() {
        let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
        FUIAuth.defaultAuthUI()?.providers = providers
        
        _authHandle = FIRAuth.auth()?.addStateDidChangeListener { (auth: FIRAuth, user: FIRUser?) in
            self.trips.removeAll(keepingCapacity: false)
            self.noTripsLabel.isHidden = true
            self.tripTableView.reloadData()
            
            if let activeUser = user {
                if self.delegate.user != activeUser {
                    self.configureSignedInState(user: activeUser)
                    self.ref = FIRDatabase.database().reference()
                    self.firebaseService.configure(ref: self.ref)
                    self.configureDatabase()
                }
            } else {
                self.configureSignedOutState()
                self.loginSession()
            }
        }
        
    }
    
    func configureSignedInState(user: FIRUser) {
        addTripButton.isEnabled = true
        loadingIndicatorView.isHidden = false
        loadingIndicator.startAnimating()
        signOutSignInButton.setTitle("SignOut", for: UIControlState.normal)
        delegate.user = user
        let name = delegate.user!.email!.components(separatedBy: "@")[0]
        displayName = name
    }
    
    func configureSignedOutState() {
        signOutSignInButton.setTitle("SignIn", for: UIControlState.normal)
        addTripButton.isEnabled = false
        loadingIndicatorView.isHidden = true
        loadingIndicator.stopAnimating()
    }
    
    func configureDatabase() {
        ref.child("trips").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            if snapshot.hasChild((self.delegate.user?.uid)!) {
                self.noTripsLabel.isHidden = true
            } else {
                self.noTripsLabel.isHidden = false
                self.loadingIndicatorView.isHidden = true
                self.loadingIndicator.stopAnimating()
            }
        }
        _refHandle = ref.child("trips").child((delegate.user?.uid)!).observe(.childAdded) { (snapshot: FIRDataSnapshot) in
            self.noTripsLabel.isHidden = true
            self.trips.append(snapshot)
            self.tripTableView.insertRows(at: [IndexPath(row: self.trips.count - 1, section: 0)], with: .automatic)
        }
    }
    
    deinit {
        ref.child("trips").removeObserver(withHandle: _refHandle!)
        FIRAuth.auth()?.removeStateDidChangeListener(_authHandle)
        reachability.stopNotifier()
    }
    
    func loginSession() {
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        let authViewController = authUI?.authViewController()
        if let vc = authViewController {
            self.present(vc, animated: true, completion: nil)
        }
    }

    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return TravelogueAuthViewController(authUI: authUI)
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
    }
    
    @IBAction func handleSignInSignOut(_ sender: Any) {
        print(signOutSignInButton.currentTitle!)
        if signOutSignInButton.currentTitle! == "SignOut" {
            signOut(self)
        } else {
            loginSession()
        }
    }
    
    func signOut(_ sender: Any) {
        do {
            self.loadingIndicatorView.isHidden = true
            self.loadingIndicator.stopAnimating()
            try FIRAuth.auth()?.signOut()
        } catch {
            print("unable to sign out: \(error)")
        }
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
        if reachability.isReachable {
            return true
        }
        showErrorToUser(title: "No internet!", message: "Trips cannot be edited when offline.")
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let favorite = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Favorite", handler: { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
            if self.reachability.isReachable {
                let trip = self.trips[indexPath.row].value as! [String: AnyObject]
                self.makeTripOffline(trip: trip)
                self.trips.removeAll(keepingCapacity: false)
                self.tripTableView.reloadData()
                self.configureDatabase()
            } else {
                self.showErrorToUser(title: "No internet!", message: "Trips cannot be favorited when offline.")
            }
            
        });
        favorite.backgroundColor = ColorResources.FavoritesForegroundColor
        
        let unFavorite = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Unfavorite", handler: { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
            if self.reachability.isReachable {
                let trip = self.trips[indexPath.row].value as! [String: AnyObject]
                self.removeTripFromFavorites(tripId: trip["id"] as! String)
                self.trips.removeAll(keepingCapacity: false)
                self.tripTableView.reloadData()
                self.configureDatabase()
            } else {
                self.showErrorToUser(title: "No internet!", message: "Trips cannot be favorited when offline.")
            }
            
        });
        unFavorite.backgroundColor = ColorResources.FavoritesForegroundColor
        
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Delete", handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            if self.reachability.isReachable {
                let trip = self.trips[indexPath.row].value as! [String: AnyObject]
                self.firebaseService.deleteTrip(id: trip["id"] as! String)
                self.trips.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else {
                self.showErrorToUser(title: "No internet!", message: "Trip can be deleted only when online.")
            }
        });
        
        let trip = self.trips[indexPath.row].value as! [String: AnyObject]
        let isFavorite = trip["favorite"] as! Bool
        
        if isFavorite {
            return [unFavorite, delete]
        }
        return [favorite, delete]
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
            vc.ref = ref
        }
    }
}

extension HomeTableViewController {
    func makeTripOffline(trip: [String: AnyObject]) {
        
        // Create Trip model
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
            if !(tripDay["location"]!.isEmpty) {
                tripDayModel.location = tripDay["location"]
            }
            tripDayModel.trip = tripModel
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
    
    func removeTripFromFavorites(tripId: String) {
        let stack = delegate.stack
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Trip")
        fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let predicate = NSPredicate(format: "id = %@", tripId)
        fr.predicate = predicate
        
        let fc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fc.performFetch()
        } catch let e as NSError {
            print("Error while trying to perform a search: \n\(e)\n\(fc)")
        }
        
        let trip = fc.object(at: IndexPath(row: 0, section: 0)) as! Trip
        print(trip.id!)
        fc.managedObjectContext.delete(fc.object(at: IndexPath(row: 0, section: 0)) as! NSManagedObject)
        delegate.stack.save()
        
        firebaseService.updateTripFavorite(for: tripId, isFavorite: false)
    }
}

extension UIViewController {
    func showErrorToUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

