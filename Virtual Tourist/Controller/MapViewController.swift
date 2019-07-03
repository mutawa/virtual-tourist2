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
            let span = MKCoordinateSpan(latitudeDelta: spanLatitudeDelta, longitudeDelta: spanLongitudeDelta)
            let region = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(region, animated: false)
        }
    }
    
    @objc func mapTapped(sender : UILongPressGestureRecognizer) {
        
        // only trigger adding a pin if the gesture began, to avoid
        // adding multiple pins on the same location
        
        if sender.state == .began {
            let locationInMap = sender.location(in: mapView)
            let coordinate = mapView.convert(locationInMap, toCoordinateFrom: mapView)
            
            // create a new Pin object in CoreDate
            let newPin = Pin(context: dataController.context)
            newPin.coordinates = coordinate
            
            // create a new Annotation marker object and add it on the map
            let annotation = FlickrAnnotation(fromPin: newPin)
            self.mapView.addAnnotation(annotation)
            
            // since we are about to call the API, we better
            // display the spinner activity indicator
            self.showActivityIndicator()
            
            FlickrAPI.shared.select(location: coordinate) { result,errorMessage in
                // we are back from the API call. let's first hide the spinner activity indicator
                // before we do anything else
                self.hideActivityIndicator()
                
                // newPin's isLoading property is TRUE by default,
                // so it's time to set it to false
                newPin.isLoading = false
                
                // check if we have a result from the API
                guard let result = result else {
                    // we don't. So let's remove the annotation that we added earlier
                    self.mapView.removeAnnotation(annotation)
                    
                    // and inform the user about it
                    self.alert(title: "Can't select location", message: errorMessage ?? "--")
                    return
                }
                
                // ensure that we have less than or equal the maximum number of photos to pull from the API
                let totalPhotos = min( Constants.maximumNumberOfPhotosToPull , Int(result.total) ?? 0)
                
                // update the newPin title
                newPin.title = "\(totalPhotos) photos"
                
                
                // iterate through all photo objects returned by the API
                // NOTICE: the returned results only contains information that
                //         will be used to construct URLs. No actual image data
                //         is downloaded at this point. Only urls.
                //         This is useful, if we need to limit traffic between
                //         the view controller and the API.
                //         Plus, we will make use of the count of image URLs obtained
                for flickrPhoto in result.photos {
                    // create a new Photo Object in CoreData
                    let photo = Photo(context: self.dataController.context)
                    
                    // link it to the newly created Pin
                    photo.pin = newPin
                    
                    // populate the photo object with the url obtained from the API
                    photo.urlString = flickrPhoto.url
                }
                
                // save CoreData context
                self.saveContext()
                
                // for some reason, the title of the annotation will not be updated
                // unless I remove the annotation and add it back again
                self.mapView.removeAnnotation(annotation)
                self.mapView.addAnnotation(annotation)
                
                
            }
        }
        
    }
    
    func saveContext() {
        // only save if there are changes in the context
        if dataController.context.hasChanges {
            do {
                try self.dataController.context.save()
            } catch {
                alert(title: "Could not save", message: "An error occured while trying to save data. \(error.localizedDescription)")
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // ensure the annotation passed is a FlickrAnnotation
        guard annotation is FlickrAnnotation else { return nil }
        
        let flickrAnnotation = annotation as! FlickrAnnotation
        
        
        // first check if we can re-use an existing view
        var reuseAnnotation = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.FlickrAnnotationIdentifier)
        
        // if we can't then let's go ahead and create a new one
        if reuseAnnotation == nil {
            reuseAnnotation = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: Constants.FlickrAnnotationIdentifier)
            reuseAnnotation?.canShowCallout = true
            reuseAnnotation?.rightCalloutAccessoryView = UIButton(type: .infoLight)
        }
        
        // cast the re-use view to MarkerAnnotationView to access .rightCalloutAccessoryView
        // and .markerTintColor
        let annotationView = reuseAnnotation as! MKMarkerAnnotationView
        
        if flickrAnnotation.pin.isLoading {
            // the pin is a new pin and a call to the API is in progress
            flickrAnnotation.title = "loading..."
            annotationView.markerTintColor = .orange
        } else {
            // the pin is an existing pin
            // we will check the count of photos objects it has
            let count = flickrAnnotation.pin.photos!.count
            
            if count == 0 {
                flickrAnnotation.title = "no photos"
                annotationView.markerTintColor = .gray
            } else if(count>0) {
                // "1 photo", "2 photos", etc
                let countString = "\(count) photo" + ( (count>1) ? "s" :  "")
                
                flickrAnnotation.title = countString
                annotationView.markerTintColor = .red
            } else {
                // count can never be a negative value
                fatalError("Invalid negative count for annotation")
            }
        }
        
        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // make sure the tapped annotation is of type FlickrAnnotation
        guard let flickrAnnotation = view.annotation as? FlickrAnnotation else { return }
        
        // IT IS... move to PhotoAlbum view controller
        performSegue(withIdentifier: Constants.photoAlbumSegueIdentifier , sender: flickrAnnotation)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // de-select the previously selected annotation to hide its callout
        mapView.deselectAnnotation(selectedAnnotation, animated: true)
        
        // update the title of the annotation since the user might have deleted some of its photos
        self.selectedAnnotation?.title = selectedAnnotation?.pin.photoCountString
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // make sure the destination is a PhotoAlbum view Controller
        guard let pavc = segue.destination as? PhotoAlbumViewController else { return }
        guard let annotation = sender as? FlickrAnnotation else { return }
        
        // set it's properties
        pavc.region = self.mapView.region
        pavc.pin = annotation.pin
        
        // tell the next view controller what code to execute if the user
        // decides to delete the entire pin
        pavc.deleteAnnotationAction = { [weak self] in
            self?.mapView.removeAnnotation(annotation)
        }
        
        // keep a pointer to the selected annotation, in-case it's photos count
        // changed (by the user) so that we may easily update its title
        self.selectedAnnotation = annotation
    }
    
    
    func addExistingPinsToMap() {
        for pin in self.pins {
            let annotation = FlickrAnnotation(fromPin: pin)
            mapView.addAnnotation(annotation)
        }
    }
    
    func showActivityIndicator() {
        view.addSubview(spinner)
        spinner.startAnimating()
    }
    
    func hideActivityIndicator() {
        // make sure we are on the main DispatchQueue since we are affecting the UI
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            self.spinner.removeFromSuperview()
        }

    }
}

