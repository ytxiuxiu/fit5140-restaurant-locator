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

import UIKit

class MasterViewController: UITableViewController, UIPopoverPresentationControllerDelegate {

    var detailViewController: DetailViewController? = nil
    
    var categories = [Category]()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        //let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        //navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        categories = Category.fetchAll()
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
            }
        } else if segue.identifier == "showAddCategorySegue" {
            let controller = segue.destination.popoverPresentationController!
            controller.delegate = self
            controller.barButtonItem = sender as? UIBarButtonItem
        }
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
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            categories[indexPath.row]
            
            categories.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
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
        let addCategoryViewController = controller.presentedViewController as! AddCategoryViewController
        addCategoryViewController.addExtraTopSpaceForCompatScreen()
        
        return controller.presentedViewController
    }
    
    func cancelBarButtonItemTapped(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

