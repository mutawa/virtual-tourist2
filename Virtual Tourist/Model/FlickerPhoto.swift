//
//  FlickerPhoto.swift
//  Virtual Tourist
//
//  Created by Ahmad Al-Mutawa on 6/18/19.
//  Copyright © 2019 Ahmad Apps. All rights reserved.
//

import Foundation

struct FlickerPhoto:Codable {
    let id:String
    let server:String
    let farm:Int
    
    enum CodingKeys: String, CodingKey {
        case id, server, farm
    }
}

struct FlickerResult:Codable {
    let page:Int
    let pages:Int
    let perpage:Int
    let total:String
    let photo:[FlickerPhoto]
    enum CodingKeys: String, CodingKey {
        case page,pages,perpage,total,photo
    }
}

struct FlickerResponse:Codable {
    let photos:FlickerResult
    let stat:String
    enum CodingKeys: String, CodingKey {
        case photos,stat
    }
}
