//
//  RestaurantAnnotation.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 13/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//

import UIKit
import MapKit

/**
 Pin of restaurant on the map
 */
class RestaurantAnnotation: MKPointAnnotation {
    
    var restaurant: Restaurant?
    
    var image: UIImage?
    
}
