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
    let dataController = DataController(modelName: "FlickrModel")


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        dataController.load ()
        let nvc = window?.rootViewController as! UINavigationController
        let mvc = nvc.topViewController as! MapViewController
        mvc.dataController = dataController
        
        
        return true
    }


    func applicationDidEnterBackground(_ application: UIApplication) {
        saveDefaults()
        
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveDefaults()
    }
    
    func saveDefaults() {
        
        if let nvc = window?.rootViewController as? UINavigationController, let mvc = nvc.children[0] as? MapViewController {
            mvc.saveCurrentLocationAndZoom()
            
        }
    }


}

