//
//  ImageViewController.swift
//  Virtual Tourist
//
//  Created by Ahmad Al-Mutawa on 27/06/2019.
//  Copyright © 2019 Ahmad Apps. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    var image:UIImage!
    @IBOutlet weak private var imageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        configureUI()
    }
    
    func configureUI() {
        imageView.image = image
    }
}
