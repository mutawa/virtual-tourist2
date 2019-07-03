//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Ahmad Al-Mutawa on 25/06/2019.
//  Copyright © 2019 Ahmad Apps. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class PhotoAlbumViewController:UIViewController , UICollectionViewDelegate, UICollectionViewDataSource {
    
    // the array that holds a reference to all photos on screen
    // if the photo has not been loaded yet, it will be loaded
    // as soon as it is assigned to the photoCell UI on the collection view
    var onScreenPhotos = [Photo]()
    
    // this will hold all photos objects (loaded or not)
    // everytime the [New Collection] button is tapped,
    // a new bunch of photos are pulled from this array to the onScreenPhotos array
    var allPhotos = [Photo]()
    
    // CoreData context for saving changes as the user deletes photos
    var context:NSManagedObjectContext!
    
    // Pin object passed from MapViewController containing all photos URLs/image data
    var pin:Pin! {
        didSet {
            context = pin.managedObjectContext
        }
    }
    
    
    // Map region to set the mapView to (zoom, area)
    var region:MKCoordinateRegion!
    
    // Action set by MapViewController for when the user deletes the entire album
    // it will perform code that only makes sense in the context of the mapViewController
    var deleteAnnotationAction : (()->())?
    
    // We don't want to display an alert for each image that fails to load
    // so we control that by this variable
    var didDisplayErrorMessageOnce = false
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var collectionView:UICollectionView!
    
    @IBOutlet weak var noPhotosLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the layout flow, cell width/height, spacing, etc
        configureCollectionView()
        
        // sort the photos objects so that they are not in a random order each time
        // the view controller is loaded
        preparePhotosArrays()
        
        // get a bunch of photos from allPhotos array into onScreenPhotos
        loadNewCollection()
        
        // set the range/area/zoom as passed in from MapViewController
        configureMapView()
        
        // assign our self as delegate to the FlickrCollectionViewCell
        // so that we get notified if the Cell could not load a certain image
        FlickrCollectionViewCell.delegate = self
        
        // Add a Delete button to enable Deleting the entire Pin/Album
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash,
                                                                 target: self, action: #selector(deletePinTapped))
        
        
    }
    
    func configureCollectionView() {
        let width = min( view.frame.size.width, view.frame.size.height)
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.itemSize = CGSize(width: width/3, height: width/3)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
    }
    
    func preparePhotosArrays() {
        allPhotos = pin.photos?.allObjects as! [Photo]
        
        // Photo object from CoreData only has 2 properties, urlString and data.
        // So it is more effiecient to sort by urlString
        allPhotos.sort { return $0.urlString! < $1.urlString! }
    }
    
    func configureMapView() {
        mapView.region = region
        // zoom a little bit
        mapView.region.span = MKCoordinateSpan(latitudeDelta: Constants.zoomLatitudeDelta, longitudeDelta: Constants.zoomLongitudeDelta)
        
        // this MapView is not for the user to interact with.
        // it is only to show where the photos are taken from
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        
        // create an annotation marker to place on the map
        let annotation = MKPointAnnotation()
        annotation.coordinate = pin.coordinates
        
        // add the annotation to the map
        mapView.addAnnotation(annotation)
        
        // make sure the annotation is visible on the map,
        // without having to scroll to it
        mapView.setCenter(annotation.coordinate, animated: false)
        
    }
    
    @objc func deletePinTapped() {
        
        //let context = pin.managedObjectContext
        context.delete(pin)
        
        if saveChanges() {
            // changes are saved successfully
            deleteAnnotationAction?()
            navigationController?.popViewController(animated: true)
        }
        
        // no need for an else branch,
        // since if saveChanges() fails, it will display an alert
        
    }
    
    deinit {
        // before the view controller leaves the heap, let's unsubscribe from the
        // FlickrCollectionViewCell Delegate so that it does not prevent the view
        // from leaving the heap
        FlickrCollectionViewCell.delegate = nil
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if onScreenPhotos.count > 0  {
            // we have photos on screen
            noPhotosLabel.isHidden = true
        } else {
            // no photos on screen, display the [No Images] label
            noPhotosLabel.isHidden = false
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return onScreenPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.FlickrCollectionViewCellReuseIdentifier, for: indexPath) as! FlickrCollectionViewCell
        
        // setting the .photo property of the custom cell
        // will trigger the didSet observer and initiate
        // the UI configuration methods
        cell.photo = onScreenPhotos[indexPath.item]
        
        
        return cell
    }
    
    @IBAction func newCollectionButtonTapped(_ sender: UIButton) {
        
        loadNewCollection()
        
    }
    
    func loadNewCollection() {
        
        // we need a flag to check if we were able to save to CoreData (true by default)
        var saveWasSuccessful = true
        // first, clear the ones on the screen
        if onScreenPhotos.count > 0 {
            
            for photo in onScreenPhotos {
                // delete the photo reference from allPhoto array as well
                // since each time we delete the element at position zero,
                // the next element takes its place, we just delete the
                // first element how many number of times as the number
                // of elements in the onScreenPhotos array
                // and we know they mach becuse they came from that array
                // in the first place
                allPhotos.remove(at: 0)
                
                // delete from CoreData store as well
                context.delete(photo)
            }
            // save changes to CoreData
            saveWasSuccessful = saveChanges()
            
            onScreenPhotos.removeAll()
        }
        
        
        if saveWasSuccessful {
            
            if allPhotos.count > 0 {
                // maximum number in collection might be more than the available photos
                // so we take the minimum of these 2 numbers
                let countTo = min( Constants.maximumNumberofPhotosInAlbumCollection ,allPhotos.count)
                
                // if allPhotos contain more images than the number of photos on screen, then show the [New Collection] button
                // otherwise, hide it
                newCollectionButton.isHidden = (countTo >= allPhotos.count)
                
                // set the contents of onScreenPhotos array to the slice of allPhoto from [0..n]
                onScreenPhotos = Array(allPhotos[0..<countTo])
                
                // refresh collection view
                collectionView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // the user tapped on a cell. Make sure the cell is a custom cell
        if let cell = collectionView.cellForItem(at: indexPath) as? FlickrCollectionViewCell {
            
            // before we perform the segue, we need to prepare some data
            // we need a reference to the cell that was tapped to grab its Pin object
            // and we also need the indexPath so that we can remove it from the collectionview
            // if the user decides to delete the photo
            let dictionary:[String:Any] = [ Constants.FlickrCustomCellDictionaryCellKey  : cell,
                                            Constants.FlickrCustomCellDictionaryIndexPathKey : indexPath]
            
            performSegue(withIdentifier: Constants.photoViewControllerSegueIdentifier , sender: dictionary)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // validate the segue identifier, destination
        // and make sure (sender) is the passed-in dictionary
        // then unpack its contents
        
        if segue.identifier == Constants.photoViewControllerSegueIdentifier,
            let dictionary = sender as? [String:Any],
            let cell = dictionary[ Constants.FlickrCustomCellDictionaryCellKey] as? FlickrCollectionViewCell ,
            let indexPath = dictionary[Constants.FlickrCustomCellDictionaryIndexPathKey] as? IndexPath {
            
            if let pvc = segue.destination as? PhotoViewController {
                
                // set the image property to display the selected image enlarged
                pvc.image = cell.imageView.image
                
                // setting the delete action so that the code runs in this context
                pvc.deletePhotoAction = { [weak self] in
                    
                    // remove the deleted images from onScreenPhotos
                    self?.onScreenPhotos.remove(at: indexPath.item)
                    // remove it from allPhotos as well
                    self?.allPhotos.remove(at: indexPath.item)
                    
                    // update the title of the pin
                    self?.pin.title = self?.pin.photoCountString
                    
                    self?.context.delete(cell.photo)
                    
                    // only reload Collection view if the savechanges returned true
                    // and self is not nil to avoid wasting resources
                    if self?.saveChanges() ?? false {
                        self?.collectionView.reloadData()
                    }
                }
            }
        }
        
        
    }
    
    func saveChanges() -> Bool {
        // only save when there are changes
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                alert(title: "Could not save", message: "There was an error while trying to save data. \(error.localizedDescription)")
                return false
            }
        }
        return true
    }
    
    
}

// Implementing and Conforming to FlickrCollectionViewCell Delegate
extension PhotoAlbumViewController:FlickrCollectionViewCellDelegate {
    func didStartLoadingFromAPI() {
        
        // hide the [New Collection] Button until loading from the API is done
        DispatchQueue.main.async { [weak self] in
            self?.newCollectionButton.isHidden = true
        }
        
    }
    
    func didFinishLoadingFromAPI() {
        // loading from API is done.
        DispatchQueue.main.async {
            
            // let's check if there are more photos to pull from the array of URLs
            if self.allPhotos.count > self.onScreenPhotos.count {
                self.newCollectionButton.isHidden = false
            } else {
                self.newCollectionButton.isHidden = true
            }
            
        }
        
    }
    
    
    // only one method is required:
    func cellLoadErrorOccured(errorMessage: String) {
        
        // this method will be triggered multiple times by the delegate,
        // we don't want to display 100 alerts to the user on Each And Every error
        
        if !didDisplayErrorMessageOnce {
            self.alert(title: "Could not load image", message: errorMessage)
            didDisplayErrorMessageOnce = true
        }
        
    }
    
}
