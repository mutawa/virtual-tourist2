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
    
    var activityIndicatorView : UIActivityIndicatorView!
    
    var dataController:DataController!
    var pins:[Pin] = []
    var selectedAnnotation: FlickrAnnotation?
    
    
    
    
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
            
            self.loadPins()
        }
        catch {
            print("error fetching pins")
        }
        
        
        loadLocationAndZoom()
        
        self.activityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.view.addSubview(self.activityIndicatorView)
        
    }
    
    
    func saveCurrentLocationAndZoom() {
        
        UserDefaults.standard.set(mapView.region.center.latitude , forKey: Constants.centerLatitude)
        UserDefaults.standard.set(mapView.region.center.longitude , forKey: Constants.centerLongitude)
        UserDefaults.standard.set(mapView.region.span.latitudeDelta  , forKey: Constants.spanLatitude)
        UserDefaults.standard.set(mapView.region.span.longitudeDelta , forKey: Constants.spanLongitude)
    }
    func loadLocationAndZoom() {
        
        if let centerLatitude = UserDefaults.standard.object(forKey: Constants.centerLatitude) as? Double,
            let centerLongitude = UserDefaults.standard.object(forKey: Constants.centerLongitude) as? Double,
            let spanLatitudeDelta = UserDefaults.standard.object(forKey: Constants.spanLatitude) as? Double,
            let spanLongitudeDelta = UserDefaults.standard.object(forKey: Constants.spanLatitude) as? Double {
            
            let center = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
            let span = MKCoordinateSpan(latitudeDelta: spanLatitudeDelta * 0.999, longitudeDelta: spanLongitudeDelta * 0.999)
            let region = MKCoordinateRegion(center: center, span: span)
            mapView.region = region
            
            
            
            
        }
    }
    
    @objc func mapTapped(sender : UILongPressGestureRecognizer) {
        if sender.state == .began {
            let location = sender.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            let cdpin = Pin(context: dataController.context)
            let annotation = FlickrAnnotation(withCoordinate: coordinate, title: "loading...", pin: cdpin)
            
            cdpin.latitude = coordinate.latitude
            cdpin.longitude = coordinate.longitude
            
            
            showAcitivityIndicator()
            
            FlickrAPI.shared.select(location: coordinate) { result,errorMessage in
                guard let result = result else {
                    self.hideActivityIndicator()
                    self.alert(title: "Can't select location", message: errorMessage ?? "--")
                    return }
                
                self.mapView.addAnnotation(annotation)
                let totalPhotos = min(50, Int(result.total) ?? 0)
                
                
                cdpin.title = "\(totalPhotos) photos"
                
                
                
                
                for p in result.photo {
                    let photo = Photo(context: self.dataController.context)
                    photo.pin = cdpin
                    photo.farm = Int64(p.farm)
                    photo.server = p.server
                    photo.id = p.id
                    photo.server = p.server
                    photo.secret = p.secret
                    
                }
                
                try? self.dataController.context.save()
                
                self.mapView.removeAnnotation(annotation)
                self.mapView.addAnnotation(annotation)
                self.hideActivityIndicator()
                
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
        
        let count = a.pin.photos?.count ?? -1
        
        if count < 0 {
            a.title = "loading..."
            marker.markerTintColor = .orange
            
        } else if count == 0 {
            a.title = "no photos"
            marker.markerTintColor = .gray
        } else {
            var countString = "\(count) photo"
            
            
            if count>1 {
                countString += "s"
            }
            
            a.title = countString
            marker.markerTintColor = .red
        }
        
        marker.canShowCallout = true
        marker.rightCalloutAccessoryView = UIButton(type: .infoDark)
        
        
        
        return marker
        
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // move to detail view controller
        let flickrAnnotation = view.annotation as! FlickrAnnotation

        performSegue(withIdentifier: "details", sender: flickrAnnotation)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapView.deselectAnnotation(selectedAnnotation, animated: true)
        self.selectedAnnotation?.title = "\(self.selectedAnnotation?.pin.photos?.count ?? 0) photos"
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dvc = segue.destination as! DetailViewController
        dvc.region = self.mapView.region
        
        let annotation = sender as? FlickrAnnotation
        dvc.pin = annotation?.pin
        self.selectedAnnotation = annotation
        
        dvc.deletePinAction = { [weak self] in
            self?.mapView.removeAnnotation(annotation!)
            
        }
        
        
        
    }
    
    
    func loadPins() {
        for pin in self.pins {
            let annotation = FlickrAnnotation(withCoordinate: pin.coordinates, title: nil, pin: pin)
      
            mapView.addAnnotation(annotation)
        }
    }
}

class FlickrAnnotation:NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    let pin:Pin
    
    init(withCoordinate: CLLocationCoordinate2D, title:String?, pin: Pin) {
        self.coordinate = withCoordinate
        self.title = title
        self.pin = pin
    }

}

extension MapViewController:NetworkCallingViewController {

    
    var activityIndicator: UIActivityIndicatorView {
        return self.activityIndicatorView
    }

    
}
