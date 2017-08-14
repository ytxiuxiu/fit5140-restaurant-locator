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
        restaurant.longitude = longitude
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
    
    static func fetchByCategory(categoryName: String) -> [Restaurant] {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Restaurant")
        
        fetch.predicate = NSPredicate(format: "category.name = %@", categoryName)
        
        do {
            return try Data.shared.managedObjectContext.fetch(fetch) as! [Restaurant]
        } catch {
            fatalError("Failed to fetch restaurants: \(error)")
        }
    }
    
    
    // save restaurant photo
    // ✴️ Attribute:
    // Website: How to save a UIImage to a file using UIImagePNGRepresentation
    //      https://www.hackingwithswift.com/example-code/media/how-to-save-a-uiimage-to-a-file-using-uiimagepngrepresentation
    // Website: Save and Get Image from Document Directory in Swift ?
    //      https://iosdevcenters.blogspot.com/2016/04/save-and-get-image-from-document.html
    // GitHub: Dougly/PersistingImages
    //      https://github.com/Dougly/PersistingImages
    
    func getDirecotryURL() -> URL {
        let url = Data.shared.directoryURL.appendingPathComponent("restaurants")
        return url
    }
    
    // ✴️ Attribute:
    // Generate a UUID on iOS from Swift
    //      https://stackoverflow.com/questions/24428250/generate-a-uuid-on-ios-from-swift
    
    func getImageURL() -> URL {
        if let filename = self.image {
            return getDirecotryURL().appendingPathComponent("\(filename).png")
        } else {
            self.image = UUID().uuidString
            return getDirecotryURL().appendingPathComponent("\(self.image).png")
        }
    }
    
    func saveImage(image: UIImage) {
        let fileManager = FileManager.default
        
        let directoryPath = getDirecotryURL().path
        let imagePath = getImageURL().path
        
        do {
            if !fileManager.fileExists(atPath: directoryPath) {
                try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            fatalError("Could not add image to document directory: \(error)")
        }
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: getDirecotryURL().path)
        
            for file in files {
                // if we find existing image filePath delete it to make way for new imageData
                if "\(directoryPath)/\(file)" == imagePath {
                    try fileManager.removeItem(atPath: imagePath)
                }
            }
        } catch {
            fatalError("Could not add image to document directory: \(error)")
        }
        
        do {
            if let data = UIImagePNGRepresentation(image) {
                try data.write(to: getImageURL(), options: .atomic)
            }
        } catch {
            fatalError("Could not write image: \(error)")
        }
    }
    
    func getImage() -> UIImage {
        let fileManager = FileManager.default
        
        let imagePath = getImageURL().path

        if fileManager.fileExists(atPath: imagePath) {
            return UIImage(contentsOfFile: imagePath)!
        } else {
            return UIImage(named: "photo")!
        }
    }
    
    func calculateDistance(currentLocation: CLLocation) -> Double? {
        let location = CLLocation(latitude: self.latitude, longitude: self.longitude)
        self.distance = location.distance(from: currentLocation)
        return self.distance
    }
    
}