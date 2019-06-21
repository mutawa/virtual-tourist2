//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Ahmad Al-Mutawa on 6/21/19.
//  Copyright © 2019 Ahmad Apps. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    let container:NSPersistentContainer
    var context:NSManagedObjectContext { return container.viewContext }
    
    
    init(modelName:String) {
        container = NSPersistentContainer(name: modelName)
    }
    
    func load(completionHandler:(()->())?=nil) {
        container.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError("Could not load persistant Store")
                
            }
            completionHandler?()
            
        }
    }
}
