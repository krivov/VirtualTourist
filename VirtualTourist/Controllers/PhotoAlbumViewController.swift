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

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    //Pin from MapViewController
    var pin: Pin!
    
    //Arrays with selected, updated, deleted indexes of collection view cells
    var selectedIndexes   = [NSIndexPath]()
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths : [NSIndexPath]!
    var updatedIndexPaths : [NSIndexPath]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup map view
        mapView.delegate = self
        mapView.userInteractionEnabled = false
        mapView.addAnnotation(pin)
        
        //set center for map view
        let region = MKCoordinateRegionMakeWithDistance(pin.coordinate, 20000, 20000)
        mapView.region = region
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //initial fetch
        var error: NSError?
        fetchedResultsController.performFetch(&error)
        
        if (error != nil) {
            showAlertWithTitleAndRetry("Error", message: "Error download photos for the selected pin", retryNewPhotoSet: false)
        }
        
        //disable newCollectionButton when pin dont have images
        if fetchedResultsController.fetchedObjects?.count == 0 {
            newCollectionButton.enabled = false
        }
    }

    @IBAction func getNewCollection(sender: UIBarButtonItem) {
        println("getNewCollection")
    }
    
    //show alert
    func showAlertWithTitleAndRetry(title: String, message: String, retryNewPhotoSet: Bool) {
        
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
        
        
        if retryNewPhotoSet {
            
            alert.addAction(
                UIAlertAction(
                    title: "Retry",
                    style: UIAlertActionStyle.Destructive,
                    handler: {
                        action in
                        
                        alert.dismissViewControllerAnimated(true, completion: nil)
                    }
                )
            )
        }
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //change alpha when select cell
    func selectCell(cell: PhotoCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        
        //If the user has selected a cell, grey it out...
        if let index = find(selectedIndexes, indexPath) {
            
            UIView.animateWithDuration(0.1,
                animations: {
                    cell.imageView.alpha = 0.5
            })
        } else {
            
            //...otherwise show it clearly.
            UIView.animateWithDuration(0.1,
                animations: {
                    cell.imageView.alpha = 1.0
            })
        }
    }
    
    //update text bottom button
    func updateBottomButton() {
        if selectedIndexes.count > 0 {
            newCollectionButton.title = "Delete Selected Images";
        } else {
            newCollectionButton.title = "New Collection";
        }
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
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        //Set indexes for changed content from Core Data
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths  = [NSIndexPath]()
        updatedIndexPaths  = [NSIndexPath]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        //add indexPath to appropriate array with type of change
        switch type {
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
        case .Delete:
            deletedIndexPaths.append(indexPath!)
        case .Update:
            updatedIndexPaths.append(indexPath!)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        //Check to make sure UI elements are correctly displayed.
        if controller.fetchedObjects?.count > 0 {
            newCollectionButton.enabled = true
        }
        
        //Make the relevant updates to the collectionView once Core Data has finished its changes.
        collectionView.performBatchUpdates({
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
    }
    
    //=====================================================================
    //MARK: UICollectionView
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //Get section info from the fetched results controller...
        if let sectionInfo = self.fetchedResultsController.sections?[section] as? NSFetchedResultsSectionInfo {
            return sectionInfo.numberOfObjects
        }
        
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        //get reuse cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        //update cell properties
        if photo.image != nil {
            
            cell.activityIndicatorView.stopAnimating()
            cell.imageView.alpha = 0.0
            cell.imageView.image = photo.image
            
            UIView.animateWithDuration(0.2,
                animations: { cell.imageView.alpha = 1.0 })
        }
        
        //modify cell if user select it
        self.selectCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCollectionViewCell
        
        //dont select if the cell is waiting image
        if cell.activityIndicatorView.isAnimating() {
            return false
        }
        
        return true
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        //Get cell and photo associated with the indexPath.
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCollectionViewCell
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        // If photo image failed to download before, retry download here.
        if photo.filePath == "error" {
            
            //UI changes to indicate activity.
            cell.activityIndicatorView.startAnimating()
            cell.imageView.alpha = 0.0
            cell.imageView.image = nil
            
            //retryImageDownloadForPhoto(photo)
            return
        }
        
        //If the user touches a cell, add or remove it from the selectedIndexes array...
        if let index = find(selectedIndexes, indexPath) {
            
            selectedIndexes.removeAtIndex(index)
        } else {
            
            selectedIndexes.append(indexPath)
        }
        
        //update selected cell
        selectCell(cell, atIndexPath: indexPath)
        
        //update bottom button
        updateBottomButton()
    }

}
