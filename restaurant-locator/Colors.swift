//
//  Colors.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 15/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//

import UIKit

class Colors: NSObject {
    
    static func red(alpha: Float) -> UIColor {
        return UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: CGFloat(alpha))
    }
    
    static func orange(alpha: Float) -> UIColor {
        return UIColor(red: 243/255, green: 156/255, blue: 18/255, alpha: CGFloat(alpha))
    }
    
    static func yellow(alpha: Float) -> UIColor {
        return UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: CGFloat(alpha))
    }
    
    static func green(alpha: Float) -> UIColor {
        return UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: CGFloat(alpha))
    }
    
    static func blue(alpha: Float) -> UIColor {
        return UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: CGFloat(alpha))
    }
    
    static let categoryColors: [UIColor] = [Colors.red(alpha: 0.5), Colors.orange(alpha: 0.5), Colors.yellow(alpha: 0.5), Colors.green(alpha: 0.5), Colors.blue(alpha: 0.5)]
    
    static let categorySegmentColors: [UIColor] = [Colors.red(alpha: 1), Colors.orange(alpha: 1), Colors.yellow(alpha: 1), Colors.green(alpha: 1), Colors.blue(alpha: 1)]
    
}
