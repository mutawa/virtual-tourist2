//
//  FlickrCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Ahmad Al-Mutawa on 25/06/2019.
//  Copyright © 2019 Ahmad Apps. All rights reserved.
//

import UIKit

class FlickrCollectionViewCell:UICollectionViewCell {
    @IBOutlet weak var imageView:UIImageView!
    var photo:Photo! {
        didSet{
            configureUI()
        }
    }
    
    func configureUI() {
        
        self.imageView.image = UIImage(named: "imagePlaceholder")
        if photo.data == nil {
            photo.load { [weak self] data in
                self?.photo.data = data
                try? self?.photo.managedObjectContext?.save()
                DispatchQueue.main.async {
                    self?.imageView.image = self?.photo.image!
                }
            }
        } else {
            self.imageView.image = photo.image
        }
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1.5
        self.imageView.contentMode = .scaleAspectFill
        
        
    }
    
    
}
