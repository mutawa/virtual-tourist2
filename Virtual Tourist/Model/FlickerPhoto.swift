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
}

struct FlickrResult:Codable {
    let page:Int
    let pages:Int
    let perpage:Int
    let total:String
    let photo:[FlickrPhoto]
    enum CodingKeys: String, CodingKey {
        case page,pages,perpage,total,photo
    }
}

struct FlickrResponse:Codable {
    let result:FlickrResult
    let stat:String
    enum CodingKeys: String, CodingKey {
        case result="photos",stat
    }
}
