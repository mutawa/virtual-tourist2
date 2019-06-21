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
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}
