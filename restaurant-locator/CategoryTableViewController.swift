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


protocol CategoryTableDelegate {
    func addCategory(category: Category)
    func editCategory(category: Category)
    func addRestaurant(restaurant: Restaurant)
    func removeRestaurant(restaurant: Restaurant)
    func editRestaurant(restaurant: Restaurant)
    func showEditCategory(category: Category)
}

class CategoryTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, CategoryTableDelegate {

    var categories = [Category]()
    
    var isGrantedNotificationAccess = false


    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItems?.append(editButtonItem)
        
        categories = Category.fetchAll()
        
        // request location authorization
        let locationManager = Location.shared.locationManager
        locationManager.requestAlwaysAuthorization()
        
        // notification
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: { (granted,error) in
            guard !granted else {
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
        
        // number of restaurants
        for category in categories {
            category.numberOfRestaurants = category.restaurants?.count ?? 0
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRestaurantsInCategorySegue" {
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
            let controller = segue.destination as! AddCategoryViewController
            
            controller.categoryTableDelegate = self
            controller.sort = categories.count  // new sort
            
        }
    }
    
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
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let device = UIDevice.current.userInterfaceIdiom
        
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

    
    // MARK: - Table View

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
        cell.numberOfRestaurantsLabel.text = "\(category.numberOfRestaurants) restaurants"
        cell.backgroundColor = Colors.categoryColors[Int(category.color)]
        
        // Add edit button
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

    
    // MARK: - Presentation Controller - only will be executed on compact screen
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.fullScreen
    }
    
    func addCategory(category: Category) {
        categories.append(category)
        tableView.reloadData()
    }
    
    func editCategory(category: Category) {
        self.tableView.reloadData()
    }
    
    func removeRestaurant(restaurant: Restaurant) {
        for categoryInTheTable in categories {
            if categoryInTheTable.name == restaurant.category?.name {
                categoryInTheTable.numberOfRestaurants = categoryInTheTable.numberOfRestaurants - 1
                self.tableView.reloadData()
                return
            }
        }
        
        Location.shared.removeMonitor(restaurant: restaurant)
    }
    
    func addRestaurant(restaurant: Restaurant) {
        for categoryInTheTable in categories {
            if categoryInTheTable.name == restaurant.category?.name {
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

