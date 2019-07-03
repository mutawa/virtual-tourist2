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
    
}


class FlickrCollectionViewCell:UICollectionViewCell {
    static weak var delegate : FlickrCollectionViewCellDelegate?
    var spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    
    @IBOutlet weak var imageView:UIImageView! {
        didSet {
            configureActivityIndicator()
        }
    }
    var photo:Photo! {
        didSet{
            configureUI()
            
        }
    }
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 3
        self.layer.masksToBounds = true
        self.layer.borderWidth = 0.25
        self.imageView.contentMode = .scaleAspectFill
    }
    
    func configureUI() {
        
        self.showLoadingPlaceHolder()
        
        
        if photo.data == nil {
            
            showActivityIndicator()
            photo.load { [weak self] data,errorMessage in
                self?.hideActivityIndicator()
                guard errorMessage == nil else {
                    self?.showErrorPlaceHolder()
                    
                    FlickrCollectionViewCell.delegate?.cellLoadErrorOccured(errorMessage: errorMessage!)
                    return
                }
                
                self?.photo.data = data
                try? self?.photo.managedObjectContext?.save()
                
                DispatchQueue.main.async {
                    self?.imageView.image = self?.photo.image!
                }
            }
        } else {
            self.imageView.image = photo.image
        }
        
        
        
    }
    
    func configureActivityIndicator() {
        spinner.center = self.center
        spinner.layer.cornerRadius = 5
        spinner.color = .white
        spinner.isOpaque = false
        spinner.backgroundColor = #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 0.4446168664)
        spinner.hidesWhenStopped = true
    }
    
    func showActivityIndicator() {
        addSubview(spinner)
        spinner.startAnimating()
    }
    
    func hideActivityIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.spinner.stopAnimating()
            self?.spinner.removeFromSuperview()
        }
    }
    
    func showLoadingPlaceHolder() {
        self.imageView.image = UIImage(named: "image-placeholder")
    }
    func showErrorPlaceHolder() {
        DispatchQueue.main.async {
            self.imageView.image = UIImage(named: "error")
        }
    }
}
