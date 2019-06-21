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
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

