//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Ahmad Al-Mutawa on 6/17/19.
//  Copyright © 2019 Ahmad Apps. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class MapViewController : UIViewController, MKMapViewDelegate {
    @IBOutlet private var mapView:MKMapView!
    
    var dataController:DataController!
    var pins:[Pin] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        let tgr = UILongPressGestureRecognizer(target: self, action: #selector(mapTapped))
        mapView.addGestureRecognizer(tgr)
        
        let fr:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sd = NSSortDescriptor(key: "title", ascending: false)
        fr.sortDescriptors = [sd]
        do {
            pins = try dataController.context.fetch(fr)
            for pin in pins {
                addPinToMap(pin: pin)
                
            }
        }
        catch {
            print("error fetching pins")
        }
        
        
        
        
    }
    
    @objc func mapTapped(sender : UILongPressGestureRecognizer) {
        if sender.state == .began {
            let location = sender.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            
            let annotation = FlickrAnnotation(withCoordinate: coordinate, title: "loading...", subtitle: nil)
            let cdpin = Pin(context: dataController.context)
            cdpin.latitude = coordinate.latitude
            cdpin.longitude = coordinate.longitude
            
            

            mapView.addAnnotation(annotation)
            FlickrAPI.shared.select(location: coordinate) { result in
                print("got result count \(result.photo.count)")
                annotation.setCount(result.photo.count)
                cdpin.title = "\(result.photo.count) photos"
                
                cdpin.photosCount = Int64(result.photo.count)
                print("setting count to \(cdpin.photosCount)")

                
                try? self.dataController.context.save()
                
                self.mapView.removeAnnotation(annotation)
                self.mapView.addAnnotation(annotation)
                
            }
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is FlickrAnnotation else { return nil }
        
        let a = annotation as! FlickrAnnotation
        
        let identifier = "pin"
        
        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        
        if pin == nil {
            pin = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        let marker = pin as! MKMarkerAnnotationView
        
            if a.cnt<0 {
                a.title = "loading..."
                marker.markerTintColor = .orange
                
            } else if a.cnt == 0 {
              a.title = "no photos"
                marker.markerTintColor = .gray
            } else {
                a.title = "\(a.cnt) photos"
                marker.markerTintColor = .red
            }
        
        marker.canShowCallout = true
        marker.rightCalloutAccessoryView = UIButton(type: .infoDark)
       
        
        
        return marker
        
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("you tapped me")
        
    }
    
    func addPinToMap(pin:Pin) {
        let annotation = FlickrAnnotation(withCoordinate: pin.coordinates, title: pin.title, subtitle: nil)
        
        annotation.setCount(Int(pin.photosCount))
        annotation.cnt = Int(pin.photosCount)
        
        print("this count is \(pin.photosCount)")
        
        
        mapView.addAnnotation(annotation)
    }
}

class FlickrAnnotation:NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var cnt:Int = -1
    
    init(withCoordinate: CLLocationCoordinate2D, title: String?, subtitle: String? ) {
        self.coordinate = withCoordinate
        self.title = title
        self.subtitle = subtitle
    }
    func setCount(_ count:Int) {
        self.cnt = count
        
    }
   
    
    
}

