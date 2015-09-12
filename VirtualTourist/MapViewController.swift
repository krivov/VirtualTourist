//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Sergey Krivov on 08.09.15.
//  Copyright (c) 2015 Sergey Krivov. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var deleteAlert: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    var isEditButtonTapped = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set mapView delegate
        mapView.delegate = self
        
        self.deleteAlert.hidden = true
        
        self.loadMapViewRegion()
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
    
    // ====================================================================================
    // MARK: - Core Data
    
    // CoreData sharedContext
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    // ====================================================================================
    // MARK: - NSUserDefaults constants and methods
    
    let CenterLatitudeMapView     = "Center Latitude"
    let CenterLongitudeMapView    = "Center Longitude"
    let SpanLatitudeDeltaMapView  = "Span Latitude Delta"
    let SpanLongitudeDeltaMapView = "Span Longitude Delta"
    
    //Save mapView region properties to NSUserDefaults
    func saveMapViewRegion() {
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.center.latitude, forKey: CenterLatitudeMapView)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.center.longitude, forKey: CenterLongitudeMapView)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.latitudeDelta, forKey: SpanLatitudeDeltaMapView)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.longitudeDelta, forKey: SpanLongitudeDeltaMapView)
    }
    
    //Reload mapView region properties from NSUserDefaults
    func loadMapViewRegion() {
        
        //if mapView region properties exist in NSUserDefaults - zoom map to save location
        let centerLatitude = NSUserDefaults.standardUserDefaults().doubleForKey(CenterLatitudeMapView)
        
        if centerLatitude != 0 {
            
            //Get all map view region properties
            let centreLongitude = NSUserDefaults.standardUserDefaults().doubleForKey(CenterLongitudeMapView)
            let spanLatitudeDelta = NSUserDefaults.standardUserDefaults().doubleForKey(SpanLatitudeDeltaMapView)
            let spanLongitudeDelta = NSUserDefaults.standardUserDefaults().doubleForKey(SpanLongitudeDeltaMapView)
            
            let center = CLLocationCoordinate2DMake(centerLatitude, centreLongitude)
            let span = MKCoordinateSpanMake(spanLatitudeDelta, spanLongitudeDelta)
            
            //set properties to map view
            let region = MKCoordinateRegionMake(center, span)
            mapView.region = region
        }
    }
    
    // ====================================================================================
    // MARK: - MKMapViewDelegate implementation
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        
        //Save map view region properties
        saveMapViewRegion()
    }
}

