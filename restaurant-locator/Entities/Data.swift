//
//  BaseEntity.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 14/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//

import UIKit
import CoreData

class Data: NSObject {
    
    static let shared = Data()
    
    let managedObjectContext: NSManagedObjectContext

    override init() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.managedObjectContext = (appDelegate?.persistentContainer.viewContext)!
    }
    
}
