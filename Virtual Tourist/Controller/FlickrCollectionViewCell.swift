//
//  FlickrCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Ahmad Al-Mutawa on 25/06/2019.
//  Copyright © 2019 Ahmad Apps. All rights reserved.
//

import UIKit


protocol FlickrCollectionViewCellDelegate : class {
    func cellLoadErrorOccured(errorMessage:String)
    func didStartDownloadingFromAPI()
    func didFinishDownloadingFromAPI()
    
}


class FlickrCollectionViewCell:UICollectionViewCell {
    static weak var delegate : FlickrCollectionViewCellDelegate?
    
    @IBOutlet weak var imageView:UIImageView!
    var photo:Photo! {
        didSet{
            configureUI()
        }
    }
    
    func configureUI() {
        
        self.imageView.image = UIImage(named: "imagePlaceholder")
        if photo.data == nil {
            FlickrCollectionViewCell.delegate?.didStartDownloadingFromAPI()
            
            photo.load { [weak self] data,errorMessage in
                guard errorMessage == nil else {
                    FlickrCollectionViewCell.delegate?.didFinishDownloadingFromAPI()
                    FlickrCollectionViewCell.delegate?.cellLoadErrorOccured(errorMessage: errorMessage!)
                    return
                }
                
                self?.photo.data = data
                try? self?.photo.managedObjectContext?.save()
                FlickrCollectionViewCell.delegate?.didFinishDownloadingFromAPI()
                DispatchQueue.main.async {
                    self?.imageView.image = self?.photo.image!
                }
            }
        } else {
            self.imageView.image = photo.image
        }
        self.layer.cornerRadius = 3
        self.layer.masksToBounds = true
        self.layer.borderWidth = 0.25
        self.imageView.contentMode = .scaleAspectFill
        
        
    }
    
    
}
