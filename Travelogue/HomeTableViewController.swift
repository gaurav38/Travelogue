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

class HomeTableViewController: CoreDataTableViewController, FUIAuthDelegate {

    var ref: FIRDatabaseReference!
    let delegate = UIApplication.shared.delegate as! AppDelegate
    fileprivate var _refHandle: FIRDatabaseHandle!
    fileprivate var _authHandle: FIRAuthStateDidChangeListenerHandle!
    var displayName = "Anonymous"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAuth()
        fetchSavedTrips()
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
            //self.messages.removeAll(keepingCapacity: false)
            //self.messagesTable.reloadData()
            
            // check if there is a current user
            if let activeUser = user {
                // check if the current app user is the current FIRUser
                if self.delegate.user != activeUser {
                    self.delegate.user = activeUser
                    //self.signedInStatus(isSignedIn: true)
                    let name = self.delegate.user!.email!.components(separatedBy: "@")[0]
                    self.displayName = name
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
//        _refHandle = ref.child("messages").observe(.childAdded) { (snapshot: FIRDataSnapshot) in
//            self.messages.append(snapshot)
//            self.messagesTable.insertRows(at: [IndexPath(row: self.messages.count - 1, section: 0)], with: .automatic)
//            self.scrollToBottomMessage()
//        }
    }
    
    func configureStorage() {
        // TODO: configure storage using your firebase storage
    }
    
    deinit {
        //ref.child("messages").removeObserver(withHandle: _refHandle)
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
    func fetchSavedTrips() {
        
        // Get the Stack
        let stack = delegate.stack
        
        // Create the fetch request
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Trip")
        fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true), NSSortDescriptor(key: "startDate", ascending: false)]
        
        // Create the FetchResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Find the notebook
        let trip = fetchedResultsController!.object(at: indexPath) as! Trip
        
        // Create the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath)
        
        // Sync trip -> cell
        cell.textLabel?.text = trip.name!
        if trip.startDate == nil && trip.endDate == nil {
            cell.detailTextLabel?.text = ""
        } else if trip.endDate == nil {
            cell.detailTextLabel?.text = "\(trip.startDate!) -"
        } else {
            cell.detailTextLabel?.text = "\(trip.startDate!) - \(trip.endDate!)"
        }
        
        print(trip.tripDay?.count ?? 0)
        
        return cell
    }
}

