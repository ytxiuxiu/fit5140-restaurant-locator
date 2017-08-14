//
//  Category+CoreDataClass.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 14/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//

import UIKit
import Foundation
import CoreData

@objc(Category)
public class Category: NSManagedObject {

    static func insertNewObject(name: String, color: String, icon: Int, sort: Int) -> Category {
        let category = NSEntityDescription.insertNewObject(forEntityName: "Category", into: Data.shared.managedObjectContext) as! Category
        category.name = name
        category.color = color
        category.icon = Int64(icon)
        category.sort = Int64(sort)
        
        return category
    }
    
    static func fetchAll() -> [Category] {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        
        fetch.sortDescriptors = [NSSortDescriptor(key: "sort", ascending: true)]
        
        do {
            return try Data.shared.managedObjectContext.fetch(fetch) as! [Category]
        } catch {
            fatalError("Failed to fetch categories: \(error)")
        }
    }
    
    
}
