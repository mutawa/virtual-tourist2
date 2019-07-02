//
//  DetailViewController.swift
//  Virtual Tourist
//
//  Created by Ahmad Al-Mutawa on 25/06/2019.
//  Copyright © 2019 Ahmad Apps. All rights reserved.
//

import UIKit

class DetailViewController:UIViewController , UICollectionViewDelegate, UICollectionViewDataSource {
    var allPhotos = [Photo]()
    var photos = [[Photo]]()
    var pin:Pin!
    var deletePinAction : (()->())?
    var didDisplayErrorMessageOnce = false
    
    @IBOutlet weak var loadMoreButton: UIButton!
    @IBOutlet weak var collectionView:UICollectionView!
    
    @IBOutlet weak var noPhotosLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = min( view.frame.size.width, view.frame.size.height)
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.itemSize = CGSize(width: (width-40-20)/3, height: (width-40-20)/3)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        allPhotos = pin.photos?.allObjects as! [Photo]
        FlickrCollectionViewCell.delegate = self
        
        addSection()
        
        if photos.count > 0 && photos[0].count > 0 {
            noPhotosLabel.isHidden = true
        } else {
            noPhotosLabel.isHidden = false
        }
        
        
    }
    
    deinit {
        FlickrCollectionViewCell.delegate = nil
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        

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
        var count = 0
        let total = allPhotos.count
        for section in photos {
            for _ in section {
                count += 1
            }
        }
        
        if total > count {
            // check if count+9 is within total
            var countTo = count + 9
            var numberOfItems = 0
            if countTo >= total {
                countTo = total
                numberOfItems = total - count
                loadMoreButton.isHidden = true
            } else {
                numberOfItems = 9
                loadMoreButton.isHidden = false
            }
            
            let newSection = Array(allPhotos[count..<countTo])
            
            photos.append(newSection)
            // todo: insertSections causes the app to crash
            //       need to find a better way
            // collectionView.insertSections(IndexSet(integer: collectionView.numberOfSections ))
            
            // solution is expensive, but works for now
            
            collectionView.reloadData()
            collectionView.scrollToItem(at: IndexPath(item: numberOfItems-1, section: collectionView.numberOfSections-1), at: .bottom, animated: true)
            
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? FlickrCollectionViewCell {
            performSegue(withIdentifier: "show image", sender: cell)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show image", let cell = sender as? FlickrCollectionViewCell {
            if let ivc = segue.destination as? ImageViewController {
                ivc.image = cell.imageView.image
                
            }
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        let context = pin.managedObjectContext
        context?.delete(pin)
        try? context?.save()
        deletePinAction?()
        
        
        navigationController?.popViewController(animated: true)
        
    }
    
}

extension DetailViewController:FlickrCollectionViewCellDelegate {
    func cellLoadErrorOccured(errorMessage: String) {
        if !didDisplayErrorMessageOnce {
            self.alert(title: "Could not load image", message: errorMessage)
            didDisplayErrorMessageOnce = true
        }
        
    }
    
  
}
