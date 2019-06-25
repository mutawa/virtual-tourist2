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
    
    override func viewWillAppear(_ animated: Bool) {
        
        for p in photos {
            if p.data==nil { print("loading photo...");  p.load() }
        }
        
        do {
            if let ctx = photos[0].pin?.managedObjectContext {
                if ctx.hasChanges {
                    print("saving changes")
                    try ctx.save()
                    print("saved")
                } else {
                    print("no changes to save")
                }
            }
            
        } catch { print("failed to save") }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FlickrCollectionViewCell
        cell.image = photos[indexPath.item].image
        
        return cell
    }
    
    
}
