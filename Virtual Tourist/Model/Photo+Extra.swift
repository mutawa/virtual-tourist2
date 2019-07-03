//
//  Photo+Extra.swift
//  Virtual Tourist
//
//  Created by Ahmad Al-Mutawa on 25/06/2019.
//  Copyright © 2019 Ahmad Apps. All rights reserved.
//

import UIKit


extension Photo {
    
    func load(completionHandler:@escaping (Data?,String?)->()) {
        guard let urlString = urlString else { return }
        
        FlickrAPI.shared.loadImage(from: urlString) { data,errorMessage in
            completionHandler(data,errorMessage)
        }
    }
    
    var image:UIImage? {
        guard let data=data else { return nil }
        return UIImage(data: data)
    }
    
}
