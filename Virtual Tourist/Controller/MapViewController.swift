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
    
    // spinner will be displayed whenever there is a call to the API over the network
    var spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    
    // DataCore Store Container
    var dataController:DataController!
    
    // All pins displayed on the map will be stored here
    var pins:[Pin] = []
    
    // This will keep a track of which annotation the user has selected
    // This is useful if the user decides to delete the entire album of
    // the selected pin, then the annotation pin will also be removed from
    // the map
    var selectedAnnotation: FlickrAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // assign delegate, configure gesture, add selector
        configureMap()
        
        // set background color, layer corner radius, etc.
        configureSpinner()
        
        // load previously stored pins from CoreData, and place them on the map
        loadExistingPins()
        
        // load last map region and zoom from UserDefaults
        loadLocationAndZoom()
        
    }
    
    func configureMap() {
        mapView.delegate = self
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(mapTapped))
        mapView.addGestureRecognizer(gesture)
    }
    
    func configureSpinner() {
        spinner.center = view.center
        spinner.hidesWhenStopped = true
        spinner.isOpaque = true
        spinner.backgroundColor = #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 0.4626765839)
        spinner.layer.cornerRadius = 5
    }
    
    func loadExistingPins() {
        
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: Constants.sortPinsBy, ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            // populate the empty array with results from CoreData
            pins = try dataController.context.fetch(fetchRequest)
            
            // if we are still here, then no error occured. Go ahead and place
            // pins on the map
            self.addExistingPinsToMap()
        }
        catch {
            alert(title: "Could not load data",
                  message: "There was an error while loading existing pin data. \(error.localizedDescription)")
        }
        
    }
    
    func saveCurrentLocationAndZoom() {
        // save current map region to user defaults
        UserDefaults.standard.set(mapView.region.center.latitude , forKey: Constants.centerLatitude)
        UserDefaults.standard.set(mapView.region.center.longitude , forKey: Constants.centerLongitude)
        UserDefaults.standard.set(mapView.region.span.latitudeDelta  , forKey: Constants.spanLatitude)
        UserDefaults.standard.set(mapView.region.span.longitudeDelta , forKey: Constants.spanLongitude)
    }
    
    func loadLocationAndZoom() {
        // load map region from user defaults
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
            
            self.mapView.addAnnotation(annotation)
            
            self.showActivityIndicator()
            
            
            FlickrAPI.shared.select(location: coordinate) { result,errorMessage in
                self.hideActivityIndicator()
                cdpin.isLoading = false
                
                guard let result = result else {
                    self.mapView.removeAnnotation(annotation)
                    self.alert(title: "Can't select location", message: errorMessage ?? "--")
                    return }
                
                
                let totalPhotos = min(50, Int(result.total) ?? 0)
                
                
                cdpin.title = "\(totalPhotos) photos"
                
                
                
                
                for p in result.photo {
                    let photo = Photo(context: self.dataController.context)
                    photo.pin = cdpin
                    photo.urlString = p.url
                    
                    
                }
                
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
        
        if a.pin.isLoading {
            a.title = "loading..."
            marker.markerTintColor = .orange
        } else {
            let count = a.pin.photos!.count
            
            if count == 0 {
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
        let dvc = segue.destination as! PhotoAlbumViewController
        dvc.region = self.mapView.region
        
        let annotation = sender as? FlickrAnnotation
        dvc.pin = annotation?.pin
        self.selectedAnnotation = annotation
        
        dvc.deletePinAction = { [weak self] in
            self?.mapView.removeAnnotation(annotation!)
            
        }
        
        
        
    }
    
    
    func addExistingPinsToMap() {
        for pin in self.pins {
            let annotation = FlickrAnnotation(withCoordinate: pin.coordinates, title: nil, pin: pin)
            mapView.addAnnotation(annotation)
        }
    }
    
    func showActivityIndicator() {
        
        view.addSubview(spinner)
        spinner.startAnimating()
    }
    func hideActivityIndicator() {
        DispatchQueue.main.async {
        
        self.spinner.stopAnimating()
        self.spinner.removeFromSuperview()
        }
        
    }
}

