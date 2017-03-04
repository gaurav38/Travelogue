//
//  TravelogueClient.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 2/27/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import Foundation

class TravelogueClient {
    static let instance = TravelogueClient()
    
    let session = URLSession.shared
    
    func taskForGETMethod(_ request: URLRequest, completionHandler: @escaping (_ data: AnyObject?, _ error: String?) -> Void) -> URLSessionDataTask {
        
        print(request.url!)
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                completionHandler(nil, error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("[taskForGETMethod]: \(error.debugDescription)")
                sendError("There was an error with your request")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("[taskForGETMethod]: Request code other than 2xx")
                sendError("Unsuccessful request.")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandler)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    func downloadImage(imagePath:String, completionHandler: @escaping (_ imageData: Data?, _ errorString: String?) -> Void) {
        let imgURL = NSURL(string: imagePath)
        let request = NSURLRequest(url: imgURL! as URL)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard error == nil else {
                completionHandler(nil, "Could not download image \(imagePath)")
                return
            }
            
            completionHandler(data, nil)
        }
        
        task.resume()
    }
    
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: String?) -> Void) {
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            print("Could not parse the data as JSON: '\(data)'")
            completionHandlerForConvertData(nil, "Could not parse the data as JSON")
        }
        completionHandlerForConvertData(parsedResult, nil)
    }
}
