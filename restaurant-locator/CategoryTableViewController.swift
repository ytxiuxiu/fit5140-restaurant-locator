//
//  MasterViewController.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 5/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//
//  ✴️ Attributes:
//      1. Show Navigation Bar and Close Button on Popover on Compact Screen
//          Website: A Beginner’s Guide to Presentation Controllers in iOS 8
//              http://www.appcoda.com/presentation-controllers-tutorial/
//          Create NavBar programmatically with Button and Title Swift
//              https://stackoverflow.com/questions/33717698/create-navbar-programmatically-with-button-and-title-swift
//      2. Icon Generator
//          Website: MakeAppIcon
//              https://makeappicon.com

import UIKit
import CoreLocation
import UserNotifications


/**
 Category Table Delegate
 */
protocol CategoryTableDelegate {
    
    /**
     Add category, it should add the category to the table
     
     - Parameters:
        - category: Category added
     */
    func addCategory(category: Category)
    
    /**
     Edit category, it should update the cell view of the category
     
     - Parameters:
        - category: Category edited
     */
    func editCategory(category: Category)
    
    /**
     Add restaurant, it should update the number of restaurants in the corresponding category and add region monitor
 
     - Parameters:
        - restaurant: Restaurant added
     */
    func addRestaurant(restaurant: Restaurant)
    
    /**
     Edit restaurant
     
     - Parameters:
        - restaurant: Restaurant edited
     */
    func editRestaurant(restaurant: Restaurant)
    
    /**
     Remove restaurant, it should update the number of restaurants and remove region monitor
     
     - Parameters:
        - restaurant: Restaurant to be removed
     */
    func removeRestaurant(restaurant: Restaurant)
    
    /**
     Show edit category, it should show edit category view
     
     - Parameters:
        - category: Category to be edited
     */
    func showEditCategory(category: Category)
}


/**
 Category table
 */
class CategoryTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, CategoryTableDelegate {

    
    var categories = [Category]()
    
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItems?.append(editButtonItem)
        
