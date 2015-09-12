//
//  Pin.swift
//  VirtualTourist
//
//  Created by Sergey Krivov on 12.09.15.
//  Copyright (c) 2015 Sergey Krivov. All rights reserved.
//

import UIKit
import MapKit
import CoreData

@objc(Pin)

class Pin: NSManagedObject, MKAnnotation {
    
    // MARK: - Pin model properties
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var pageNumber: NSNumber?
    @NSManaged var photos: NSMutableOrderedSet
    
    var coordinate: CLLocationCoordinate2D {
        
        set {
            self.latitude = newValue.latitude
            self.longitude = newValue.longitude
        }
        
        get {
            return CLLocationCoordinate2DMake(latitude, longitude)
        }
    }
    
    // MARK: - Init model
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(coordinate: CLLocationCoordinate2D, context: NSManagedObjectContext) {
        
        // Entity of core data
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.photos = NSMutableOrderedSet()
    }
}
