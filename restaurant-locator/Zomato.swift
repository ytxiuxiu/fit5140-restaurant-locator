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
    
    let headers: HTTPHeaders
    
    static let sharedInstance = Zomato()
    
    var lastGetGeoCodeTime: CFAbsoluteTime?
    
    var cityName: String?
    
    var cityId: Int?
    
    override init() {
        self.headers = [
            "user-key": self.zomatoAPIKey,
            "Accept": "application/json"
        ]
    }
    
    func getGeoCode(lat: CLLocationDegrees, lng: CLLocationDegrees, closure: @escaping (_ cityId: Int?, _ cityName: String?) -> Void) {
        // only get it after 5 min from last time
        if let lastGetGeoCodeTime = self.lastGetGeoCodeTime {
            if CFAbsoluteTimeGetCurrent() - lastGetGeoCodeTime < 5 * 60 {
                if let cityId = self.cityId, let cityName = self.cityName {
                    closure(cityId, cityName)
                } else {
                    return
                }
            }
        }
        
        
        Alamofire.request("\(self.zomatoURL)geocode?lat=\(lat)&lon=\(lng)", headers: self.headers).responseJSON { response in
            // ⚠️ TODO: error handling
            if let json = response.data {
                let data = JSON(data: json)
                self.cityName = data["location"]["city_name"].string
                self.cityId = data["location"]["city_id"].int
                
                if let cityId = self.cityId, let cityName = self.cityName {
                    closure(cityId, cityName)
                } else {
                    // ⚠️ TODO: error handling
                    closure(nil, nil)
                }
            }
        }
        
        lastGetGeoCodeTime = CFAbsoluteTimeGetCurrent()
    }
    
    func searchRestaurants(keyword: String, closure: @escaping (_ restaurants: [ZomatoRestaurant]) -> Void) throws {
        // ⚠️ TODO: error handling - for no city id
        if let cityId = self.cityId {
            let url = URL(string: "\(self.zomatoURL)search")!
            let urlRequest = URLRequest(url: url)
            
            let parameters: Parameters = ["entity_type": "city", "entity_id": cityId, "q": keyword]
            var encodedURLRequest = try URLEncoding.queryString.encode(urlRequest, with: parameters)
            encodedURLRequest.setValue(zomatoAPIKey, forHTTPHeaderField: "user-key")
            encodedURLRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            
            Alamofire.request(encodedURLRequest).responseJSON { response in
                var restaurants = [ZomatoRestaurant]()
            
                if let json = response.data {
                    let data = JSON(data: json)
                
                    let restaurantsData = data["restaurants"].array
                
                    if restaurantsData == nil {
                        return closure(restaurants)
                    }
                
                    for restaurantData in restaurantsData! {
                        // ⚠️ TODO: error handling - no data
                        let name = restaurantData["restaurant"]["name"].string
                        let imageURL = restaurantData["restaurant"]["featured_image"].string
                        let rating = Double(restaurantData["restaurant"]["user_rating"]["aggregate_rating"].string!)
                        let address = restaurantData["restaurant"]["location"]["address"].string
                        let latitude = Double(restaurantData["restaurant"]["location"]["latitude"].string!)
                        let longitude = Double(restaurantData["restaurant"]["location"]["longitude"].string!)
                    
                        let restaurant = ZomatoRestaurant(name: name!, imageURL: imageURL!, rating: rating!, address: address!, latitude: latitude!, longitude: longitude!)
                        restaurants.append(restaurant)
                    }
                }
            
                closure(restaurants)
            }
        }
    }

}
