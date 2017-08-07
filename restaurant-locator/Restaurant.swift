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
    
    var fRating: Double?
    
    var sAddress: String?
    
    var oCoordinate: CLLocationCoordinate2D?
    
    var dAddedAt: Date?
    
    init(name: String, category: Category?, url: String?, thumbURL: String?, imageURL: String?, rating: Double?, address: String?, coordinate: CLLocationCoordinate2D?, addedAt: Date?) {
        self.sName = name
        self.oCategory = category
        self.sURL = url
        self.sThumbURL = thumbURL
        self.sImageURL = imageURL
        self.fRating = rating
        self.sAddress = address
        self.oCoordinate = coordinate
        self.dAddedAt = addedAt
    }
    
    convenience init(name: String, url: String, thumbURL: String, imageURL: String, rating: Double, address: String, coordinate: CLLocationCoordinate2D) {
        
        // ✴️ Attribute:
        // Website: nil is not compatible with expected argument type Selector??
        //      https://teamtreehouse.com/community/nil-is-not-compatible-with-expected-argument-type-selector
        
        self.init(name: name, category: nil, url: url, thumbURL: thumbURL, imageURL: imageURL, rating: rating, address: address, coordinate: coordinate, addedAt: nil)
    }
}
