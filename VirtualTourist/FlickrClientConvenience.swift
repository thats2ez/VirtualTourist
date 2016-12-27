//
//  FlickrClientConvenience.swift
//  VirtualTourist
//
//  Created by Yang Ji on 11/14/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import Foundation
import CoreData

extension FlickrClient {
    
    private var sharedContext: NSManagedObjectContext {
        return CoreDataStack.sharedInstance().persistentContainer.viewContext
    }
    
    func getPhotosForPin(pin: Pin, completionHandler: @escaping (_ sucess: Bool, _ errorString: String?) -> Void) {
        if (pin.isDownloading) {
            return
        }
        pin.isDownloading = true
        getPhotosOfPinFromFlickr(pin: pin) {sucess, errorString in
            pin.isDownloading = false
            CoreDataStack.sharedInstance().saveContext()
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: FlickrNotification.pinFinishedDownloadingNotification), object: self, userInfo: nil))
            completionHandler(sucess, errorString)
        }
    }
    
    // MARK: - Private
    
    private func getPhotosOfPinFromFlickr(pin: Pin, completionHandler: @escaping (_ sucess: Bool, _ errorString: String?) -> Void) {
        
        // see if we previously  received total number of pages for pin
        var pageNumber = 1
        var numPagesInt = pin.numPages
        if numPagesInt > 190 {
            numPagesInt = 190
        }
        pageNumber = Int(arc4random_uniform(UInt32(numPagesInt))) + 1
        
        let parameters = [
            FlickrParameterKeys.APIKey : FlickrParameterValues.APIKey,
            FlickrParameterKeys.Method : FlickrParameterValues.SearchMethod,
            FlickrParameterKeys.Extras : FlickrParameterValues.MediumURL,
            FlickrParameterKeys.Format : FlickrParameterValues.ResponseFormat,
            FlickrParameterKeys.NoJSONCallback : FlickrParameterValues.DisableJSONCallback,
            FlickrParameterKeys.SafeSearch : FlickrParameterValues.UseSafeSearch,
            FlickrParameterKeys.Page : pageNumber,
            FlickrParameterKeys.BoundingBox : createBoundingBoxString(pin: pin)
        ] as [String : Any]
        
        taskForGETMethod(urlString: nil, methodParameters: parameters as [String : AnyObject]?) {
            JSONResult, error in
            
            if let error = error {
                var errorMessage = ""
                switch error.code {
                case 2:
                    errorMessage = FlickrError.ErrorCodeTwo
                    break
                default:
                    errorMessage = FlickrError.ErrorDuringFetch
                    break
                }
                completionHandler(false, errorMessage)
                return
            }
            
            if let photosDictionary = JSONResult?.value(forKey: FlickrResponseKeys.Photos) as? [String: AnyObject],
                let photosArray = photosDictionary[FlickrResponseKeys.Photo] as? [[String:AnyObject]],
                let numPages = photosDictionary[FlickrResponseKeys.Pages] as? Int {
                performUIUpdatesOnMain {
                    pin.numPages = Int16(numPages)
                    
                    for photoDictionary in photosArray {
                        let photoURLString = photoDictionary[FlickrResponseKeys.MediumURL] as! String
                        let photo = Photo(photoURL: photoURLString, pin: pin, context: self.sharedContext)
                        self.prefetchImage(for: photo)
                    }
                }
                completionHandler(true, nil)
            } else {
                completionHandler(false, FlickrError.NotFoundPhotosKey)
            }
            
        }
        
    }
    
    private func prefetchImage(for photo: Photo) {
        downloadImageForPhoto(photo: photo) { _ in }
    }
    
    private func downloadImageForPhoto(photo:Photo, completionHandler: @escaping (_ error: NSError?) -> Void) {
        
        taskForGETMethod(urlString: photo.photoURL, methodParameters: nil) { JSONResult, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with downloading: \(error)")
                completionHandler(error)
                return
            }
            
            if let result = JSONResult {
                performUIUpdatesOnMain {
                    let filename = (photo.photoURL! as NSString).lastPathComponent
                    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                    let pathArray = [path, filename]
                    let fileURL = NSURL.fileURL(withPathComponents: pathArray)!
                    
                    FileManager.default.createFile(atPath: fileURL.path, contents: result as? Data, attributes: nil)
                    photo.imagePath = fileURL.path
                    completionHandler(nil)
                }
            } else {
                completionHandler(NSError(domain: FlickrError.DomainErrorDownloadImage, code: 2, userInfo: nil))
            }
        }
    }
    
    private func createBoundingBoxString(pin: Pin) -> String {
        
        let latitude = pin.coordinate.latitude
        let longitude = pin.coordinate.longitude
        
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - BBoxParameters.BOUNDING_BOX_HALF_WIDTH, BBoxParameters.LON_MIN)
        let bottom_left_lat = max(latitude - BBoxParameters.BOUNDING_BOX_HALF_HEIGHT, BBoxParameters.LAT_MIN)
        let top_right_lon = min(longitude + BBoxParameters.BOUNDING_BOX_HALF_HEIGHT, BBoxParameters.LON_MAX)
        let top_right_lat = min(latitude + BBoxParameters.BOUNDING_BOX_HALF_HEIGHT, BBoxParameters.LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
}
