//
//  CreateDayPlanViewController.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 2/26/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import UIKit
import GooglePlaces

class CreateDayPlanViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var activitiesView: UIStackView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var dateView: UIView!
    
    var locationNumber: Int!
    var dataContainer: NewTripDataContainer!
    var date: Date!
    var location: String!
    let fourSquareApiHelper = FourSquareApiHelper.instance
    let googlePlacesClient: GMSPlacesClient! = GMSPlacesClient.shared()
    var suggestedPlaces = [FoursquarePhoto]()
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.placeholder = "Enter city:"
        locationTextField.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        dateView.layer.cornerRadius = 37
        dateFormatter.dateFormat = "MMM d, yyyy"
        let dateString = dateFormatter.string(from: date)
        let dateComponents = dateString.components(separatedBy: ", ")
        dateLabel.text = dateComponents[0]
        yearLabel.text = dateComponents[1]
        updateItemSizeBasedOnOrientation()
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
    
    @IBAction func addActivity(_ sender: Any) {
        let label = BetterLabel()
        label.text = "New label"
        label.textColor = UIColor.black
        activitiesView.addArrangedSubview(label)
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
        let suggestedPhoto = suggestedPlaces[indexPath.row]
        if suggestedPhoto.isLoaded {
            let newView = UIView()
            newView.frame = self.view.frame
            newView.backgroundColor = .black
            
            let newImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            newImageView.image = suggestedPhoto.photo
            newImageView.contentMode = .scaleAspectFit
            
            let label = BetterLabel(frame: CGRect(x: 0, y: -(self.view.frame.height/2) + 40, width: self.view.frame.width, height: self.view.frame.height))
            label.text = suggestedPhoto.photoDescription
            label.textAlignment = NSTextAlignment.center
            label.textColor = .white
            label.font.withSize(16)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
            newView.addGestureRecognizer(tap)
            
            newView.addSubview(newImageView)
            newView.addSubview(label)
            
            self.view.addSubview(newView)
            self.navigationController?.isNavigationBarHidden = true
        }
    }
}

extension CreateDayPlanViewController {
    func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
        self.navigationController?.isNavigationBarHidden = false
    }
}
