//
//  GooglePlacesApiHelper.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 2/27/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import Foundation

class GooglePlacesApiHelper {
    static let instance = GooglePlacesApiHelper()
    
    let travelogueClient = TravelogueClient.instance
    
    func getPlaceIdForLocation(location: String, callback: @escaping (String?) -> Void) {
        var parameters = [String: String]()
        parameters[Constants.Google_API.RequestParamQuery] = location
        parameters[Constants.Google_API.RequestParamKey] = Constants.GOOGLE_PLACES_API_KEY
        
        let url = getURLFromParameters(parameters: parameters, withPathExtension: Constants.Google_API.TextSearchMethod)
        let request = URLRequest(url: url)
        
        let _ = travelogueClient.taskForGETMethod(request) { (data, error) in
            if error == nil {
                if let response = data as? [String: AnyObject], let responseCode = response[Constants.Google_API.ResponseStatus] as? String {
                    if responseCode == "OK" {
                        callback(self.getPlaceIdFromResponseData(data: response))
                    } else if responseCode == "ZERO_RESULT" {
                        print("Google Places API returned empty result for query: \(location)")
                    }
                } else {
                    print("Invalid response format!")
                    callback(nil)
                }
            } else {
                print(error!)
                callback(nil)
            }
        }
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
        components.host = Constants.Google_API.TextSearchURL
        components.path = Constants.Google_API.TextSearchAPIPath + (withPathExtension ?? "")
        
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
