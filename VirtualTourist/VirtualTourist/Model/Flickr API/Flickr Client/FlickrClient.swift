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
        static let base = "https://www.flickr.com/services/rest/?method=flickr.photos.search" //&api_key=\(flickrAPIKey)&bbox=-10%2C-10%2C10%2C10&content_type=1&lat=43.6532&lon=79.3832&format=json&nojsoncallback=1"
        static let apiKeyParam = "&api_key=\(flickrAPIKey)"
        
        //Static queries for the request
        static let bboxQuery = "&bbox=-5%2C-5%2C5%2C5"
        static let contentTypeQuery = "&content_type=1"
        static let flickrQuery = Endpoints.bboxQuery + Endpoints.contentTypeQuery
        
        case search(Double,Double)
        case photoPath(Int, String, String, String)
        
        var stringValue: String {
            switch self {
            case .search(let lat, let long):
                return Endpoints.base + Endpoints.apiKeyParam + Endpoints.flickrQuery + "&lat=\(lat)&lon=\(long)&page=\(Int.random(in: 0..<100))&format=json&nojsoncallback=1"
            case .photoPath(let farm, let server, let id, let secret):
                return "https://farm\(farm).static.flickr.com/\(server)/\(id)_\(secret).jpg"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        print("we're in GetRequest")
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("theres no data in the request")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            print(String(decoding: data, as: UTF8.self))
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    print("theres a response in the getRequest")
                    completion(responseObject, nil)
                }
            } catch {
                /*do {
                    let errorResponse = try decoder.decode(FlickrErrorResponse.self, from: data) as LocalizedError
                    DispatchQueue.main.async {
                        print("localized error done here in getRequest")
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }*/
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        
        return task
    }
    
    class func search(lat: Double, long: Double, completion: @escaping ([FlickrPhoto], Error?) -> Void) -> URLSessionDataTask {
        print("were in search func")
        print("url: \(Endpoints.search(lat,long).url)")
        let task = taskForGETRequest(url: Endpoints.search(lat,long).url, responseType: FlickrResponse.self) { response, error in
            if let response = response {
                print("there's been a response under search")
                completion(response.photos.photo, nil)
            } else {
                print("search error: \(error)")
                completion([], error)
            }
        }
        return task
    }
    
    class func photoPathURL(photo: FlickrPhoto) -> URL {
        return Endpoints.photoPath(photo.farm, photo.server, photo.id, photo.secret).url
    }

    /*
    class func downloadPosterImage(photo: FlickrPhoto, completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.photoPath(photo.farm, photo.server, photo.id, photo.secret).url) { data, response, error in
            DispatchQueue.main.async {
                completion(data, error)
            }
        }
        task.resume()
    }*/
    
    class func downloadPosterImage(photoURL: URL, completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: photoURL) { data, response, error in
            DispatchQueue.main.async {
                completion(data, error)
            }
        }
        task.resume()
    }
}
