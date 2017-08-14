//
//  Restaurant.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 6/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//

import UIKit
import CoreLocation

class ZomatoRestaurant: NSObject {
    
    var name: String
    
    var imageURL: String?
    
    var rating: Double
    
    var address: String
    
    var latitude: CLLocationDegrees
    
    var longitude: CLLocationDegrees
    
    var distance: Double?

    
    init(name: String, imageURL: String?, rating: Double, address: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.name = name
        self.imageURL = imageURL
        self.rating = rating
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
    
}
