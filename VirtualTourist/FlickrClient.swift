//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Yang Ji on 11/11/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import Foundation


class FlickrClient: NSObject {
    
    // MARK: -Properties
    var session : URLSession
    
    // MARK: -Init
    override init() {
        session = URLSession.shared
        super.init()
    }
    
    // MARK: Singleton Instance
    
    private static var sharedInstance = FlickrClient()
    
    class func sharedClient() -> FlickrClient {
        return sharedInstance
    }

    
    // Create URL by given parameters NSURLComponent()
    func createURLFromParameters(parameters: [String: AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Flickr.APIScheme
        components.host = Flickr.APIHost
        components.path = Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems?.append(queryItem)
        }
        
        return components.url!
    }
    
    // Get data by sending GET request to service
    func taskForGETMethod(urlString: String?, methodParameters : [String: AnyObject]?, completionHandler : @escaping (_ results: AnyObject?, _ error: NSError?)->Void) {
        
        session = URLSession.shared
        
        var requestURL : URL {
            if (urlString != nil) {
                return URL(string: urlString!)!
            } else {
                return createURLFromParameters(parameters: methodParameters!)
            }
        }
        let request = URLRequest(url: requestURL)
        let task = session.dataTask(with: request) { data, urlResponse, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completionHandler(nil, NSError(domain: FlickrError.DomainErrorGETImage, code: 2, userInfo: nil))
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (urlResponse as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode < 299 else {
                var errorCode = 0 /* technical error */
                if let response = urlResponse as? HTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                    errorCode = response.statusCode
                } else if let response = urlResponse {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                
                DispatchQueue.main.async {
                    completionHandler(nil, NSError(domain: FlickrError.DomainErrorGETImage, code: errorCode, userInfo: nil))
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                completionHandler(nil, NSError(domain: FlickrError.DomainErrorGETImage, code: 3, userInfo: nil))
                return
            }
            
            let parseResult : AnyObject
            do {
                parseResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
                completionHandler(parseResult, nil)
            } catch {
                let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
                completionHandler(nil, NSError(domain: FlickrError.DomainErrorParseData, code: 1, userInfo: userInfo))
            }
        }
        task.resume()
    }
    
    // TODO: once get the data, we need to parse the data to photos
    
    
    
    
    
}
