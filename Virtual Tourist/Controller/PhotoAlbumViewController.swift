//
//  DetailViewController.swift
//  Virtual Tourist
//
//  Created by Ahmad Al-Mutawa on 25/06/2019.
//  Copyright © 2019 Ahmad Apps. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController:UIViewController , UICollectionViewDelegate, UICollectionViewDataSource {
    var allPhotos = [Photo]()
    var photos = [[Photo]]()
    var pin:Pin!
    var deletePinAction : (()->())?
    var didDisplayErrorMessageOnce = false
    var region:MKCoordinateRegion!
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loadMoreButton: UIButton!
    @IBOutlet weak var collectionView:UICollectionView!
    
    @IBOutlet weak var noPhotosLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = min( view.frame.size.width, view.frame.size.height)
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.itemSize = CGSize(width: (width)/3, height: (width)/3)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        allPhotos = pin.photos?.allObjects as! [Photo]
        allPhotos.sort { return $0.id! < $1.id! }
        
        FlickrCollectionViewCell.delegate = self
        
        addSection()
        
        mapView.region = region
        mapView.region.span = MKCoordinateSpan(latitudeDelta: 9, longitudeDelta: 16)
        
        
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = pin.coordinates
        
        mapView.addAnnotation(annotation)
        mapView.setCenter(annotation.coordinate, animated: false)
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deletePinTapped))
        
        
    }
    
    @objc func deletePinTapped() {
        let context = pin.managedObjectContext
        context?.delete(pin)
        try? context?.save()
        deletePinAction?()
        
        
        navigationController?.popViewController(animated: true)
    }
    
    deinit {
        FlickrCollectionViewCell.delegate = nil
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if photos.count > 0 && photos[0].count > 0 {
            noPhotosLabel.isHidden = true
        } else {
            noPhotosLabel.isHidden = false
        }
        

        
        
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FlickrCollectionViewCell
        
        cell.photo = photos[indexPath.section][indexPath.item]
        
        
        return cell
    }
    
    @IBAction func loadMoreButtonTapped(_ sender: UIButton) {
        
        addSection()
        
    }
    
    func addSection() {
        
        if photos.count>0, photos[0].count>0 {
            let context = self.pin.managedObjectContext
            
            for (_,photo) in photos[0].enumerated() {
                
                allPhotos.remove(at: 0)
                context?.delete(photo)
            }
            try? context?.save()
            photos.remove(at: 0)
        }
        
        
        
        let total = allPhotos.count
        
        
        if total > 0 {
            
            var countTo = 9
            
            if countTo >= total {
                countTo = total
                
                loadMoreButton.isHidden = true
            } else {
                
                loadMoreButton.isHidden = false
            }
            
            photos.append(Array(allPhotos[0..<countTo]))
            
            
            
            
            collectionView.reloadData()
            //collectionView.scrollToItem(at: IndexPath(item: numberOfItems-1, section: collectionView.numberOfSections-1), at: .bottom, animated: true)
            
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? FlickrCollectionViewCell {
            let dict:[String:Any] = ["cell" : cell, "indexPath" : indexPath]
            performSegue(withIdentifier: "show image", sender: dict)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show image", let dict = sender as? [String:Any], let cell = dict["cell"] as? FlickrCollectionViewCell , let indexPath = dict["indexPath"] as? IndexPath {
            
            if let ivc = segue.destination as? PhotoViewController {
                
                ivc.image = cell.imageView.image
                ivc.deletePhotoAction = { [weak self] in
                    
                    
                    self?.photos[indexPath.section].remove(at: indexPath.item)
                    if var allPhotos = self?.allPhotos {
                        for (index,photoToDelete) in allPhotos.enumerated() {
                            if photoToDelete===cell.photo {
                                allPhotos.remove(at: index)
                                self?.pin.title = "\(allPhotos.count) photos"
                                break
                            }
                        }
                    }
                    
                    let context = self?.pin.managedObjectContext
                    context?.delete(cell.photo)
                    try? context?.save()
                    
                    
                    self?.collectionView.reloadData()
                }
            }
        }
        
        
    }
    
    
}

extension PhotoAlbumViewController:FlickrCollectionViewCellDelegate {
    
    
    func cellLoadErrorOccured(errorMessage: String) {
        if !didDisplayErrorMessageOnce {
            self.alert(title: "Could not load image", message: errorMessage)
            didDisplayErrorMessageOnce = true
        }
        
    }

}
