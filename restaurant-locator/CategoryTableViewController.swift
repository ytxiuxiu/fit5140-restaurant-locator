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


protocol CategoryTableDelegate {
    func addCategory(category: Category)
    func editCategory(category: Category)
    func reduceNumberOfRestaurants(category: Category)
    func increaseNumberOfRestaurants(category: Category)
}

class CategoryTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, CategoryTableDelegate {

    var restaurantMapViewController: RestaurantMapViewController?
    
    var categories = [Category]()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        categories = Category.fetchAll()
        for category in categories {
            category.numberOfRestaurants = Restaurant.countByCategory(categoryName: category.name)
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
                
                controller.restaurantMapViewController = self.restaurantMapViewController
                controller.category = category
                controller.title = category.name
                //controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                controller.delegate = self
            }
            
        } else if segue.identifier == "showAddCategorySegue" {
            let controller = segue.destination as! AddCategoryViewController
            
            controller.categoryTableDelegate = self
            controller.sort = categories.count  // new sort
            
        }
    }
    
    func showViewControllerOnDetailViewController(controller: UIViewController) {
        // if some view opened on the detail view conroller already, pop it
        if restaurantMapViewController?.navigationController?.viewControllers.last != restaurantMapViewController {
            restaurantMapViewController?.navigationController?.popViewController(animated: false)
            restaurantMapViewController?.navigationController?.pushViewController(controller, animated: false)
        } else {
            restaurantMapViewController?.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let device = UIDevice.current.userInterfaceIdiom
        
        if device == .pad {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            if identifier == "showAddCategorySegue" {
                let controller = storyboard.instantiateViewController(withIdentifier: "editCategoryViewController") as! AddCategoryViewController
                
                controller.restaurantMapViewController = self.restaurantMapViewController
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
        
        cell.categoryImageView.image = UIImage(named: "category-\(category.icon)")
        cell.categoryNameLabel.text = category.name
        cell.numberOfRestaurantsLabel.text = "\(category.numberOfRestaurants) restaurants"
        cell.backgroundColor = Colors.categoryColors[Int(category.color)]
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
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
    
    func reduceNumberOfRestaurants(category: Category) {
        for categoryInTheTable in categories {
            if categoryInTheTable.name == category.name {
                categoryInTheTable.numberOfRestaurants = categoryInTheTable.numberOfRestaurants - 1
                self.tableView.reloadData()
                return
            }
        }
    }
    
    func increaseNumberOfRestaurants(category: Category) {
        for categoryInTheTable in categories {
            if categoryInTheTable.name == category.name {
                categoryInTheTable.numberOfRestaurants = categoryInTheTable.numberOfRestaurants + 1
                self.tableView.reloadData()
                return
            }
        }
    }
}

