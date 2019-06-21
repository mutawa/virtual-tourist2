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
            + "&per_page=4"
        
    }
    public static let shared = FlickrAPI()
    
    private init() {}
    
    public func select(location:CLLocationCoordinate2D, completionHandler: ((FlickrResult)->Void)?=nil) {
        
        URLSession.shared.dataTask(with: URL(string: FlickrAPI.baseUrl + "&lon=\(location.longitude)&lat=\(location.latitude)")!) { data, resp, err in
            guard err == nil else { print("Error: \(err?.localizedDescription ?? "some error")"); return }
            guard let data=data else { print("No Data"); return }
            let decoder = JSONDecoder()
            let sData = data.subdata(in: 14..<data.count-1)
            
            do {
                
                let reply = try decoder.decode(FlickrResponse.self, from: sData)
                DispatchQueue.main.async {
                    completionHandler?(reply.result)
                }
                
                

            } catch {
                let str = String(data: sData, encoding: .utf8)!
                print(str)
                print(error.localizedDescription)
            }
            
            
        }.resume()
        
        
        
        
    }
    
}
