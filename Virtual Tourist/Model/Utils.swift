//
//  Utils.swift
//  Virtual Tourist
//
//  Created by Ahmad Al-Mutawa on 02/07/2019.
//  Copyright © 2019 Ahmad Apps. All rights reserved.
//

import UIKit


extension UIViewController {
    func alert(title:String, message:String) {
        let avc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        avc.addAction(okAction)
        
        present(avc, animated: true)
    }
}

