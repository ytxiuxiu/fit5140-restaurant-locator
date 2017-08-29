//
//  Location.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 8/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import SwiftyJSON
import UserNotifications
import Whisper

/**
 Deal with location related functionalities
 */
class Location: NSObject, CLLocationManagerDelegate {
    
    static let shared = Location()
    
    static let radiusText = ["< 50m", "< 100m", "< 250m", "< 500m", "< 1km"]
    
    static let radius = [50.0, 100.0, 250.0, 500.0, 1000.0]
    
    let locationManager = CLLocationManager()
    
    private var monitoringRestaurants = [String: Restaurant]()
    
    private var monitoringRegions = [String: CLRegion]()
    
    static let geocoder = CLGeocoder();
    
    private var callbacks = [String: (latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> Void]()
    
    var lastLatitude: CLLocationDegrees?
    
    var lastLongitude: CLLocationDegrees?
    
    var appDelegate: AppDelegate?
    
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        
        // accuracy
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.distanceFilter = 5.0
        
        // privacy
        self.locationManager.requestWhenInUseAuthorization()
        
        self.locationManager.startUpdatingLocation()
        
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
    }
    
    
    // MARK: - Location Manager
    
    // Location did updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0] // most recent location
        
        for (_, callback) in self.callbacks {
            self.lastLatitude = location.coordinate.latitude
            self.lastLongitude = location.coordinate.longitude
            
            callback(self.lastLatitude!, self.lastLongitude!)
        }
    }
    
    // ✴️ Attributes:
    // Website: Swift Tutorial : CoreLocation and Region Monitoring in iOS 8
    //      http://shrikar.com/swift-tutorial-corelocation-and-region-monitoring-in-ios-8/
    // StackOverflow: didEnterRegion, didExitRegion not being called
    //      https://stackoverflow.com/questions/37498438/didenterregion-didexitregion-not-being-called
    // Website: How to Make Local Notifications in iOS 10
    //      https://makeapppie.com/2016/08/08/how-to-make-local-notifications-in-ios-10/
    
    // Did enter monitored region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let restaurant = monitoringRestaurants[region.identifier]
        
        print("entered restaurant region \(restaurant?.name ?? "no name restaurant")")
        
        let content = UNMutableNotificationContent()
        
        content.title = "You are near \(restaurant?.name ?? "a restaurant")"
        content.sound = UNNotificationSound.default()
        if let distance = restaurant?.distance {
            content.subtitle = "\(Location.getDistanceString(distance: distance)) away from here"
        }
        content.body = "\(restaurant?.address ?? "")"
        content.categoryIdentifier = "nearRestaurant"
        content.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
        
        let request = UNNotificationRequest(identifier: region.identifier, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        // In-app notification
        // ✴️ Attribute:
        // GitHub: hyperoslo/Whisper
        //      https://github.com/hyperoslo/Whisper
        let murmur = Murmur(title: "You are near \(restaurant?.name ?? "a restaurant")")
        Whisper.show(whistle: murmur, action: .show(3))

    }
    
    
    // MARK: - Tools
    
    // ✴️ Attribute:
    // StackOverflow: Swift - Generate an Address Format from Reverse Geocoding
    //      https://stackoverflow.com/questions/41358423/swift-generate-an-address-format-from-reverse-geocoding
    
    /**
     Get address string from a location
 
     - Parameters:
        - latitude: Current latitude
        - longitude: Current longitude
        - callback: Callback function after getting the address
        - address: String format of the address
        - error: Error
     */
    static func getAddress(latitude: CLLocationDegrees, longitude: CLLocationDegrees, callback: @escaping (_ address: String?, _ error: Error?) -> Void) {

        geocoder.reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { (placemark, error) in
            guard placemark != nil else {
                callback(nil, error)
                return
            }

            let place = placemark?.first
            
            var address = ""
            
            if place?.subThoroughfare != nil {  // eg. 900
                address = "\(address)\(place?.subThoroughfare ?? "") "
            }
            if place?.thoroughfare != nil { // eg. Dandenong Road
                address = "\(address)\(place?.thoroughfare ?? ""), "
            }
            if place?.locality != nil { // eg. Caulfield
                address = "\(address)\(place?.locality ?? ""), "
            }
            if place?.administrativeArea != nil {   // eg. VIC
                address = "\(address)\(place?.administrativeArea ?? ""), "
            }
            if place?.country != nil {   // eg. Australia
                address = "\(address)\(place?.country ?? ""), "
            }
            
            let endIndex = address.index(address.endIndex, offsetBy: -2)
            address = address.substring(to: endIndex)
            
            callback(address, nil)
        }
    }
    
    /**
     Make a MKCoordinateRegion for maps
     
     - Parameters:
        - latitude: Current latitude
        - longitude: Current longitude
     - Returns: MKCoordinateRegion
     */
    func makeRegion(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> MKCoordinateRegion {
        let coordinateLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let coordinateSpan: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        return MKCoordinateRegionMake(coordinateLocation, coordinateSpan)
    }
    
    /**
     Get string format of a distance
     
     - Parameters:
        - distance: Distance in Double
     - Returns: String format of the distance
     */
    static func getDistanceString(distance: Double) -> String {
        if (distance < 1000) {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
    
    
    // MARK: - Add and Remove
    
    // ✴️ Attribute:
    // Swift Tutorial : CoreLocation and Region Monitoring in iOS 8
    //      http://shrikar.com/swift-tutorial-corelocation-and-region-monitoring-in-ios-8/
    
    /**
     Add enter radius monitor to a restaurant
     
     - Parameters:
        - restaurant: The restaurant to be monitored
     */
    func addMonitor(restaurant: Restaurant) {
        let center = CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude)
        let radius = CLLocationDistance(Location.radius[Int(restaurant.notificationRadius)])
        let identifier = restaurant.id
        
        let region = CLCircularRegion(center: center, radius: radius, identifier: identifier)
        
        monitoringRegions.updateValue(region, forKey: restaurant.id)
        monitoringRestaurants.updateValue(restaurant, forKey: restaurant.id)
        
        region.notifyOnEntry = true
        region.notifyOnExit = false
        
        locationManager.startMonitoring(for: region)
        
        print("start to monitor restaurant \(restaurant.name)")
    }
    
    /**
     Remove enter radius monitor of a restaurant
     
     - Parameters:
        - restaurant: The restaurant will be removed from monitoring
     */
    func removeMonitor(restaurant: Restaurant) {
        if let index = monitoringRegions.index(forKey: restaurant.id) {
            monitoringRegions.remove(at: index)
        }
        
        if let index = monitoringRestaurants.index(forKey: restaurant.id) {
            monitoringRestaurants.remove(at: index)
        }
    }
    
    /**
     Add a callback function when the current location has updated
     
     - Parameters:
        - key: key of the callback function, it makes it easier to remove a certain callback
        - callback: callback function itself
        - latitude: current latitude
        - longitude: current longitude
     */
    func addCallback(key: String, callback: @escaping (_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) -> Void) {
        self.callbacks[key] = callback
        
        if let latitude = self.lastLatitude, let longitude = self.lastLongitude {
            callback(latitude, longitude)
        }
        
        self.locationManager.startUpdatingLocation()
    }
    
    /**
     Remove a callback function for location updates
     
     - Parameters:
        - key: key of the callback function to remove
     */
    func removeCallback(key: String) {
        self.callbacks.removeValue(forKey: key)
        
        if self.callbacks.count == 0 {
            self.locationManager.stopUpdatingLocation()
        }
    }

}
