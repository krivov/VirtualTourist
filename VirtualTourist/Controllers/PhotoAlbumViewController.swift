//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Sergey Krivov on 09.09.15.
//  Copyright (c) 2015 Sergey Krivov. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.userInteractionEnabled = false
    }

    @IBAction func getNewCollection(sender: UIBarButtonItem) {
        println("getNewCollection")
    }
}
