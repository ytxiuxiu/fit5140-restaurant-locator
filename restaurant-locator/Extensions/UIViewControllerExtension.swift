//
//  UIViewControllerExtension.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 29/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//

import UIKit


extension UIViewController {
    
    /**
     Show view controller on detail view controller
     
     - Parameters:
        - controller: view controller to show
     */
    func showViewControllerOnDetailViewController(controller: UIViewController) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if let detailNavigationController = appDelegate?.detailNavigationController {
            
            // if some view opened on the detail view conroller already, pop it
            if !(detailNavigationController.viewControllers.last is RestaurantMapViewController) {
                detailNavigationController.popViewController(animated: false)
                detailNavigationController.pushViewController(controller, animated: false)
            } else {
                detailNavigationController.pushViewController(controller, animated: true)
            }
        }
    }
    
    /**
     Show error message using alert
 
     - Parameters:
        - message: Message to be displayed
     */
    func showError(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

}
