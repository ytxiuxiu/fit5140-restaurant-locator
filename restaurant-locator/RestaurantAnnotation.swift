//
//  RestaurantAnnotation.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 13/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//

import UIKit
import MapKit

class RestaurantAnnotation: MKPointAnnotation {
    
    var imageFilename: String?
    
    var image: UIImage
    
    var pinImage: UIImage?
    
    var name: String
    
    var address: String
    
    var isNotification: Bool
    
    var notificationDistance: Double?
    
    init(imageFilename: String, image: UIImage, name: String, address: String, isNotification: Bool, notificationDistance: Double?) {
        self.imageFilename = imageFilename
        self.image = image
        self.name = name
        self.address = address
        self.isNotification = isNotification
        self.notificationDistance = notificationDistance
    }
}
