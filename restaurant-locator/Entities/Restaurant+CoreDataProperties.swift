//
//  Restaurant+CoreDataProperties.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 14/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//

import Foundation
import CoreData


extension Restaurant {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Restaurant> {
        return NSFetchRequest<Restaurant>(entityName: "Restaurant")
    }

    @NSManaged public var addedAt: NSDate
    @NSManaged public var address: String
    @NSManaged public var image: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String
    @NSManaged public var rating: Double
    @NSManaged public var category: Category?

}
