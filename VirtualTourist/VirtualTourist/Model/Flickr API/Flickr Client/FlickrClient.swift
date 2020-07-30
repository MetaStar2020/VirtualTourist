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
        case photoPath(Int, String, String, String)
        
        var stringValue: String {
            switch self {
            case .search(let lat, let long):
                return Endpoints.base + Endpoints.apiKeyParam + Endpoints.flickrQuery + "&lat=\(lat)&lon=\(long)&format=json&nojsoncallback=1"
            case .photoPath(let farm, let server, let id, let secret):
                return "http://farm\(farm).static.flickr.com/\(server)/\(id)_\(secret).jpg"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(FlickrErrorResponse.self, from: data) as Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        
        return task
    }
    
    class func search(lat: String, long: String, completion: @escaping ([FlickrPhoto], Error?) -> Void) -> URLSessionDataTask {
        let task = taskForGETRequest(url: Endpoints.search(lat,long).url, responseType: FlickrResponse.self) { response, error in
            if let response = response {
                completion(response.photos.photo, nil)
            } else {
                completion([], error)
            }
        }
        return task
    }
    
    class func downloadPosterImage(photo: FlickrPhoto, completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.photoPath(photo.farm, photo.server, photo.id, photo.secret).url) { data, response, error in
            DispatchQueue.main.async {
                completion(data, error)
            }
        }
        task.resume()
    }
    
}