        // Init
        categories = Category.fetchAll()
        requestLocationPrivacy()
        setupRegionMonitors()
        calculateNumberOfRestaurants()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
        // Hide the tab bar
        if UIDevice.current.userInterfaceIdiom == .phone {
            tabBarController?.tabBar.isHidden = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Init methods
    
    /**
     Request location privacy
     */
    func requestLocationPrivacy() {
        let locationManager = Location.shared.locationManager
        locationManager.requestAlwaysAuthorization()
    }
    
    /**
     Setup region monitors
     */
    func setupRegionMonitors() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: { (granted,error) in
            guard granted else {
                return
            }
            
            for category in self.categories {
                for restaurant in category.restaurants?.allObjects as! [Restaurant] {
                    if restaurant.notificationRadius != -1 {
                        Location.shared.addMonitor(restaurant: restaurant)
                    }
                }
            }
        })
    }
    
    /**
     Calculate number of restaurants for each category
     */
    func calculateNumberOfRestaurants() {
        for category in categories {
            category.numberOfRestaurants = category.restaurants?.count ?? 0
        }
    }


    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRestaurantsInCategorySegue" {
            // Show restaurant table view
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let category = categories[indexPath.row]
                let controller = segue.destination as! RestaurantTableViewController
                
                controller.category = category
                controller.title = category.name
                //controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                controller.categoryTableDelegate = self
            }
            
        } else if segue.identifier == "showAddCategorySegue" {
            // Show add category view
            
            let controller = segue.destination as! AddCategoryViewController
            
            controller.categoryTableDelegate = self
            controller.sort = categories.count  // new sort
            
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let device = UIDevice.current.userInterfaceIdiom
        
        // If it is a iPad, show following views on top of the detail view controller
        if device == .pad {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            if identifier == "showAddCategorySegue" {
                let controller = storyboard.instantiateViewController(withIdentifier: "editCategoryViewController") as! AddCategoryViewController
                
                controller.categoryTableDelegate = self
                controller.sort = categories.count  // new sort
                
                showViewControllerOnDetailViewController(controller: controller)
                
                return false    // don't do the default segue
            }
        }
        
        return true
    }

    
    // MARK: - Table View Lifecycle

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryTableViewCell
        let category = categories[indexPath.row]
        
        cell.categoryTableDelegate = self
        cell.category = category
        cell.categoryImageView.image = UIImage(named: "category-\(category.icon)")
        cell.categoryNameLabel.text = category.name
        cell.numberOfRestaurantsLabel.text = "\(category.numberOfRestaurants) restaurant\(category.numberOfRestaurants <= 1 ? "" : "s")"
        cell.backgroundColor = Colors.categoryColors[Int(category.color)]
        
        // Toggle edit button
        // ✴️ Attribute:
        // Website: UITableView Custom Edit Button In Each Row With Swift
        //      http://www.iosinsight.com/uitableview-custom-edit-button-in-each-row-with-swift/
        
        if (tableView.isEditing && self.tableView(tableView, canEditRowAt: indexPath)) {
            cell.categoryEditButton.isHidden = false
            cell.categoryEditButtonWidthConstraint.constant = 30
            cell.categoryEditButtonRightConstraint.constant = 8
        } else {
            cell.categoryEditButton.isHidden = true
            cell.categoryEditButtonWidthConstraint.constant = 0
            cell.categoryEditButtonRightConstraint.constant = 0
        }
        
        return cell
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        // Update the view so that it can toggle the edit button
        tableView.reloadData()
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
            let category = categories[indexPath.row]
            
            let alert = UIAlertController(title: "Delete?", message: "Are you sure to delete the category \"\(category.name)\"? It will also delete all restaurants in this category.", preferredStyle: .alert);
            alert.isModalInPopover = true;
            
            // add an action button
            let deleteAction: UIAlertAction = UIAlertAction(title: "Delete", style: .destructive) { action -> Void in
                Data.shared.managedObjectContext.delete(category)
                
                do {
                    try Data.shared.managedObjectContext.save()
                } catch {
                    self.showError(message: "Could not delete the category: \(error)")
                }
                
                self.categories.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
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
    
    // Re-arrange Categories
    // ✴️ Attribute:
    // Website: Reordering Rows from Table View in iOS8 with Swift
    //      https://www.ioscreator.com/tutorials/reordering-rows-table-view-ios8-swift
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let category = categories[sourceIndexPath.row]
        categories.remove(at: sourceIndexPath.row)
        categories.insert(category, at: destinationIndexPath.row)
        
        for i in 0..<categories.count {
            categories[i].sort = Int64(i)
        }
        
        // ⚠️ TODO: save it later, after finish editing
        do {
            try Data.shared.managedObjectContext.save()
        } catch {
            self.showError(message: "Could not re-arrange categoris: \(error)")
        }
    }

    
    // MARK: - Category Table Delegate
    
    func addCategory(category: Category) {
        categories.append(category)
        tableView.reloadData()
    }
    
    func editCategory(category: Category) {
        self.tableView.reloadData()
    }
    
    func removeRestaurant(restaurant: Restaurant) {
        Location.shared.removeMonitor(restaurant: restaurant)
        
        for categoryInTheTable in categories {
            if categoryInTheTable.id == restaurant.category?.id {
                categoryInTheTable.numberOfRestaurants = categoryInTheTable.numberOfRestaurants - 1
                self.tableView.reloadData()
                return
            }
        }
    }
    
    func addRestaurant(restaurant: Restaurant) {
        for categoryInTheTable in categories {
            if categoryInTheTable.id == restaurant.category?.id {
                categoryInTheTable.numberOfRestaurants = categoryInTheTable.numberOfRestaurants + 1
                self.tableView.reloadData()
                return
            }
        }
        
        if restaurant.notificationRadius != -1 {
            Location.shared.removeMonitor(restaurant: restaurant)
        }
    }
    
    func editRestaurant(restaurant: Restaurant) {
        Location.shared.removeMonitor(restaurant: restaurant)
        if restaurant.notificationRadius != -1 {
            Location.shared.removeMonitor(restaurant: restaurant)
        }
    }
    
    func showEditCategory(category: Category) {
        let device = UIDevice.current.userInterfaceIdiom
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
        let controller = storyboard.instantiateViewController(withIdentifier: "editCategoryViewController") as! AddCategoryViewController

        controller.isEdit = true
        controller.category = category
        controller.categoryTableDelegate = self

        if device == .pad {
            showViewControllerOnDetailViewController(controller: controller)
        } else {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

