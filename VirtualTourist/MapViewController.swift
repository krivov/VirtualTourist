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
        
        //hide alert for delete pins
        self.deleteAlert.hidden = true
        
        // Load all pre-saved Pins from CoreData
        mapView.addAnnotations(fetchAllPins())
        
        //load previous map view region properties
        self.loadMapViewRegion()
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
    
    // fetch all pins from CoreData
    func fetchAllPins() -> [Pin] {
        
        let error: NSErrorPointer = nil
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        let results = sharedContext.executeFetchRequest(fetchRequest, error: error)
        
        if error != nil {
            showAlertWithTitleAndRetry("Error",
                message: "There was an error getting your saved Pins",
                retryFetchPhotos: false)
        }
        
        return results as! [Pin]
    }
    
    // fetch all photos for a selected Pin
    func fetchPhotosForPin(pin: Pin) {
        
        FlickrClient.sharedInstance().downloadPhotosForPin(pin, completionHandler: {
            success, error in
            
            if success {
                
                //save the new Photo to Core Data
                dispatch_async(dispatch_get_main_queue(), {
                    CoreDataStackManager.sharedInstance().saveContext()
                })
            } else {
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.showAlertWithTitleAndRetry("Error",
                        message: "There was an error with downloading pictures",
                        retryFetchPhotos: true)
                })
            }
        })
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
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        //Use dequeued pin annotation view if available, otherwise create a new one
        if let annotation = annotation as? Pin {
            
            let identifier = "Pin"
            var view: MKPinAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = false
                view.animatesDrop = true
                view.draggable = false
            }
            
            return view
        }
        
        return nil
    }
    
    // ====================================================================================
    // MARK: - Some helper functions
    
    var lastDroppedPin: Pin? = nil
    var pinToBeAdded: Pin? = nil
    
    //long press for add new Pin
    @IBAction func longPress(sender: UILongPressGestureRecognizer) {
        
        // extract coordinate from the tapped point
        let tappedPoint: CGPoint = sender.locationInView(mapView)
        let touchMapPoint: CLLocationCoordinate2D = mapView.convertPoint(tappedPoint, toCoordinateFromView: mapView)
        
        // add tapped pin to mapView and save it to CoreData
        switch sender.state {
            
            //init a new Pin
        case UIGestureRecognizerState.Began:
            pinToBeAdded = Pin(coordinate: touchMapPoint, context: sharedContext)
            mapView.addAnnotation(pinToBeAdded)
            
            //user drags the pin - update the location of the pin and the coordinate property of the Pin model
        case UIGestureRecognizerState.Changed:
            pinToBeAdded!.willChangeValueForKey("coordinate")
            pinToBeAdded!.coordinate = touchMapPoint
            pinToBeAdded!.didChangeValueForKey("coordinate")
            
            //save Pin to Core Data.
        case UIGestureRecognizerState.Ended:
            lastDroppedPin = pinToBeAdded
            fetchPhotosForPin(pinToBeAdded!)
            CoreDataStackManager.sharedInstance().saveContext()
            
        default:
            return
        }
    }
    
    //show alert
    func showAlertWithTitleAndRetry(title: String, message: String, retryFetchPhotos: Bool) {
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: UIAlertActionStyle.Default,
                handler: {
                    action in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                }
            )
        )
    
        
        if retryFetchPhotos {
            
            alert.addAction(
                UIAlertAction(
                    title: "Retry",
                    style: UIAlertActionStyle.Destructive,
                    handler: {
                        action in
                        self.fetchPhotosForPin(self.lastDroppedPin!)
                        alert.dismissViewControllerAnimated(true, completion: nil)
                    }
                )
            )
        }
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    

}

