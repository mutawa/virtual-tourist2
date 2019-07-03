//
//  Pin+Extra.swift
//  Virtual Tourist
//
//  Created by Ahmad Al-Mutawa on 6/21/19.
//  Copyright © 2019 Ahmad Apps. All rights reserved.
//

import Foundation
import MapKit

extension Pin {
    var coordinates: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        }
        set {
            self.latitude = newValue.latitude
            self.longitude = newValue.longitude
        }
    }
    
    var photoCountString:String {
        guard let photos = photos else { return "..." }
        
        if photos.count == 0 { return "no photos" }
        else {
            return "\(photos.count) photo" + ((photos.count > 1) ? "s" : "")
        }
    }
    
}
