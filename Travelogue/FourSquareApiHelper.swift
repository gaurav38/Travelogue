//
//  GooglePlacesApiHelper.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 2/27/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import Foundation

class FourSquareApiHelper {
    static let instance = FourSquareApiHelper()
    
    let travelogueClient = TravelogueClient.instance
    
    func getPhotosNear(location: String, callback: @escaping (String?, [FoursquarePhoto]?) -> Void) {
        var parameters = [String: String]()
        parameters[Constants.FourSquare.RequestParamsKeys.CLIENT_ID] = Constants.FourSquare.RequestParamsValues.CLIENT_ID
        parameters[Constants.FourSquare.RequestParamsKeys.CLIENT_SECRET] = Constants.FourSquare.RequestParamsValues.CLIENT_SECRET
        parameters[Constants.FourSquare.RequestParamsKeys.MODE] = Constants.FourSquare.RequestParamsValues.MODE
        parameters[Constants.FourSquare.RequestParamsKeys.VERSION] = Constants.FourSquare.RequestParamsValues.VERSION
        parameters[Constants.FourSquare.RequestParamsKeys.NEAR] = location
        parameters[Constants.FourSquare.RequestParamsKeys.INCLUDE_PHOTOS] = Constants.FourSquare.RequestParamsValues.INCLUDE_PHOTOS
        parameters[Constants.FourSquare.RequestParamsKeys.LIMIT] = Constants.FourSquare.RequestParamsValues.LIMIT
        
        let url = getURLFromParameters(parameters: parameters, withPathExtension: Constants.FourSquare.METHOD)
        let request = URLRequest(url: url)
        
        let _ = travelogueClient.taskForGETMethod(request) { (data, error) in
            if error == nil {
                if let response = data as? [String: AnyObject] {
                    //print(response)
                    let photos = self.parsePhotosFrom(response: response[Constants.FourSquare.ResponseKeys.RESPONSE] as! [String: AnyObject])
                    if let photos = photos {
                        callback(nil, photos)
                    } else {
                        callback("Empty response", nil)
                    }
                } else {
                    print("Invalid response format!")
                    callback("Invalid response format!", nil)
                }
            } else {
                print(error!)
                callback(error!, nil)
            }
        }
    }
    
    fileprivate func parsePhotosFrom(response: [String: AnyObject]) -> [FoursquarePhoto]? {
        guard let groups = response[Constants.FourSquare.ResponseKeys.GROUPS] as? [[String: AnyObject]] else {
            print("Groups not found in response.")
            return nil
        }
        
        print("Total number of groups = \(groups.count)")
        let group = groups[0]
        guard let items = group[Constants.FourSquare.ResponseKeys.ITEMS] as? [[String: AnyObject]] else {
            print("Items not found in response groups")
            return nil
        }
        
        print("Total number of items in group-1 = \(items.count)")
        
        var foursquarePhotos = [FoursquarePhoto]()
        
        for item in items {
            var description: String? = nil
            if let venue = item[Constants.FourSquare.ResponseKeys.VENUE] as? [String: AnyObject] {
                description = venue[Constants.FourSquare.ResponseKeys.VENUE_NAME] as? String
                if let featuredPhotos = venue[Constants.FourSquare.ResponseKeys.FEATURED_PHOTOS] as? [String: AnyObject] {
                    let photos = featuredPhotos["items"] as! [[String: AnyObject]]
                    for photo in photos {
                        let prefix = photo[Constants.FourSquare.ResponseKeys.PHOTOURL_PREFIX] as! String
                        let suffix = photo[Constants.FourSquare.ResponseKeys.PHOTOURL_SUFFIX] as! String
                        let width = photo[Constants.FourSquare.ResponseKeys.PHOTO_WIDTH] as! NSNumber
                        let height = photo[Constants.FourSquare.ResponseKeys.PHOTO_HEIGHT] as! NSNumber
                        let url = "\(prefix)\(width)x\(height)\(suffix)"
                        print("Description = \(description!)")
                        print("URL = \(url)")
                        let foursquarePhoto = FoursquarePhoto(photoUrl: url, photoDescription: description!)
                        foursquarePhotos.append(foursquarePhoto)
                    }
                }
            }
            
        }
        return foursquarePhotos
    }
    
    func downloadFoursquarePhoto(imagePath:String, completionHandler: @escaping (_ imageData: Data?, _ errorString: String?) -> Void) {
        travelogueClient.downloadImage(imagePath: imagePath, completionHandler: completionHandler)
    }
    
    fileprivate func getPlaceIdFromResponseData(data: [String: AnyObject]) -> String? {
        if let results = data[Constants.Google_API.ResponseResults] as? [[String: AnyObject]] {
            let result = results[0]
            return result[Constants.Google_API.ResponsePlaceId] as? String
        } else {
            return nil
        }
    }
    
    func getURLFromParameters(parameters: [String: String], withPathExtension: String?) -> URL {
        var components = URLComponents()
        components.scheme = Constants.RequestScheme
        components.host = Constants.FourSquare.HOSTNAME
        components.path = Constants.FourSquare.API_PATH + (withPathExtension ?? "")
        
        if !parameters.isEmpty {
            components.queryItems = [URLQueryItem]()
            
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems?.append(queryItem)
            }
        }
        return components.url!
    }
}
