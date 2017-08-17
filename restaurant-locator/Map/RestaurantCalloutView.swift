//
//  RestaurantCalloutView.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 14/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//

import UIKit

class RestaurantCalloutView: UIView {
    
    @IBOutlet weak var restaurantImageView: UIImageView!
    
    @IBOutlet weak var restaurantNameLabel: UILabel!

    @IBOutlet weak var restaurantAddressLabel: UILabel!
    
    @IBOutlet weak var restaurantNotificationLabel: UILabel!
    
    @IBOutlet weak var backgroundContentButton: UIButton!
    
    @IBOutlet weak var restaurantDetailButton: UIButton!
    
    var mainMapDelegate: MainMapDelegate?
    
    var restaurant: Restaurant?
    
    
    @IBAction func onRestaurantDetailTapped(_ sender: Any) {
        self.mainMapDelegate?.showRestaurantDetail(restaurant: self.restaurant!)
    }
    
    // Detect hits in the custom callout
    // Website: Building The Perfect IOS Map (II): Completely Custom Annotation Views
    //      https://digitalleaves.com/blog/2016/12/building-the-perfect-ios-map-ii-completely-custom-annotation-views/
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Check if it hit the annotation detail view components.
        
        // detail button
        if let result = restaurantDetailButton.hitTest(convert(point, to: restaurantDetailButton), with: event) {
            return result
        }
        
        // fallback to the background content view
        return backgroundContentButton.hitTest(convert(point, to: backgroundContentButton), with: event)
    }

}
