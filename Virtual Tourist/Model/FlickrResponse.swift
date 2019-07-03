//
//  FlickrResponse.swift
//  Virtual Tourist
//
//  Created by Ahmad Al-Mutawa on 03/07/2019.
//  Copyright © 2019 Ahmad Apps. All rights reserved.
//

import Foundation


struct FlickrResponse:Codable {
    let result:FlickrResult
    let stat:String
    enum CodingKeys: String, CodingKey {
        // Flickr API for some reason calls the result object 'photos'
        // and calls the returned array of photos 'photo'. Consusing, I know.
        // Thus, we need to fix that by renaming their result
        case result="photos", stat
    }
}
