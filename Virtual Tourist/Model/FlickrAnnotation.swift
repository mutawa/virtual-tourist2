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
    var coordinate: CLLocationCoordinate2D
    var title: String?
    let pin:Pin
    
    init(withCoordinate coordinate: CLLocationCoordinate2D, title:String?, pin: Pin) {
        self.coordinate = coordinate
        self.title = title
        self.pin = pin
    }
    
    
}
