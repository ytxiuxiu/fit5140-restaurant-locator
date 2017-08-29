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


/**
 Restaurant entity
 */
@objc(Restaurant)
public class Restaurant: NSManagedObject {

    var distance: Double?
    
    
    /**
     Create a new restaurant object
    
     - Parameters:
        - id: UUID of the restaurant
        - name: Name
        - rating: Rating (5 stars)
        - address: Address
        - latitude: Latitude
        - longitude: Longitude
        - notificationRadius: Notification radius index (-1 for no notification)
     - Returns: Restaurant object
     */
    static func insertNewObject(id: String, name: String, rating: Double, address: String, latitude: Double, longitude: Double, notificationRadius: Int) -> Restaurant {
        let restaurant = NSEntityDescription.insertNewObject(forEntityName: "Restaurant", into: Data.shared.managedObjectContext) as! Restaurant
        restaurant.id = id
        restaurant.name = name
        restaurant.rating = rating
        restaurant.address = address
        restaurant.latitude = latitude
        restaurant.longitude = longitude
        restaurant.notificationRadius = Int64(notificationRadius)
        restaurant.addedAt = NSDate()
        
        return restaurant
    }
    
    /**
     Fetch all restaurants
    
     - Returns: List of all restaurants
     */
    static func fetchAll() -> [Restaurant] {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Restaurant")
        
        do {
            return try Data.shared.managedObjectContext.fetch(fetch) as! [Restaurant]
        } catch {
            fatalError("Failed to fetch restaurants: \(error)")
        }
    }
    
    
    // MARK: - Photo
    
    // ✴️ Attribute:
    // Website: How to save a UIImage to a file using UIImagePNGRepresentation
    //      https://www.hackingwithswift.com/example-code/media/how-to-save-a-uiimage-to-a-file-using-uiimagepngrepresentation
    // Website: Save and Get Image from Document Directory in Swift ?
    //      https://iosdevcenters.blogspot.com/2016/04/save-and-get-image-from-document.html
    // GitHub: Dougly/PersistingImages
    //      https://github.com/Dougly/PersistingImages
    
    /**
     Generate directory url for saving photos
     
     - Returns: URL
     */
    func getDirecotryURL() -> URL {
        let url = Data.shared.directoryURL.appendingPathComponent("restaurants")
        return url
    }
    
    // ✴️ Attribute:
    // Generate a UUID on iOS from Swift
    //      https://stackoverflow.com/questions/24428250/generate-a-uuid-on-ios-from-swift
    
    /**
     Get url for the restaurant's image
     
     - Returns: URL
     */
    func getImageURL() -> URL? {
        if let filename = self.image {
            return getDirecotryURL().appendingPathComponent("\(filename).png")
        } else {
            return nil
        }
    }
    
    /**
     Generate url for the restaurant's image
     
     - Returns: URL
     */
    func generateImageUrl() -> URL {
        self.image = UUID().uuidString
        return getDirecotryURL().appendingPathComponent("\(self.image ?? "").png")
    }
    
    /**
     Save a image for this restaurant
     
     - Parameters:
        - image: The image to save
     */
    func saveImage(image: UIImage) {
        let fileManager = FileManager.default
        
        let directoryPath = getDirecotryURL().path
        let imagePath = generateImageUrl().path
        
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
                try data.write(to: self.getImageURL()!, options: .atomic)
            }
        } catch {
            fatalError("Could not write image: \(error)")
        }
    }
    
    /**
     Get the image for this restaurant
    
     - Parameters:
        - defaultImage: Default image used when there is no image for this restaurant
     - Returns: Image
     */
    func getImage(defaultImage: UIImage = UIImage(named: "photo")!) -> UIImage {
        let fileManager = FileManager.default
        
        if let imageURL = getImageURL() {
            if fileManager.fileExists(atPath: imageURL.path) {
                return UIImage(contentsOfFile: imageURL.path)!
            }
        }
        
        return defaultImage
    }


    // MARK: - Distance

    /**
     Calculate the distance between this restaurant to a certain loction
    
     - Parameters:
        - currentLocation: The certain location
     - Returns: Distance in meters
     */
    func calculateDistance(currentLocation: CLLocation) -> Double? {
        let location = CLLocation(latitude: self.latitude, longitude: self.longitude)
        self.distance = location.distance(from: currentLocation)
        return self.distance
    }
    
}
