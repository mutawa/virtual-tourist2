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
    private static let key = "03ad452ca7fc8e5b98cda18df0c68d7b"
    private static let secret = "2c1ac02addba8a2f"
    
    
    private static var baseUrl:String {
        return
            "https://api.flickr.com/services/rest?"
                + "method=flickr.photos.search"
                + "&api_key=\(key)"
                + "&format=json"
                + "&per_page=50"
        
    }
    public static let shared = FlickrAPI()
    
    private init() {}
    
    public func select(location:CLLocationCoordinate2D, completionHandler: ((FlickrResult?,String?)->Void)?=nil) {
        
        URLSession.shared.dataTask(with: URL(string: FlickrAPI.baseUrl + "&lon=\(location.longitude)&lat=\(location.latitude)")!) { data, resp, err in
            guard err == nil else {
                completionHandler?(nil,err?.localizedDescription)
                return
                
            }
            guard let data=data else {
                completionHandler?(nil,"No data retrieved from API")
                return
                
            }
            let decoder = JSONDecoder()
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
    
    public func loadImage(from urlString:String?, completionHandler: ((Data?,String?)->())? = nil) {
        
        guard let urlString = urlString else { return }
        
        
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
