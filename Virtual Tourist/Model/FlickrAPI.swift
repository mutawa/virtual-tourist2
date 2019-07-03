//
//  FlickrAPI.swift
//  Virtual Tourist
//
//  Created by Ahmad Al-Mutawa on 6/17/19.
//  Copyright © 2019 Ahmad Apps. All rights reserved.
//

import Foundation
import MapKit


class FlickrAPI {
    // Singlton desing pattern
    public static let shared = FlickrAPI()
    private init() {}
    
    private static var baseUrl:String {
        return
            "https://api.flickr.com/services/rest?"
                + "method=flickr.photos.search"
                + "&api_key=\(Constants.FlickrApiKey)"
                + "&format=json"
                + "&per_page=\(Constants.maximumNumberOfPhotosToPull)"
        
    }
    
    
    
    // this function will be called whenever the user taps on a new location on the map
    public func select(location:CLLocationCoordinate2D, completionHandler: ((FlickrResult?,String?)->Void)?=nil) {
        // inject latitude and longitude parameters into the url
        let urlString = FlickrAPI.baseUrl + "&lon=\(location.longitude)&lat=\(location.latitude)"
        
        // make sure it is a valid url
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, resp, err in
            // check if there were any errors
            guard err == nil else {
                completionHandler?(nil,err?.localizedDescription)
                return
            }
            
            // check if data is received
            guard let data=data else {
                completionHandler?(nil,"No data retrieved from API")
                return
                
            }
            
            let decoder = JSONDecoder()
            
            // skip the first 14 characters, and remove the last character
            let sData = data.subdata(in: 14..<data.count-1)
            
            do {
                
                let reply = try decoder.decode(FlickrResponse.self, from: sData)
                DispatchQueue.main.async {
                    completionHandler?(reply.result,nil)
                }
            } catch {
                completionHandler?(nil,"Error while trying to parse recieved data. \(err?.localizedDescription ?? "")")
            }
            
            
            }.resume()
        
    }
    
    
    // this function will be called by the Custom Cells in the PhotoAlbum View controller to load each image
    public func loadImage(from urlString:String, completionHandler: ((Data?,String?)->())? = nil) {
        
        URLSession.shared.dataTask(with: URL(string: urlString)!) { imgdata, resp, err in
            guard err == nil else {
                completionHandler?(nil,err?.localizedDescription)
                return
                
            }
        
            if let data = imgdata {
                
                completionHandler?(data,nil)
            }
            
            }.resume()
        
    }
    
}
