//
//  Constants.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 2/27/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import Foundation

struct Constants {
    static let GOOGLE_PLACES_API_KEY = "AIzaSyDi3hlzCQ6NFHfc1D32i3k9ktyGdU6Al6U"
    static let RequestScheme = "https"
    
    struct Google_API {
        static let TextSearchURL = "maps.googleapis.com"
        static let TextSearchAPIPath = "/maps/api/place"
        static let TextSearchMethod = "/textsearch/json"
        static let RequestParamQuery = "query"
        static let RequestParamKey = "key"
        static let ResponseResults = "results"
        static let ResponsePlaceId = "place_id"
        static let ResponseStatus = "status"
    }
    
    struct FourSquare {
        static let HOSTNAME = "api.foursquare.com"
        static let API_PATH = "/v2"
        static let METHOD = "/venues/explore"
        
        struct RequestParamsKeys {
            static let NEAR = "near"
            static let LIMIT = "limit"
            static let INCLUDE_PHOTOS = "venuePhotos"
            static let CLIENT_ID = "client_id"
            static let CLIENT_SECRET = "client_secret"
            static let MODE = "m"
            static let VERSION = "v"
        }
        
        struct RequestParamsValues {
            static let CLIENT_ID = "DM2GG3SI3WWU1FLIWOJ0I05NHKXEROLBCFDUECPJSSOUPIIH"
            static let CLIENT_SECRET = "ZVMKGDQ0SJQCHJ4VJQRL4IOSYMDXQY1NMOEACODSIQVXY52G"
            static let INCLUDE_PHOTOS = "1"
            static let LIMIT = "10"
            static let MODE = "foursquare"
            static let VERSION = "20161231"
        }
        
        struct ResponseKeys {
            static let RESPONSE = "response"
            static let GROUPS = "groups"
            static let ITEMS = "items"
            static let VENUE = "venue"
            static let VENUE_NAME = "name"
            static let PHOTOS = "photos"
            static let PHOTOURL_PREFIX = "prefix"
            static let PHOTOURL_SUFFIX = "suffix"
            static let PHOTO_WIDTH = "width"
            static let PHOTO_HEIGHT = "height"
            static let PHOTO_VISIBILITY = "public"
        }
    }
    
}
