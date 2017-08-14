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


class RestaurantTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    var category: Category?
    
    var restaurants = [Restaurant]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let restaurant = Restaurant(name: "Amarillo", url: "", thumbURL: "", imageURL: "", rating: 3.5, address: "149 Brunswick Street", latitude: -37.81283536536353, longitude: 144.96120929718018)
        restaurants.append(restaurant)
        
        Location.sharedInstance.addCallback(key: "restaurantsDisntance", callback: {(latitude, longitude, cityId, cityName) in
            for i in 0..<self.restaurants.count {
                let restaurant = self.restaurants[i]
                restaurant.calculateDistance(currentLocation: CLLocation(latitude: latitude, longitude: longitude))
                
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
        
        cell.restaurantNameLabel.text = restaurant.sName
        cell.restaurantRatingView.settings.fillMode = .precise
        cell.restaurantRatingView.rating = restaurant.fRating
        cell.restaurantAddressLabel.text = restaurant.sAddress
        
        if let distance = restaurant.fDistance {
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
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddRestaurantSegue" {
            let controller = segue.destination.popoverPresentationController!
            controller.delegate = self
            controller.barButtonItem = sender as? UIBarButtonItem
        }
    }

    
    // MARK: - Presentation Controller - only will be executed on compact screen
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.fullScreen
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        // add navigation bar
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIApplication.shared.statusBarFrame.size.height + 44))
        let navigationItem = UINavigationItem(title: "Add Category")
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
}
