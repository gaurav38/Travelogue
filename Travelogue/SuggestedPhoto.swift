//
//  SuggestedPhoto.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 2/28/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import Foundation
import GooglePlaces

class SuggestedPhoto {
    var placeMetadata: GMSPlacePhotoMetadata!
    var isLoaded = false
    var photo: UIImage?
    
    init(photoMetadata: GMSPlacePhotoMetadata) {
        self.placeMetadata = photoMetadata
    }
}
