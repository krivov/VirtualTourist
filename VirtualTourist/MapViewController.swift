//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Sergey Krivov on 08.09.15.
//  Copyright (c) 2015 Sergey Krivov. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var deleteAlert: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    var isEditButtonTapped = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set mapView delegate
        mapView.delegate = self
        
        self.deleteAlert.hidden = true
    }
    
    @IBAction func longPress(sender: UILongPressGestureRecognizer) {
        println("longPress")
    }

    @IBAction func editButtonTapped(sender: UIBarButtonItem) {
        println("editButtonTapped")
        
        if isEditButtonTapped {
            navigationItem.rightBarButtonItem?.title = "Edit"
            self.deleteAlert.hidden = true
            self.isEditButtonTapped = false
        } else {
            navigationItem.rightBarButtonItem?.title = "Done"
            self.deleteAlert.hidden = false
            self.isEditButtonTapped = true
        }
    }

}

