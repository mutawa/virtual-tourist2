//
//  FlickrAnnotation.swift
//  Virtual Tourist
//
//  Created by Ahmad Al-Mutawa on 03/07/2019.
//  Copyright © 2019 Ahmad Apps. All rights reserved.
//

import Foundation
import MapKit

class FlickrAnnotation:NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        return pin.coordinates
    }
    var title: String?
    let pin:Pin
    
    init(fromPin pin: Pin) {
        self.pin = pin
    }
    
    
}
