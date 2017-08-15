//
//  RestaurantTableViewController.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 6/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//
//  ✴️ Attributes:
//      1. Bar Button Item
//          StackOverflow: xcode/storyboard: can't drag bar button to toolbar at top
//              https://stackoverflow.com/questions/29435620/xcode-storyboard-cant-drag-bar-button-to-toolbar-at-top
//              Jamal's answer works
//      2. Toggle Master View
//          StackOverflow: Hiding the master view controller with UISplitViewController in iOS8
//              https://stackoverflow.com/questions/27243158/hiding-the-master-view-controller-with-uisplitviewcontroller-in-ios8

import UIKit
import CoreLocation


protocol RestaurantDelegate {
    func addRestaurant(restaurant: Restaurant)
}

class RestaurantTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, RestaurantDelegate {
    
    var category: Category?
    
    var restaurants = [Restaurant]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

//        navigationItem.leftBarButtonItem = editButtonItem
        
        
        // get data
        if let categoryName = category?.name {
            restaurants = Restaurant.fetchByCategory(categoryName: categoryName)
        }
        
        Location.sharedInstance.addCallback(key: "restaurantsDisntance", callback: {(latitude, longitude, cityId, cityName) in
            for i in 0..<self.restaurants.count {
                let restaurant = self.restaurants[i]
                let _ = restaurant.calculateDistance(currentLocation: CLLocation(latitude: latitude, longitude: longitude))
                
                // ✴️ Attribute:
                // StackOverflow: Refresh certain row of UITableView based on Int in Swift
                // https://stackoverflow.com/questions/28206492/refresh-certain-row-of-uitableview-based-on-int-in-swift
                
                let indexPath = IndexPath(item: i, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Location.sharedInstance.removeCallback(key: "restaurantsDisntance")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.restaurants.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath) as! RestaurantTableViewCell
        let restaurant = restaurants[indexPath.row]
        
        cell.restaurantNameLabel.text = restaurant.name
        cell.restaurantPhotoImageView.image = restaurant.getImage()
        cell.restaurantRatingView.settings.fillMode = .precise
        cell.restaurantRatingView.rating = restaurant.rating
        cell.restaurantRatingView.settings.updateOnTouch = false    // disable editing
        cell.restaurantAddressLabel.text = restaurant.address
        
        if let distance = restaurant.distance {
            if (distance < 1000) {
                cell.restaurantDistanceLabel.text = String(format: "%.0f m", distance)
            } else {
                cell.restaurantDistanceLabel.text = String(format: "%.1f km", distance / 1000)
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            restaurants.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddRestaurantSegue" {
            let controller = segue.destination as! AddRestaurantViewController
            controller.category = self.category
            controller.delegate = self
            
            let popoverPresentationController = segue.destination.popoverPresentationController!
            popoverPresentationController.delegate = self
            popoverPresentationController.barButtonItem = sender as? UIBarButtonItem
        }
    }

    
    // MARK: - Presentation Controller - only will be executed on compact screen
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.fullScreen
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        // add navigation bar
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIApplication.shared.statusBarFrame.size.height + 44))
        let navigationItem = UINavigationItem(title: "Add Restaurant")
        let cancelBarButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelBarButtonItemTapped(sender:)))
        navigationItem.leftBarButtonItem = cancelBarButton
        navigationBar.setItems([navigationItem], animated: false)
        controller.presentedViewController.view.addSubview(navigationBar)
        
        // add extra top space
        let addRestaurantViewController = controller.presentedViewController as! AddRestaurantViewController
        addRestaurantViewController.addExtraTopSpaceForCompatScreen()
        
        return controller.presentedViewController
    }
    
    func cancelBarButtonItemTapped(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Data
    
    func addRestaurant(restaurant: Restaurant) {
        self.restaurants.append(restaurant)
        tableView.reloadData()
    }
}
