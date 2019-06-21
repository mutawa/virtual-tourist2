//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Ahmad Al-Mutawa on 6/17/19.
//  Copyright © 2019 Ahmad Apps. All rights reserved.
//

import UIKit
import MapKit

class MapViewController : UIViewController, MKMapViewDelegate {
    @IBOutlet private var mapView:MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        let tgr = UILongPressGestureRecognizer(target: self, action: #selector(mapTapped))
        mapView.addGestureRecognizer(tgr)
        
        
        
    }
    
    @objc func mapTapped(sender:Any) {
        if let gr = sender as? UILongPressGestureRecognizer {
            let location = gr.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            API.shared.get(location: coordinate) { data in
                let decoder = JSONDecoder()
                let sData = data.subdata(in: 14..<data.count-1)
                
                do {
                    
                    
                    let result = try decoder.decode(FlickerResponse.self, from: sData)
                    
                    print(result.photos.photo.count)

                    
                    
                } catch {
                    let str = String(data: sData, encoding: .utf8)!
                    print(str)
                    print(error.localizedDescription)
                }
                
                
            }
        }
        
    }
}

