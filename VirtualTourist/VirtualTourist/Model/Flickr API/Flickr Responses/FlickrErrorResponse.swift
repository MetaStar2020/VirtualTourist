//
//  FlickrErrorResponse.swift
//  VirtualTourist
//
//  Created by Chantal Deguire on 2020-07-30.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

struct FlickrErrorResponse: Codable {
    
    let stat: String
    let code: Int
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case stat
        case code
        case message
    }
}

extension FlickrErrorResponse: LocalizedError {
    var errorDescription: String? {
        return message
    }
}
