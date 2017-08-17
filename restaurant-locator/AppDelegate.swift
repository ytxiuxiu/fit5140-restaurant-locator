//
//  AppDelegate.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 5/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//

import UIKit
import CoreData


extension UIViewController {
    
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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let splitViewController = window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self
        
        
        // insert default data when first launch
        // ✴️ Attributes:
        // StackOverflow: Detect first launch of iOS app [duplicate]
        //      https://stackoverflow.com/questions/27208103/detect-first-launch-of-ios-app
        
        if !UserDefaults.standard.bool(forKey: "launchedBefore") {
            self.insertDefaultData()
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func insertDefaultData() {
        let categoryJapanese = Category.insertNewObject(name: "Japanese", color: 3, icon: 15, sort: 1)
        let categoryBakery = Category.insertNewObject(name: "Bakery", color: 2, icon: 1, sort: 2)
        let categoryBrunch = Category.insertNewObject(name: "Brunch", color: 4, icon: 2, sort: 2)
        
        let restaurantRestore = Restaurant.insertNewObject(name: "Restore Cafe Bar", rating: 3.1, address: "18 Derby Road, Caulfield East, Caulfield, Melbourne", latitude: -37.876051, longitude: 145.042027, notificationRadius: 4)
        restaurantRestore.saveImage(image: UIImage(named: "demo-restore-cafe")!)
        categoryJapanese.addToRestaurants(restaurantRestore)
        
        let restaurantSakuraSushi = Restaurant.insertNewObject(name: "Sakura Kaiten Sushi", rating: 4.3, address: "61, Little Collins Street, CBD, Melbourne, VIC", latitude: -37.8129954, longitude: 144.9716862, notificationRadius: 4)
        restaurantSakuraSushi.saveImage(image: UIImage(named: "demo-sakura-sushi")!)
        categoryJapanese.addToRestaurants(restaurantSakuraSushi)
        
        let restaurantHakata = Restaurant.insertNewObject(name: "Hakata Gensuke Ramen Professionals", rating: 4.2, address: "168, Russell Street, CBD, Melbourne, VIC", latitude: -37.8122201, longitude: 144.9682514, notificationRadius: 3)
        restaurantHakata.saveImage(image: UIImage(named: "demo-hakata-gensuke")!)
        categoryJapanese.addToRestaurants(restaurantHakata)
        
        let restaurantCorner = Restaurant.insertNewObject(name: "The Corner Kitchen", rating: 3.2, address: "98 Waverley Road, Malvern East, Melbourne", latitude: -37.876054, longitude: 145.047481, notificationRadius: -1)
        restaurantCorner.saveImage(image: UIImage(named: "demo-corner-kitchen")!)
        categoryBrunch.addToRestaurants(restaurantCorner)

        saveContext()
    }
    
    func getDirecotryURL() -> URL {
        let fileManager = FileManager.default
        
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.detailItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }
    
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "restaurant")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
