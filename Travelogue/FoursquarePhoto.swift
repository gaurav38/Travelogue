//
//  SuggestedPhoto.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 2/28/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import Foundation
import GooglePlaces

class FoursquarePhoto {
    var photoDescription: String!
    var isLoaded = false
    var photo: UIImage?
    var photoUrl: String!
    
    init(photoUrl: String, photoDescription: String) {
        self.photoUrl = photoUrl
        self.photoDescription = photoDescription
    }
}
