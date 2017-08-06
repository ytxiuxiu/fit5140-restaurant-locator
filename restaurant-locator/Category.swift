//
//  Category.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 5/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//

import UIKit

class Category: NSObject {

    var sName: String
    
    var cColor: UIColor
    
    var nIcon: Int
    
    init(name: String, color: String, icon: Int) {
        self.sName = name
        
        switch color {
        case "red":
            self.cColor = UIColor.red
            break
        case "orange":
            self.cColor = UIColor.orange
            break
        case "yellow":
            self.cColor = UIColor.yellow
            break
        case "green":
            self.cColor = UIColor.green
            break
        case "blue":
            self.cColor = UIColor.blue
            break
        default:
            self.cColor = UIColor.white
            break
        }
        
        self.nIcon = icon
    }
}
