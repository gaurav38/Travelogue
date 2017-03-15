//
//  CreateDayPlanViewController.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 2/26/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import UIKit
import Firebase
import GooglePlaces
import ReachabilitySwift

class CreateDayPlanViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var activitiesTableView: UITableView!
    @IBOutlet weak var addItineraryButton: UIButton!
    
    var dataContainer: NewTripDataContainer!
    var tripDay: String!
    var date: Date!
    var firebaseService: FirebaseService!
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var tripDayLocation: String?
    let reachability = Reachability()!
    
    fileprivate var location: String?
    fileprivate var suggestedPlaces = [FoursquarePhoto]()
    fileprivate let dateFormatter = DateFormatter()
    fileprivate let timeFormatter = DateFormatter()
    fileprivate var tripDayVisits: [FIRDataSnapshot]! = []
    fileprivate var selectedSuggestedPlace: FoursquarePhoto?
    fileprivate let fourSquareApiHelper = FourSquareApiHelper.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.placeholder = "Enter city:"
        locationTextField.delegate = self
        addItineraryButton.isEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
        dateView.layer.cornerRadius = 37
        dateFormatter.dateFormat = "MMM d, yyyy"
        timeFormatter.dateFormat = "h:mm a"
        let dateString = dateFormatter.string(from: date as Date)
        let dateComponents = dateString.components(separatedBy: ", ")
        dateLabel.text = dateComponents[0]
        yearLabel.text = dateComponents[1]
        updateItemSizeBasedOnOrientation()
        activitiesTableView.delegate = self
        activitiesTableView.dataSource = self
        configureTripDayVisitsObserver()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    func updateItemSizeBasedOnOrientation() {
        var width: CGFloat = 0.0
        var height: CGFloat = 0.0
        let space: CGFloat = 5.0
        
        width = (collectionView.frame.size.width - space) / 2.0
        height = collectionView.frame.size.height - space
        if height > 0 && width > 0 {
            var itemSize: CGSize = CGSize()
            itemSize.height = height
            itemSize.width = width
            
            flowLayout.minimumInteritemSpacing = space
            flowLayout.itemSize = itemSize
        }
    }
    
    func configureTripDayVisitsObserver() {
        print("Adding observer for \(tripDay)")
        FIRDatabase.database().reference().child("trip_visits").child(tripDay).observe(.childAdded) { (snapshot: FIRDataSnapshot) in
            self.tripDayVisits.append(snapshot)
            self.activitiesTableView.reloadData()
        }
    }
    
    @IBAction func unWindToHere(_ segue: UIStoryboardSegue) {
        let vc = segue.source as! AddActivityViewController
        let timeStamp = Int((Date().timeIntervalSince1970 * 1000).rounded())
        let userId = self.delegate.user!.uid
        let tripVisitId = "TRIP_VISIT_\(userId)_\(timeStamp)"
        firebaseService.createTripDayVisit(for: tripDay, id: tripVisitId, location: location ?? "", place: vc.activityDescription, photoUrl: vc.selectedPlaceUrl, startTime: vc.startTime!, endTime: vc.endTime!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddActivity" {
            let vc = segue.destination as! AddActivityViewController
            vc.date = date
            if selectedSuggestedPlace != nil {
                vc.preSelectedPlace = selectedSuggestedPlace
            }
        }
    }
}

extension CreateDayPlanViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripDayVisits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell")! as UITableViewCell
        let tripDayVisitSnapshot: FIRDataSnapshot = tripDayVisits[indexPath.row]
        let tripDayVisit = tripDayVisitSnapshot.value as! [String: String]
        
        cell.textLabel?.text = tripDayVisit["place"]
        if let startTime = tripDayVisit["startTime"] {
            if let endTime = tripDayVisit["endTime"] {
                cell.detailTextLabel?.text = "\(startTime) - \(endTime)"
            } else {
                cell.detailTextLabel?.text = "\(startTime) -"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if reachability.isReachable {
                let visit = tripDayVisits[indexPath.row].value as! [String: String]
                firebaseService.deleteTripDayVisit(for: tripDay, id: visit["id"]!)
                tripDayVisits.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else {
                showErrorToUser(title: "No internet!", message: "Trip can be edited only when online.")
            }
        }
    }
}

