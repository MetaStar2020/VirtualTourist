//
//  FlickrAPI.swift
//  VirtualTourist
//
//  Created by Chantal Deguire on 2020-07-29.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

class FlickrClient {
    
    static let flickrAPIKey = "23aa09bd0bda6d5930e81a57a1738fc1"
    static let flickrAPISecret = "00d842f53cde4ac1"
    
    
    enum Endpoints {
        static let base = " https://www.flickr.com/services/rest/?method=flickr.photos.search" //&api_key=\(flickrAPIKey)&bbox=-10%2C-10%2C10%2C10&content_type=1&lat=43.6532&lon=79.3832&format=json&nojsoncallback=1"
        static let apiKeyParam = "&api_key=\(flickrAPIKey)"
        
        //Static queries for the request
        static let bboxQuery = "&bbox=-10%2C-10%2C10%2C10"
        static let contentTypeQuery = "&content_type=1"
        static let flickrQuery = Endpoints.bboxQuery + Endpoints.contentTypeQuery
        
        case search(String,String)
        //case photoPath
        
        var stringValue: String {
            switch self {
            case .search(let lat, let long):
                return Endpoints.base + Endpoints.apiKeyParam + Endpoints.flickrQuery + "&lat=\(lat)&lon=\(long)&format=json&nojsoncallback=1"
            //case .photoPath: "http://farm" + FlickResponse.farm + ".static.flickr.com/" + FlickResponse.server + "/"+ FlickResponse.id + "_"+FlickResponse.secret + ".jpg"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
}
