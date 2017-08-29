//
//  SplitViewController.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 17/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Disable show master when swipe (because of the map)
        // ✴️ Attributes:
        // StackOverflow: How to suppress the Master-Detail Controller swipe gesture, and recreate its behaviour on iOS 7
        //      https://stackoverflow.com/questions/19357447/how-to-suppress-the-master-detail-controller-swipe-gesture-and-recreate-its-beh
        
        presentsWithGesture = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
