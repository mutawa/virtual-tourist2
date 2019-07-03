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
    let photos:[FlickrPhoto]
    enum CodingKeys: String, CodingKey {
        // Flickr calls the array of photos just 'photo'
        // and calls the result that encapsulates the array 'photos'
        // so we need to change that on our end, and keep things as-is for Flickr
        case page, pages, perpage, total, photos="photo"
    }
}
