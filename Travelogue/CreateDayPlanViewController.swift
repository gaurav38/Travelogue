//
//  CreateDayPlanViewController.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 2/26/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import UIKit

class CreateDayPlanViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var activitiesTableView: UITableView!
    
    var locationNumber: Int!
    var dataContainer: NewTripDataContainer!
    var tripDayModel: TripDay!
    var location: String!
    var suggestedPlaces = [FoursquarePhoto]()
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    var activities = [TripActivity]()
    var selectedSuggestedPhoto: FoursquarePhoto?
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    let fourSquareApiHelper = FourSquareApiHelper.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.placeholder = "Enter city:"
        locationTextField.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        dateView.layer.cornerRadius = 37
        dateFormatter.dateFormat = "MMM d, yyyy"
        timeFormatter.dateFormat = "h:mm a"
        let dateString = tripDayModel.date!
        let dateComponents = dateString.components(separatedBy: ", ")
        dateLabel.text = dateComponents[0]
        yearLabel.text = dateComponents[1]
        updateItemSizeBasedOnOrientation()
        activitiesTableView.delegate = self
        activitiesTableView.dataSource = self
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
    
    @IBAction func unWindToHere(_ segue: UIStoryboardSegue) {
        let vc = segue.source as! AddActivityViewController
        let activity = TripActivity(time: "\(vc.startTime) - \(vc.endTime)", description: vc.activityDescription)
        let tripVisitModel = TripVisit(place: activity.activityDescription, startTime: vc.startTime, endTime: vc.endTime, context: delegate.stack.context)
        tripVisitModel.tripDay = tripDayModel
        delegate.stack.save()
        activities.append(activity)
        activitiesTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddActivity" {
            let vc = segue.destination as! AddActivityViewController
            vc.date = tripDayModel.date!
            if selectedSuggestedPhoto != nil {
                vc.preSelectedPlace = selectedSuggestedPhoto?.photoDescription
            }
        }
    }
}

extension CreateDayPlanViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell")! as UITableViewCell
        cell.textLabel?.text = ""
        cell.detailTextLabel?.text = ""
        
        let activity = activities[indexPath.row]
        cell.textLabel?.text = activity.activityTime
        cell.detailTextLabel?.text = activity.activityDescription
        return cell
        
    }
}

extension CreateDayPlanViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        dataContainer.selectedLocations.append("")
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        dataContainer.selectedLocations[locationNumber] = textField.text!
        location = textField.text!
        tripDayModel.location = location
        delegate.stack.save()
        fetchSuggestedLocationPhotos()
    }
}

extension CreateDayPlanViewController {
    func fetchSuggestedLocationPhotos() {
        fourSquareApiHelper.getPhotosNear(location: location) { (success, photos) in
            if let photos = photos {
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
        print(suggestedPlaces.count)
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
        selectedSuggestedPhoto = suggestedPlaces[indexPath.row]
        if selectedSuggestedPhoto!.isLoaded {
            let newView = UIView()
            newView.frame = self.view.frame
            newView.backgroundColor = .black
            
            let newImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            newImageView.image = selectedSuggestedPhoto!.photo
            newImageView.contentMode = .scaleAspectFit
            
            let label = BetterLabel(frame: CGRect(x: 0, y: -(self.view.frame.height/2) + 40, width: self.view.frame.width, height: self.view.frame.height))
            label.text = selectedSuggestedPhoto!.photoDescription
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
            self.navigationController?.isNavigationBarHidden = true
        }
    }
}

extension CreateDayPlanViewController {
    func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
        self.navigationController?.isNavigationBarHidden = false
        selectedSuggestedPhoto = nil
    }
    
    func addActivityForSelectedPlace() {
        performSegue(withIdentifier: "AddActivity", sender: self)
    }
}
