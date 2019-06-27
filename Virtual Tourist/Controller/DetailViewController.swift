//
//  DetailViewController.swift
//  Virtual Tourist
//
//  Created by Ahmad Al-Mutawa on 25/06/2019.
//  Copyright © 2019 Ahmad Apps. All rights reserved.
//

import UIKit

class DetailViewController:UIViewController , UICollectionViewDelegate, UICollectionViewDataSource {
    var photos = [Photo]()
    
    
    @IBOutlet weak var noPhotosLabel: UILabel!
    override func viewWillAppear(_ animated: Bool) {
        noPhotosLabel.isHidden = photos.count > 0
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FlickrCollectionViewCell
        
        cell.photo = photos[indexPath.item]
        
        return cell
    }
    
    
}
