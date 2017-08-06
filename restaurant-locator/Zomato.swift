//
//  Zomato.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 6/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//
//  ✴️ Attributes:
//      1. Singleton
//          Website: Singletons
//              https://thatthinginswift.com/singletons/
//      2. Calculate Elapsed
//          StakeOverflow: Find difference in seconds between NSDates as integer using Swift
//              https://stackoverflow.com/questions/26599172/find-difference-in-seconds-between-nsdates-as-integer-using-swift
//      3. HTTP Networking Library
//          GitHub: Alamofire/Alamofire
//              https://github.com/Alamofire/Alamofire
//      4. JSON Library
//          GitHub: SwiftyJSON/SwiftyJSON
//              https://github.com/SwiftyJSON/SwiftyJSON
//          StackOverflow: How to parse JSON response from Alamofire API in Swift?
//              https://stackoverflow.com/questions/26114831/how-to-parse-json-response-from-alamofire-api-in-swift

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class Zomato: NSObject {
    
    let zomatoAPIKey = "cbdd121b433ee55698c5557755a56e94"
    
    let zomatoURL = "https://developers.zomato.com/api/v2.1/"
    
    static let sharedInstance = Zomato()
    
    var lastGetGeoCodeTime: CFAbsoluteTime?
    
    var cityName: String?
    
    var cityId: Int?
    
    func getGeoCode(lat: CLLocationDegrees, lng: CLLocationDegrees, closure: @escaping (_ cityId: Int, _ cityName: String) -> Void) {
        // only get it after 5 min from last time
        if let lastGetGeoCodeTime = self.lastGetGeoCodeTime {
            if CFAbsoluteTimeGetCurrent() - lastGetGeoCodeTime < 5 * 60 {
                return
            }
        }
        
        let headers: HTTPHeaders = [
            "user-key": self.zomatoAPIKey,
            "Accept": "application/json"
        ]
        
        Alamofire.request("\(self.zomatoURL)geocode?lat=\(lat)&lon=\(lng)", headers: headers).responseJSON { response in
            // ⚠️ TODO: error handling
            if let json = response.data {
                let data = JSON(data: json)
                self.cityName = data["location"]["city_name"].string
                self.cityId = data["location"]["city_id"].int
                
                closure(self.cityId!, self.cityName!)
            }
        }
        
        lastGetGeoCodeTime = CFAbsoluteTimeGetCurrent()
    }

}
