//
//  FlickrClientConstant.swift
//  VirtualTourist
//
//  Created by Yang Ji on 11/11/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

extension FlickrClient {
    
    // MARK: Flickr
    struct Flickr {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
    }
    
    // MARK: Flickr Parameter Keys
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let BoundingBox = "bbox"
        static let Page = "page"
    }
    
    // MARK: Flickr Parameter Values
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "ca4a2557448ed06d8f8548b96187ece4"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
    }
    
    // MARK: Flickr Response Keys
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    }
    
    // MARK: Flickr Response Values
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }
    
    // MARK: ERROR
    struct FlickrError {
        static let DomainErrorGETImage = "GetImageTaskBySearch"
        static let DomainErrorParseData = "parseJSONWithData"
        static let DomainErrorDownloadImage = "Downloading Image"
        static let ErrorCodeTwo = "Network connection lost"
        static let ErrorDuringFetch = "A technical error occured while fetching photos"
        static let NotFoundPhotoKey = "Not Found key word 'Photo'"
        static let NotFoundPhotosKey = "Not Fount key word 'Photos'"
    }
    
    
    struct BBoxParameters {
        static let BOUNDING_BOX_HALF_WIDTH = 1.0
        static let BOUNDING_BOX_HALF_HEIGHT = 1.0
        static let LAT_MIN = -90.0
        static let LAT_MAX = 90.0
        static let LON_MIN = -180.0
        static let LON_MAX = 180.0
    }
}
