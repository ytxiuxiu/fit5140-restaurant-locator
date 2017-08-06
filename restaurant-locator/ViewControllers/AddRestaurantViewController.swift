//
//  AddRestaurantViewController.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 6/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//
//  ✴️ Attributes:
//      1. Multiple Detail Split View
//          GitHub: dstarsboy/TMMultiDetailSplitView
//              https://github.com/dstarsboy/TMMultiDetailSplitView
//      2. CocoaPods
//          Website: CocoaPods.org
//              https://cocoapods.org/
//      3. Form auto fill-in
//          Website: Zomato API - Zomato Developers
//              https://developers.zomato.com/api
//          GitHub: apasccon/SearchTextField
//              https://github.com/apasccon/SearchTextField

import UIKit
import SearchTextField

class AddRestaurantViewController: UIViewController {
    
    @IBOutlet weak var restaurantNameSearchTextField: SearchTextField!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.restaurantNameSearchTextField.userStoppedTypingHandler = {
            if let keyword = self.restaurantNameSearchTextField.text {
                if keyword.characters.count > 1 {
                    // show the loading indicator
                    self.restaurantNameSearchTextField.showLoadingIndicator()
                    
                    
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
