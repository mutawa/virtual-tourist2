//
//  FlickrResult.swift
//  Virtual Tourist
//
//  Created by Ahmad Al-Mutawa on 03/07/2019.
//  Copyright © 2019 Ahmad Apps. All rights reserved.
//

import Foundation


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
