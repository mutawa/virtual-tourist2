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
        case result="photos",stat
    }
}
