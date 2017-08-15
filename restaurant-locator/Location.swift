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
    
    static let googleAPIKey = "AIzaSyAxLjdTklyKbWxOL75N3sZcqyvGl-rxCrA"
    
    static let googleGeocoderURL = "https://maps.googleapis.com/maps/api/geocode/json"

    static let sharedInstance = Location()
    
    let locationManager = CLLocationManager()
    
    private var callbacks = [String: (latitude: CLLocationDegrees, longitude: CLLocationDegrees, cityId: Int?, cityName: String?) -> Void]()
    
    var lastLatitude: CLLocationDegrees?
    
    var lastLongitude: CLLocationDegrees?
    
    var lastCityId: Int?
    
    var lastCityName: String?
    
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0] // most recent location
        
        // get zomato geocode
        Zomato.sharedInstance.getGeoCode(lat: location.coordinate.latitude, lng: location.coordinate.longitude, closure: {(cityId, cityName) in
            
            for (_, callback) in self.callbacks {
                self.lastLatitude = location.coordinate.latitude
                self.lastLongitude = location.coordinate.longitude
                self.lastCityId = cityId
                self.lastCityName = cityName
                
                callback(self.lastLatitude!, self.lastLongitude!, cityId, cityName)
            }
        })
    }
    
    // ✴️ Attribute:
    // StackOverflow: Swift - Generate an Address Format from Reverse Geocoding
    //      https://stackoverflow.com/questions/41358423/swift-generate-an-address-format-from-reverse-geocoding
    
    static func getAddress(latitude: CLLocationDegrees, longitude: CLLocationDegrees, callback: @escaping (_ address: String?) -> Void) {

        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { (placemark, error) in
            if error != nil || placemark?.count == 0 {
                callback(nil)
            } else {
                let place = placemark?.first
                
                var address = ""
                
                if place?.subThoroughfare != nil {  // eg. 900
                    address = "\(address)\(place?.subThoroughfare ?? ""), "
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
                
                callback(address)
            }
        }
    }
    
    func makeRegion(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> MKCoordinateRegion {
        let coordinateLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let coordinateSpan: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        return MKCoordinateRegionMake(coordinateLocation, coordinateSpan)
    }
    
    func addCallback(key: String, callback: @escaping (_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees, _ cityId: Int?, _ cityName: String?) -> Void) {
        self.callbacks[key] = callback
        
        if let latitude = self.lastLatitude, let longitude = self.lastLongitude {
            callback(latitude, longitude, self.lastCityId, self.lastCityName)
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
