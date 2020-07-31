//
//  FlickrResponse.swift
//  VirtualTourist
//
//  Created by Chantal Deguire on 2020-07-30.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation


struct FlickrResponse: Codable {
    
    let photos: PhotosResponse
    let stat: String
    
    enum CodingKeys: String, CodingKey {
        case photos
        case stat
    }
}

struct PhotosResponse: Codable {
    
    let page: Int
    let pages: Int
    let perPage: Int
    let total: String
    let photo: [FlickrPhoto]
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perPage = "perpage"
        case total
        case photo
    }
}

struct FlickrPhoto: Codable {
    
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let isPublic: Int
    let isFriend: Int
    let isFamily: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case secret
        case server
        case farm
        case title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
    }
}
