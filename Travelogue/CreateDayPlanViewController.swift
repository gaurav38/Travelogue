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
    let googlePlacesApiHelper = GooglePlacesApiHelper.instance
    let googlePlacesClient: GMSPlacesClient! = GMSPlacesClient.shared()
    var photosToLoad = [SuggestedPhoto]()
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
        googlePlacesApiHelper.getPlaceIdForLocation(location: location) { (placeId) in
            if let placeId = placeId {
                print(placeId)
                self.googlePlacesClient.lookUpPhotos(forPlaceID: placeId) { (photosMetadata, error) in
                    if let error = error {
                        // TODO: handle the error.
                        print("Error: \(error.localizedDescription)")
                    } else {
                        if let photoMetadata = photosMetadata {
                            print("Number of photos: \(photoMetadata.results.count)")
                            for photo in photoMetadata.results {
                                self.photosToLoad.append(SuggestedPhoto(photoMetadata: photo))
                            }
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
}

extension CreateDayPlanViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(photosToLoad.count)
        return photosToLoad.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestedPhotosCell", for: indexPath) as! LocationSuggestionCollectionViewCell
        
        cell.photo.image = nil
        let suggestedPhoto = photosToLoad[indexPath.row]
        if suggestedPhoto.isLoaded {
            cell.photo.image = suggestedPhoto.photo
            cell.activityIndicator.stopAnimating()
        } else {
            cell.activityIndicator.startAnimating()
            googlePlacesClient.loadPlacePhoto(suggestedPhoto.placeMetadata) { (photo, error) in
                cell.activityIndicator.stopAnimating()
                if let error = error {
                    // TODO: handle the error.
                    print("Error: \(error.localizedDescription)")
                } else {
                    cell.photo.image = photo
                    suggestedPhoto.photo = photo
                    suggestedPhoto.isLoaded = true
                    print(suggestedPhoto.placeMetadata.attributions?.string ?? "--- No data ---")
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let suggestedPhoto = photosToLoad[indexPath.row]
        if suggestedPhoto.isLoaded {
            let newImageView = UIImageView(image: suggestedPhoto.photo)
            newImageView.frame = self.view.frame
            newImageView.backgroundColor = .black
            newImageView.contentMode = .scaleAspectFit
            newImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
            newImageView.addGestureRecognizer(tap)
            self.view.addSubview(newImageView)
        }
    }
}

extension CreateDayPlanViewController {
    func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
}

extension CreateDayPlanViewController {
    
}
