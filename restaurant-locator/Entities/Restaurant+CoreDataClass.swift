//
//  Restaurant+CoreDataClass.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 14/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CoreLocation

@objc(Restaurant)
public class Restaurant: NSManagedObject {

    var distance: Double?
    
    
    static func insertNewObject(name: String, rating: Double, address: String, latitude: Double, longitude: Double) -> Restaurant {
        let restaurant = NSEntityDescription.insertNewObject(forEntityName: "Restaurant", into: Data.shared.managedObjectContext) as! Restaurant
        restaurant.name = name
        restaurant.rating = rating
        restaurant.address = address
        restaurant.latitude = latitude
        restaurant.addedAt = NSDate()
        
        return restaurant
    }
    
    static func fetchAll() -> [Restaurant] {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Restaurant")
        
        do {
            return try Data.shared.managedObjectContext.fetch(fetch) as! [Restaurant]
        } catch {
            fatalError("Failed to fetch restaurants: \(error)")
        }
    }
    
    
    func calculateDistance(currentLocation: CLLocation) -> Double? {
        let location = CLLocation(latitude: self.latitude, longitude: self.longitude)
        self.distance = location.distance(from: currentLocation)
        return self.distance
    }
    
}
