//
//  TabBarController.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 29/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//

import UIKit


/**
 Tab bar controller for iPhone
 */
class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide the tab bar on iPad
        // StackOverflow: How to Hide Tab Bar Controller?
        //      https://stackoverflow.com/questions/7466829/how-to-hide-tab-bar-controller
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.tabBar.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
