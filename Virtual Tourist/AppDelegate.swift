//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by Ahmad Al-Mutawa on 6/17/19.
//  Copyright © 2019 Ahmad Apps. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let dataController = DataController(modelName: Constants.modelName )


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        dataController.load ()
        // injectnig the CoreData container/context to the main view controller
        let nvc = window?.rootViewController as! UINavigationController
        let mvc = nvc.topViewController as! MapViewController
        mvc.dataController = dataController
        
        
        return true
    }


    func applicationDidEnterBackground(_ application: UIApplication) {
        // app is now in the background. Better save the map location and zoom
        saveDefaults()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // app is about to be terminated. Better save the map location and zoom
        saveDefaults()
    }
    
    func saveDefaults() {
        // check if the root view controller IS a navigation controller,
        // and that its first child is a MapViewController
        if let nvc = window?.rootViewController as? UINavigationController, let mvc = nvc.children[0] as? MapViewController {
            // call the save method of that controller
            mvc.saveCurrentLocationAndZoom()
            
        }
    }


}

