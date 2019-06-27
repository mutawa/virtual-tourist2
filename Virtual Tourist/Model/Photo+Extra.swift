//
//  Photo+Extra.swift
//  Virtual Tourist
//
//  Created by Ahmad Al-Mutawa on 25/06/2019.
//  Copyright © 2019 Ahmad Apps. All rights reserved.
//

import UIKit


extension Photo {
    private var url:String? {
        guard let id = id else { return nil  }
        guard let server = server else { return nil }
        
        var urlString = "https://farm\(farm).staticflickr.com/\(server)/\(id)"
        if secret != nil {
            urlString += "_\(secret!)"
        }
        urlString += ".jpg"
        return urlString
    }
    
    func load(completionHandler:@escaping (Data?)->()) {
        
        
        FlickrAPI.shared.loadImage(from: url) { data in
                completionHandler(data)
            
        }
            
        
    }
    
    var image:UIImage? {
        
        guard let data=data else { return nil }
        return UIImage(data: data)
    }
    
}
