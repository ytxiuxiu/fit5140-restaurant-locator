//
//  Restaurant.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 6/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//

import UIKit
import CoreLocation

class Restaurant: NSObject {
    
    var sName: String
    
    var oCategory: Category?

    var sURL: String?
    
    var sThumbURL: String?
    
    var sImageURL: String?
    
    var fRating: Double
    
    var sAddress: String
    
    var fLatitude: CLLocationDegrees
    
    var fLongitude: CLLocationDegrees
    
    var fDistance: Double?
    
    var dAddedAt: Date?
    
    init(name: String, category: Category?, url: String?, thumbURL: String?, imageURL: String?, rating: Double, address: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, addedAt: Date?) {
        self.sName = name
        self.oCategory = category
        self.sURL = url
        self.sThumbURL = thumbURL
        self.sImageURL = imageURL
        self.fRating = rating
        self.sAddress = address
        self.fLatitude = latitude
        self.fLongitude = longitude
        self.dAddedAt = addedAt
    }
    
    convenience init(name: String, url: String?, thumbURL: String?, imageURL: String?, rating: Double, address: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        
        // ✴️ Attribute:
        // Website: nil is not compatible with expected argument type Selector??
        //      https://teamtreehouse.com/community/nil-is-not-compatible-with-expected-argument-type-selector
        
        self.init(name: name, category: nil, url: url, thumbURL: thumbURL, imageURL: imageURL, rating: rating, address: address, latitude: latitude, longitude: longitude, addedAt: nil)
    }
    
    func calculateDistance(currentLocation: CLLocation) -> Double? {
        let location = CLLocation(latitude: fLatitude, longitude: fLongitude)
        self.fDistance = location.distance(from: currentLocation)
        return self.fDistance
    }
    
    
}
