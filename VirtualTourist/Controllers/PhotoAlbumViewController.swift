//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Sergey Krivov on 09.09.15.
//  Copyright (c) 2015 Sergey Krivov. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //Pin from MapViewController
    var pin: Pin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup map view
        mapView.delegate = self
        mapView.userInteractionEnabled = false
        mapView.addAnnotation(pin)
        
        //set center for map view
        let region = MKCoordinateRegionMakeWithDistance(pin.coordinate, 20000, 20000)
        mapView.region = region
    }

    @IBAction func getNewCollection(sender: UIBarButtonItem) {
        println("getNewCollection")
    }
    
    //=====================================================================
    //MARK: Core Data
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    // fetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        //Create fetch request for photos which match the sent Pin.
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        fetchRequest.sortDescriptors = []
        
        //Create fetched results controller with the new fetch request.
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
        }()
}
