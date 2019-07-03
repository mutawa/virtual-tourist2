//
//  PhotoViewController.swift
//  Virtual Tourist
//
//  Created by Ahmad Al-Mutawa on 27/06/2019.
//  Copyright © 2019 Ahmad Apps. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    var image:UIImage!
    var deletePhotoAction:(()->Void)!
    var photo:Photo!
    
    @IBOutlet weak private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deletePhotoTapped))
        
    }
    
    @objc func deletePhotoTapped() {
        deletePhotoAction()
        navigationController?.popViewController(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        configureUI()
    }
    
    func configureUI() {
        imageView.image = image
    }
}
