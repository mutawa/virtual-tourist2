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
    var image:UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
}
