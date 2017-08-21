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
import Alamofire
import SwiftyJSON


class Location: NSObject, CLLocationManagerDelegate {
    
    static let shared = Location()
    
    static let radiusText = ["< 50m", "< 100m", "< 250m", "< 500m", "< 1km"]
    
    static let radius = [50.0, 100.0, 250.0, 500.0, 1000.0]
    
    let locationManager = CLLocationManager()
    
    static let geocoder = CLGeocoder();
    
    private var callbacks = [String: (latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> Void]()
    
    var lastLatitude: CLLocationDegrees?
    
    var lastLongitude: CLLocationDegrees?
    
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.distanceFilter = 5.0
        
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0] // most recent location
        

        for (_, callback) in self.callbacks {
            self.lastLatitude = location.coordinate.latitude
            self.lastLongitude = location.coordinate.longitude
            
            callback(self.lastLatitude!, self.lastLongitude!)
        }
    }
    
    // https://stackoverflow.com/questions/37498438/didenterregion-didexitregion-not-being-called
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
    }
    
    
    
    // ✴️ Attribute:
    // StackOverflow: Swift - Generate an Address Format from Reverse Geocoding
    //      https://stackoverflow.com/questions/41358423/swift-generate-an-address-format-from-reverse-geocoding
    
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
    
    func makeRegion(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> MKCoordinateRegion {
        let coordinateLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let coordinateSpan: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        return MKCoordinateRegionMake(coordinateLocation, coordinateSpan)
    }
    
    static func getDistanceString(distance: Double) -> String {
        if (distance < 1000) {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
    
    func addCallback(key: String, callback: @escaping (_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) -> Void) {
        self.callbacks[key] = callback
        
        if let latitude = self.lastLatitude, let longitude = self.lastLongitude {
            callback(latitude, longitude)
        }
        
        self.locationManager.startUpdatingLocation()
    }
    
    func removeCallback(key: String) {
        self.callbacks.removeValue(forKey: key)
        
        if self.callbacks.count == 0 {
            self.locationManager.stopUpdatingLocation()
        }
    }

}
