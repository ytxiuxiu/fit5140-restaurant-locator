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


class RestaurantAnnotationView: MKAnnotationView {
    
    weak var customCalloutView: RestaurantCalloutView?
    
    var mainMapDelegate: MainMapDelegate?
    
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
                
                // set custom callout view
                self.addSubview(newCustomCalloutView)
                self.customCalloutView = newCustomCalloutView
                
                // animate presentation
                if animated {
                    self.customCalloutView!.alpha = 0.0
                    UIView.animate(withDuration: 0.3, animations: {
                        self.customCalloutView!.alpha = 1.0
                    })
                }
            }
        } else {
            if customCalloutView != nil {
                if animated { // fade out animation, then remove it.
                    UIView.animate(withDuration: 0.3, animations: {
                        self.customCalloutView!.alpha = 0.0
                    }, completion: { (success) in
                        self.customCalloutView!.removeFromSuperview()
                    })
                } else { self.customCalloutView!.removeFromSuperview() } // just remove it.
            }
        }
    }
    
    func loadCustomCalloutView() -> RestaurantCalloutView? {
        if let views = Bundle.main.loadNibNamed("RestaurantCalloutView", owner: self, options: nil) as? [RestaurantCalloutView], views.count > 0 {
            let restaurantCalloutView = views.first!
            
            restaurantCalloutView.mainMapDelegate = self.mainMapDelegate
            restaurantCalloutView.restaurant = self.restaurant
            
            restaurantCalloutView.restaurantImageView.image = restaurant?.getImage()
            restaurantCalloutView.restaurantNameLabel.text = restaurant?.name
            restaurantCalloutView.restaurantAddressLabel.text = restaurant?.address
            
            if restaurant?.notificationRadius != -1 {
                restaurantCalloutView.restaurantNotificationLabel.text = Location.radiusText[Int((restaurant?.notificationRadius)!)]
            } else {
                restaurantCalloutView.restaurantNotificationLabel.text = "Never"
            }
            
            restaurantCalloutView.layer.cornerRadius = 5
            
            return restaurantCalloutView
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
            } else { return nil }
        }
    }

}
