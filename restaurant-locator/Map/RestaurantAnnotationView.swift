//
//  RestaurantAnnotationView.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 17/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//
// ✴️ Attributes:
//      Website: Building The Perfect IOS Map (II): Completely Custom Annotation Views
//          https://digitalleaves.com/blog/2016/12/building-the-perfect-ios-map-ii-completely-custom-annotation-views/

import UIKit
import MapKit


/**
 Restaurant annotation delegate, it is used for updating callout view
 */
protocol RestaurantAnnotationDelegate {
    
    /**
     Edit restaurant, it should update the callout view of the restaurant
     
     - Parameters:
        - restaurant: The restaurant edited
     */
    func editRestaurant(restaurant: Restaurant)
}

/**
 View for restaurant annotation on the map
 */
class RestaurantAnnotationView: MKAnnotationView, RestaurantAnnotationDelegate {
    
    var customCalloutView: RestaurantCalloutView?
    
    var navigationController: UINavigationController?
    
    var restaurant: Restaurant?
    

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.canShowCallout = false // don't show default callout
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.canShowCallout = false // don't show default callout
    }
    
    
    // MARK: - callout showing and hiding
    
    // Important: the selected state of the annotation view controls when the
    // view must be shown or not. We should show it when selected and hide it
    // when de-selected.
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.customCalloutView?.removeFromSuperview() // remove old custom callout (if any)
            
            if let newCustomCalloutView = loadCustomCalloutView() {
                // fix location from top-left to its right place.
                newCustomCalloutView.frame.origin.x -= newCustomCalloutView.frame.width / 2.0 - (self.frame.width / 2.0)
                newCustomCalloutView.frame.origin.y -= newCustomCalloutView.frame.height
                
                newCustomCalloutView.navigationController = self.navigationController
                newCustomCalloutView.restaurantAnnotationDelegate = self
                newCustomCalloutView.restaurant = self.restaurant
                
                newCustomCalloutView.layer.cornerRadius = 5
                
                // set custom callout view
                self.addSubview(newCustomCalloutView)
                self.customCalloutView = newCustomCalloutView
                
                self.editRestaurant(restaurant: self.restaurant!)
                
                // animate presentation
                if animated {
                    self.customCalloutView!.alpha = 0.0
                    UIView.animate(withDuration: 0.3, animations: {
                        self.customCalloutView!.alpha = 1.0
                    })
                }
            }
        }
    }
    
    /**
     Load custom callout view
     
     - Returns: The view of the callout of this annotation
     */
    func loadCustomCalloutView() -> RestaurantCalloutView? {
        if let views = Bundle.main.loadNibNamed("RestaurantCalloutView", owner: self, options: nil) as? [RestaurantCalloutView], views.count > 0 {
            return views.first!
        }
        return nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.customCalloutView?.removeFromSuperview()
    }
    
    
    // MARK: - Detecting and reaction to taps on custom callout.
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // if super passed hit test, return the result
        if let parentHitView = super.hitTest(point, with: event) { return parentHitView }
        else { // test in our custom callout.
            if customCalloutView != nil {
                return customCalloutView!.hitTest(convert(point, to: customCalloutView!), with: event)
            } else {
                return nil
            }
        }
    }
    
    
    // MARK: - Restaurant Annotation Delegate
    
    func editRestaurant(restaurant: Restaurant) {
        if let customCalloutView = self.customCalloutView {
            customCalloutView.restaurantImageView.image = restaurant.getImage()
            customCalloutView.restaurantNameLabel.text = restaurant.name
            customCalloutView.restaurantAddressLabel.text = restaurant.address
            
            if restaurant.notificationRadius != -1 {
                customCalloutView.restaurantNotificationImageView.image = UIImage(named: "notification-big")
                customCalloutView.restaurantNotificationLabel.text = Location.radiusText[Int(restaurant.notificationRadius)]
            } else {
                customCalloutView.restaurantNotificationImageView.image = UIImage(named: "no-notification-big")
                customCalloutView.restaurantNotificationLabel.text = "Never"
            }
        }
    }

}
