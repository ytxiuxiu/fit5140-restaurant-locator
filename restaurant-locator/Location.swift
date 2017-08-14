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

class Location: NSObject, CLLocationManagerDelegate {

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
