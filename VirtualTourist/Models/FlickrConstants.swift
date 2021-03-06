//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Sergey Krivov on 10.09.15.
//  Copyright (c) 2015 Sergey Krivov. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    //MARK: - Constants
    struct Constants {
        
        //API Key
        static let APIKey = "329b2b318d8527cccca01bea57b88e8e"
        
        //base URL
        static let BaseURL = "https://api.flickr.com/services/rest/"
    }
    
    //MARK: - Methods
    struct Methods {
        static let Search = "flickr.photos.search"
    }
    
    //MARK: - URL Keys
    struct URLKeys {
        static let APIKey = "api_key"
        static let BoundingBox = "bbox"
        static let Format = "format"
        static let Extras = "extras"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Method = "method"
        static let NoJSONCallback = "nojsoncallback"
        static let Page = "page"
        static let PerPage = "per_page"
    }
    
    //MARK: - URL Values
    struct URLValues {
        static let JSONFormat = "json"
        static let URLMediumPhoto = "url_m"
    }
    
    //MARK: - JSON Response Keys
    struct JSONResponseKeys {
        static let Status = "stat"
        static let Code = "code"
        static let Message = "message"
        static let Pages = "pages"
        static let Photos = "photos"
        static let Photo = "photo"
    }
    
    //MARK: - JSON Response Values
    
    struct JSONResponseValues {
        
        static let Fail = "fail"
        static let Ok = "ok"
    }
}
