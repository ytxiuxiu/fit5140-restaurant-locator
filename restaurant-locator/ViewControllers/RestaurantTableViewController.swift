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


/**
 Restaurant Table Delegate
 */
protocol RestaurantTableDelegate {
    
    /**
     Add restaurant, it should add the restaurant to the table
     
     - Parameters:
        - restaurant: Restaurant added
     */
    func addRestaurant(restaurant: Restaurant)
    
    /**
     Edit restaurant, it should update the cell view for the restaurant
     
     - Parameters:
        - restaurant: Restaurant edited
     */
    func editRestaurant(restaurant: Restaurant)
    
    /**
     Edit category, it should update title of this view
     
     - Parameters:
        - category: Category edited
     */
    func editCategory(category: Category)
    
    /**
     Show edit restaurant, it should show edit restaurant view
 
     - Parameters:
        - restaurant: Restaurant to be edited
     */
    func showEditRestaurant(restaurant: Restaurant)
}


/**
 Restaurant Table
 */
class RestaurantTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, RestaurantTableDelegate {
    
    @IBOutlet weak var sortingSegmentControl: UISegmentedControl!
    
    var category: Category?
    
    var restaurants = [Restaurant]()
    
    var categoryTableDelegate: CategoryTableDelegate?
    
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItems?.append(editButtonItem)
        
        restaurants = category?.restaurants?.allObjects as! [Restaurant]
        
        // Init
        initSort()
        registerRestaurantDistanceListerner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
        // Show the tab bar on iPhone
        if UIDevice.current.userInterfaceIdiom == .phone {
            tabBarController?.tabBar.isHidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Location.shared.removeCallback(key: "restaurantsDisntance")
    }
    
    
    // MARK: - Init
    
    /**
     Sort restaurants: if the user has defined a customized order, then sort them as this order, otherwise use default order: by added date
     */
    func initSort() {
        if isCustomSort() {
            sort(by: 3)
            self.sortingSegmentControl.selectedSegmentIndex = 3
        } else {
            sort(by: 0)
        }
    }
    
