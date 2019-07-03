//
//  FlickrCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Ahmad Al-Mutawa on 25/06/2019.
//  Copyright © 2019 Ahmad Apps. All rights reserved.
//

import UIKit
import CoreData


// this protocol will be used to inform whomever is listening about any failure to load the image
protocol FlickrCollectionViewCellDelegate : class {
    // this method is useful for the viewController so that it may display an alert
    // the Custom Cell can't directly invoke an alert on the View Controller.
    func cellLoadErrorOccured(errorMessage:String)
    
    // Tells the delegate about on-going communication with the API
    // so that UI can be updated
    func didStartLoadingFromAPI()
    func didFinishLoadingFromAPI()
}


class FlickrCollectionViewCell:UICollectionViewCell {
    
    // we only need one delegate that all cells can share, hence the STATIC marker
    static weak var delegate : FlickrCollectionViewCellDelegate?
    
    // keep track of all cells that are using the API
    // this will be used to trigger the protocol didStartLoadingFromAPI and didFinishLoadingFromAPI
    static var countOfCellsThatAreUsingTheAPI: Int = 0 {
        didSet {
            if countOfCellsThatAreUsingTheAPI==0 { delegate?.didFinishLoadingFromAPI() }
            else { delegate?.didStartLoadingFromAPI() }
        }
    }
    
    // activity indicator to let user know that the cell is working on loading its image
    var spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    
    
    @IBOutlet weak var imageView:UIImageView!
    
    var context:NSManagedObjectContext!
    var photo:Photo! {
        didSet{
            // the model of this cell is configured,
            // we may start loading or setting the image
            // of the cell if it has already been loaded
            configureUI()
            
            // grab a reference to the CoreData context
            context = photo.managedObjectContext
            
            
        }
    }
    
    override func awakeFromNib() {
        // these settings are only needed
        // if the cell has been instantiated
        // and not re-used, there is no need to keep
        // setting them over and over
        
        self.layer.cornerRadius = 3
        self.layer.masksToBounds = true
        self.layer.borderWidth = 0.25
        self.imageView.contentMode = .scaleAspectFill
        
        // storyboard has loaded and configured the cell.
        // let's configure the ActivityIndicator
        
        configureActivityIndicator()
    }
    
    func configureUI() {
        
        // by default show the image placeholder
        self.showLoadingPlaceHolder()
        
        // check if an image data has been downloaded yet
        if photo.data != nil {
            self.imageView.image = photo.image
        } else {
            // no image data.. Let's download it!
            
            // first: make sure we have a valid urlString
            guard photo.urlString != nil else {
                FlickrCollectionViewCell.delegate?.cellLoadErrorOccured(errorMessage: "No url is available for this photo")
                return
            }
            
            // we have a valid urlString. Let's start downloading it
            showActivityIndicator()
            
            FlickrCollectionViewCell.countOfCellsThatAreUsingTheAPI += 1
            
            photo.load { [weak self] data,errorMessage in
                FlickrCollectionViewCell.countOfCellsThatAreUsingTheAPI -= 1
                DispatchQueue.main.async {
                    // we are back from the API network call.
                    // first, stop the activity indicator before doing anything else
                    self?.hideActivityIndicator()
                    
                    // check if we have an error
                    guard errorMessage == nil else {
                        // we do? then quickly, replace the default image placeholder with
                        // something that the user can easily identify as a problem
                        self?.showErrorPlaceHolder()
                        
                        // let the delegate know about the problem
                        FlickrCollectionViewCell.delegate?.cellLoadErrorOccured(errorMessage: errorMessage!)
                        return
                    }
                    
                    // we made it here with no errors! lets save the image data to CoreData
                    self?.photo.data = data
                    self?.saveChanges()
                    
                    // replace the placeholder with the downloaded image data
                    self?.imageView.image = self?.photo.image
                    
                } // end of DispatchQueue.main.async
            } // end of photo.load
            
        } // end of else {}
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
        // we should always manipulate UI on the main thread
        // since the spinner will be visible while we are talking
        // with the API on the background thread
        DispatchQueue.main.async { [weak self] in
            self?.spinner.stopAnimating()
            self?.spinner.removeFromSuperview()
        }
    }
    
    func showLoadingPlaceHolder() {
        self.imageView.image = UIImage(named: Constants.CustomCellDefaultImagePlaceHolderName)
    }
    func showErrorPlaceHolder() {
        DispatchQueue.main.async {
            self.imageView.image = UIImage(named: Constants.CustomCellErrorImagePlaceHolderName)
        }
    }
    
    func saveChanges() {
        // only save where there are changes
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // let the delegate know about this error (if they even care!)
                FlickrCollectionViewCell.delegate?.cellLoadErrorOccured(errorMessage: "Could not save image data. \(error.localizedDescription)")
            }
        }
    }
}