extension CreateDayPlanViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func setLocation(location: String) {
        locationTextField.text = location
        addItineraryButton.isEnabled = true
        dataContainer.selectedLocations.append(location)
        self.location = location
        firebaseService.updateTripDayLocation(for: dataContainer.tripId, tripDayId: tripDay, location: location)
        delegate.stack.save()
        fetchSuggestedLocationPhotos()
    }
}

extension CreateDayPlanViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        setLocation(location: place.name)
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

extension CreateDayPlanViewController {
    func fetchSuggestedLocationPhotos() {
        fourSquareApiHelper.getPhotosNear(location: location!) { (error, photos) in
            if let error = error {
                if error == "The Internet connection appears to be offline." {
                    self.showErrorToUser(title: "No internet!", message: "We could not fetch suggested places.")
                }
            }
            else if let photos = photos {
                self.suggestedPlaces = photos
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

extension CreateDayPlanViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return suggestedPlaces.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestedPhotosCell", for: indexPath) as! LocationSuggestionCollectionViewCell
        
        cell.photo.image = nil
        let suggestedPhoto = suggestedPlaces[indexPath.row]
        if suggestedPhoto.isLoaded {
            cell.photo.image = suggestedPhoto.photo
            cell.activityIndicator.stopAnimating()
        } else {
            cell.activityIndicator.startAnimating()
            fourSquareApiHelper.downloadFoursquarePhoto(imagePath: suggestedPhoto.photoUrl) { (photo, error) in
                if let error = error {
                    print("Error: \(error)")
                } else {
                    DispatchQueue.main.async {
                        cell.activityIndicator.stopAnimating()
                        cell.photo.image = UIImage(data: photo!)
                        suggestedPhoto.photo = UIImage(data: photo!)
                        suggestedPhoto.isLoaded = true
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedSuggestedPlace = suggestedPlaces[indexPath.row]
        if selectedSuggestedPlace!.isLoaded {
            self.navigationController?.isNavigationBarHidden = true
            let newView = UIView()
            newView.frame = self.view.frame
            newView.backgroundColor = .black
            
            let newImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            newImageView.image = selectedSuggestedPlace!.photo
            newImageView.contentMode = .scaleAspectFit
            
            let label = BetterLabel(frame: CGRect(x: 0, y: -(self.view.frame.height/2) + 40, width: self.view.frame.width, height: self.view.frame.height))
            label.text = selectedSuggestedPlace!.photoDescription
            label.textAlignment = NSTextAlignment.center
            label.textColor = .white
            label.font.withSize(16)
            
            let button = UIButton(frame: CGRect(x: 15, y: self.view.frame.height - 60, width: self.view.frame.width - 30, height: 40))
            button.backgroundColor = UIColor(red: CGFloat(1), green: CGFloat(102)/255.0, blue: CGFloat(102)/255.0, alpha: 1)
            button.setTitle("Select place", for: UIControlState.normal)
            button.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 18)
            button.addTarget(self, action: #selector(addActivityForSelectedPlace), for: UIControlEvents.touchUpInside)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
            newView.addGestureRecognizer(tap)
            
            newView.addSubview(newImageView)
            newView.addSubview(label)
            newView.addSubview(button)
            
            self.view.addSubview(newView)
        }
    }
}

extension CreateDayPlanViewController {
    func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
        self.navigationController?.isNavigationBarHidden = false
        selectedSuggestedPlace = nil
    }
    
    func addActivityForSelectedPlace() {
        performSegue(withIdentifier: "AddActivity", sender: self)
    }
}