    /**
     Register restaurant distance listener, when the user's current loction updated, update the distance
     */
    func registerRestaurantDistanceListerner() {
        Location.shared.addCallback(key: "restaurantsDisntance", callback: {(latitude, longitude) in
            // Do not update the distance during edit mode because it may crash when the user reorder items.
            // (Attempt to update the same row at the same time)
            guard !self.tableView.isEditing else {
                return
            }
            
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

    
    // MARK: - Table View Lifecycle

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
        if restaurant.notificationRadius != -1 {
            cell.restaurantNotificationImageView.image = UIImage(named: "notification-big")
            cell.restaurantNotificationLabel.text = Location.radiusText[Int(restaurant.notificationRadius)]
        } else {
            cell.restaurantNotificationImageView.image = UIImage(named: "no-notification-big")
            cell.restaurantNotificationLabel.text = "Never"
        }
        cell.restaurantTableDelegate = self
        cell.restaurant = restaurant
        
        if let distance = restaurant.distance {
            cell.restaurantDistanceLabel.text = Location.getDistanceString(distance: distance)
        }
        
        // Toggle edit button
        // ✴️ Attribute:
        // Website: UITableView Custom Edit Button In Each Row With Swift
        //      http://www.iosinsight.com/uitableview-custom-edit-button-in-each-row-with-swift/
        
        if (tableView.isEditing && self.tableView(tableView, canEditRowAt: indexPath)) {
            cell.restaurantEditButton.isHidden = false
            cell.restaurantEditButtonWidthConstraint.constant = 30
            cell.restaurantEditButtonRightConstraint.constant = 8
        } else {
            cell.restaurantEditButton.isHidden = true
            cell.restaurantEditButtonWidthConstraint.constant = 0
            cell.restaurantEditButtonRightConstraint.constant = 0
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Disable swipe to delete because it is too problematic. We can still delete a restaurant in editing mode
    // ✴️ Attribute:
    // StackOverflow: Swift: How to delete with Edit button and deactivate swipe to delete?
    //      https://stackoverflow.com/questions/29672666/swift-how-to-delete-with-edit-button-and-deactivate-swipe-to-delete
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if tableView.isEditing {
            return .delete
        }
        return .none
    }
 
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let restaurant = restaurants[indexPath.row]
            
            let alert = UIAlertController(title: "Delete?", message: "Are you sure to delete the restaurant \"\(restaurant.name)\"?", preferredStyle: .alert);
            alert.isModalInPopover = true;
            
            // add an action button
            let deleteAction: UIAlertAction = UIAlertAction(title: "Delete", style: .destructive) { action -> Void in
                Data.shared.managedObjectContext.delete(restaurant)

                self.restaurants.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                self.categoryTableDelegate?.removeRestaurant(restaurant: restaurant)
                appDelegate.restaurantMapDelegate?.deleteRestaurant(restaurant: restaurant)
                
                do {
                    try Data.shared.managedObjectContext.save()
                } catch {
                    fatalError("Could not delete the restaurant: \(error)")
                }
                
                self.dismiss(animated: true, completion: nil)
            }
            let dismissAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(deleteAction)
            alert.addAction(dismissAction)
            
            present(alert, animated: true, completion: nil)

        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if (editing) {
            // go to custom sorting mode to allow user to re-arrange
            self.sortingSegmentControl.selectedSegmentIndex = 3
            
            sort(by: 3)
            
            self.sortingSegmentControl.isEnabled = false
        } else {
            self.sortingSegmentControl.isEnabled = true
        }
        
        // Update the view so that it can toggle the edit button
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let restaurant = restaurants[sourceIndexPath.row]
        restaurants.remove(at: sourceIndexPath.row)
        restaurants.insert(restaurant, at: destinationIndexPath.row)
        
        for i in 0..<restaurants.count {
            restaurants[i].sort = Int64(i)
        }
        
        // ⚠️ TODO: save it later, after finish editing
        do {
            try Data.shared.managedObjectContext.save()
        } catch {
            self.showError(message: "Could not re-arrange restaurant: \(error)")
        }
    }
    
    
    // MARK: - Tool
    
    /**
     Sort restaurants
    
     - Parameters:
        - by: By index (0/default: added at, 1: name, 2: rating, 3: sort)
     */
    func sort(by: Int) {
        switch by {
        case 1:
            restaurants.sort(by: { (a, b) -> Bool in
                return a.name < b.name
            })
            break;
        case 2:
            restaurants.sort(by: { (a, b) -> Bool in
                return a.rating > b.rating
            })
            break;
        case 3:
            restaurants.sort(by: { (a, b) -> Bool in
                return a.sort < b.sort
            })
            break;
        default:
            // ✴️ Attribute:
            // Check if date is before current date (Swift)
            //      https://stackoverflow.com/questions/26807416/check-if-date-is-before-current-date-swift
            
            restaurants.sort(by: { (a, b) -> Bool in
                return !(a.addedAt as Date > b.addedAt as Date)
            })
            break;
        }
        
        tableView.reloadData()
    }
    
    /**
     Check if it should use custom sorting (when the user has set a customized sort on the restaurants, it should use custom sort instead of default soring - by added at)
 
     - Returns: Whether it should use custom sorting
     */
    func isCustomSort() -> Bool {
        var isCustomSort = false
        for restaurant in restaurants {
            if restaurant.sort > 0 {
                isCustomSort = true
                break;
            }
        }
        return isCustomSort
    }
    
    
    // MARK: - Events
    
    @IBAction func onSortingSegmentChanged(_ sender: Any) {
        let segmentControl = sender as! UISegmentedControl
        let index = segmentControl.selectedSegmentIndex
        
        sort(by: index)
    }
    
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddRestaurantSegue" {
            // Add restaurant view
            
            let controller = segue.destination as! AddRestaurantViewController
            
            controller.category = self.category
            controller.restaurantTableDelegate = self
            controller.categoryTableDelegate = self.categoryTableDelegate
            
            if isCustomSort() {
                controller.sort = self.restaurants.count
            } else {
                controller.sort = 0
            }
            
        } else if segue.identifier == "showRestaurantDetailSegue" {
            // Restaurant detail view
            
            let controller = segue.destination as! RestaurantDetailViewController
            let restaurant = self.restaurants[(self.tableView.indexPathForSelectedRow?.row)!]
            
            controller.title = restaurant.name
            controller.restaurant = restaurant
            controller.restaurantTableDelegate = self
            
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let device = UIDevice.current.userInterfaceIdiom
        
        // If it is a iPad, show following views on top of the detail view controller
        if device == .pad {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            if identifier == "showAddRestaurantSegue" {
                // Add restaurant view
                
                let controller = storyboard.instantiateViewController(withIdentifier: "editRestaurantViewController") as! AddRestaurantViewController
                
                controller.category = self.category
                controller.restaurantTableDelegate = self
                controller.categoryTableDelegate = self.categoryTableDelegate
                
                showViewControllerOnDetailViewController(controller: controller)
                
                return false    // don't do the default segue
                
            } else if identifier == "showRestaurantDetailSegue" {
                // Restaurant detail view
                
                let restaurant = self.restaurants[(tableView.indexPathForSelectedRow?.row)!]
                
                let controller = storyboard.instantiateViewController(withIdentifier: "restaurantDetail") as! RestaurantDetailViewController
                
                controller.title = restaurant.name
                controller.restaurant = restaurant
                controller.restaurantTableDelegate = self
                
                showViewControllerOnDetailViewController(controller: controller)
                
                return false    // don't do the default segue
            }
        }
        
        return true
    }

    
    // MARK: - Restaurant Table Delegate
    
    func addRestaurant(restaurant: Restaurant) {
        self.restaurants.append(restaurant)
        
        // get didtance for this newly added restaurant
        Location.shared.addCallback(key: "newRestaurantDisntance", callback: {(latitude, longitude) in
            let _ = restaurant.calculateDistance(currentLocation: CLLocation(latitude: latitude, longitude: longitude))
            
            // one time call
            Location.shared.removeCallback(key: "newRestaurantDisntance")
        })
        
        tableView.reloadData()
    }
    
    func editRestaurant(restaurant: Restaurant) {
        // get didtance for this edited restaurant
        Location.shared.addCallback(key: "editRestaurantDisntance", callback: {(latitude, longitude) in
            let _ = restaurant.calculateDistance(currentLocation: CLLocation(latitude: latitude, longitude: longitude))
            
            // one time call
            Location.shared.removeCallback(key: "editRestaurantDisntance")
        })
        
        tableView.reloadData()
    }
    
    func editCategory(category: Category) {
        self.title = category.name
    }
    
    func showEditRestaurant(restaurant: Restaurant) {
        let device = UIDevice.current.userInterfaceIdiom
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let controller = storyboard.instantiateViewController(withIdentifier: "editRestaurantViewController") as! AddRestaurantViewController
        
        controller.isEdit = true
        controller.restaurant = restaurant
        controller.restaurantTableDelegate = self
        
        if device == .pad {
            showViewControllerOnDetailViewController(controller: controller)
        } else {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
