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


/**
 Category entity
 */
@objc(Category)
public class Category: NSManagedObject {
    
    var numberOfRestaurants: Int = 0

    
    /**
     Create a new category object
    
     - Parameters:
        - id: UUID for the category
        - name: Name
        - color: Category color index
        - icon: Category icon index
        - sort: Sort
     - Returns: Category object
     */
    static func insertNewObject(id: String, name: String, color: Int, icon: Int, sort: Int) -> Category {
        let category = NSEntityDescription.insertNewObject(forEntityName: "Category", into: Data.shared.managedObjectContext) as! Category
        category.id = id
        category.name = name
        category.color = Int64(color)
        category.icon = Int64(icon)
        category.sort = Int64(sort)
        
        return category
    }
    
    /**
     Fetch all categories
     
     - Returns: List of all categories
     */
    static func fetchAll() -> [Category] {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        
        fetch.sortDescriptors = [NSSortDescriptor(key: "sort", ascending: true)]
        
        do {
            return try Data.shared.managedObjectContext.fetch(fetch) as NSArray as! [Category]
        } catch {
            fatalError("Failed to fetch categories: \(error)")
        }
    }
    
}
