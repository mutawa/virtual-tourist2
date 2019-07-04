//
//  Constants.swift
//  Virtual Tourist
//
//  Created by Ahmad Al-Mutawa on 02/07/2019.
//  Copyright © 2019 Ahmad Apps. All rights reserved.
//

import Foundation

struct Constants {
    
    // For use in UserDefaults
    static let centerLatitude = "map.region.center.latitude"
    static let centerLongitude = "map.region.center.longitude"
    static let spanLatitude = "map.region.span.latitude"
    static let spanLongitude = "map.region.span.longitude"
    
    // For use ion FlickrAPI
    static let FlickrApiKey = "03ad452ca7fc8e5b98cda18df0c68d7b"
    static let FlickrApiSecret = "2c1ac02addba8a2f"
    static let maximumNumberOfPhotosToPull = 70
    
    // AlbumViewController CollectionView settings
    static let maximumNumberofPhotosInAlbumCollection = 16
    static let zoomLatitudeDelta = 9.0
    static let zoomLongitudeDelta = 16.0
    
    // For use in CoreData FetchRequest SortDescriptor
    static let modelName = "FlickrModel"
    static let sortPinsBy = "title"
    
    // Re-use identifiers
    static let FlickrAnnotationIdentifier = "pin"
    static let FlickrCollectionViewCellReuseIdentifier = "cell"
    
    // Custom dictionary keys for use in prepareForSegue
    static let FlickrCustomCellDictionaryCellKey = "cell"
    static let FlickrCustomCellDictionaryIndexPathKey = "indexPath"
    
    // Segue identifiers
    static let photoAlbumSegueIdentifier = "show album"
    static let photoViewControllerSegueIdentifier = "show image"
    
    // Image place holders to be used in PhotoAlbumViewController
    static let CustomCellDefaultImagePlaceHolderName = "image-placeholder"
    static let CustomCellErrorImagePlaceHolderName = "error-placeholder"
    
    
    
    
}
