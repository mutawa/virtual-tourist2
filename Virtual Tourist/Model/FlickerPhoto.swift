//
//  FlickerPhoto.swift
//  Virtual Tourist
//
//  Created by Ahmad Al-Mutawa on 6/18/19.
//  Copyright © 2019 Ahmad Apps. All rights reserved.
//

import UIKit

struct FlickrPhoto:Codable {
    let id:String
    let server:String
    let farm:Int
    let secret:String
  
    enum CodingKeys: String, CodingKey {
        case id, server, farm, secret
    }
    
    var url:String? {
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
    }
}

