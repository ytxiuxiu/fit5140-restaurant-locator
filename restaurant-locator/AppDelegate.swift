//
//  AppDelegate.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 5/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    var masterNavigationController: UINavigationController?
    
    var categoryTableDelegate: CategoryTableDelegate?
    
    var detailNavigationController: UINavigationController?
    
    var restaurantMapDelegate: RestaurantMapDelegate?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let splitViewController = window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count - 1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self
        
        let tabBarController = splitViewController.viewControllers.first as? TabBarController
        self.masterNavigationController = tabBarController?.viewControllers?.first as? UINavigationController
        self.categoryTableDelegate = masterNavigationController?.viewControllers.first as! CategoryTableViewController
        
        self.detailNavigationController = splitViewController.viewControllers.last as? UINavigationController
        self.restaurantMapDelegate = self.detailNavigationController?.viewControllers.first as! RestaurantMapViewController
        
        // Insert default data when first launch
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

    
    // ✴️ Attribute:
    // StackOverflow: Swift- Remove Push Notification Badge number?
    //      https://stackoverflow.com/questions/27769074/swift-remove-push-notification-badge-number
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    /**
     Insert default data
     */
    func insertDefaultData() {
        let categoryJapanese = Category.insertNewObject(id: "0088a457-ab11-4fb3-a7f0-0bf7a8d1572b", name: "Japanese", color: 3, icon: 15, sort: 1)
        let categoryChinese = Category.insertNewObject(id: "0b797cd0-febf-479c-af42-d400feeb4ca0", name: "Chinese", color: 2, icon: 11, sort: 2)
        let categoryCafe = Category.insertNewObject(id: "13c7281a-b72c-49eb-973b-312fbc3452c5", name: "Cafe", color: 4, icon: 2, sort: 3)
        
        // Japanese
        let restaurantGochi = Restaurant.insertNewObject(id: "adf152fc-2dc5-4293-946c-d2f10ace5d41", name: "Gochi Japanese Fusion Tapas", rating: 4.3, address: "19980 Homestead Rd, Cupertino, CA 95014, USA", latitude: 37.3368349, longitude: -122.0226261, notificationRadius: 4)
        restaurantGochi.saveImage(image: UIImage(named: "demo-gochi")!)
        categoryJapanese.addToRestaurants(restaurantGochi)
        
        let restaurantYayoi = Restaurant.insertNewObject(id: "e9a4054d-e68a-43e4-880a-f5a2ed14db60", name: "YAYOI", rating: 4.3, address: "20682 Homestead Rd, Cupertino, CA 95014, USA", latitude: 37.3371498, longitude: -122.0364847, notificationRadius: -1)
        restaurantYayoi.saveImage(image: UIImage(named: "demo-yayoi")!)
        categoryJapanese.addToRestaurants(restaurantYayoi)
        
        let restaurantBaySushi = Restaurant.insertNewObject(id: "a85a4818-b83a-4f75-b11f-f40f8caf236f", name: "Bay Sushi", rating: 4.2, address: "1647 Hollenbeck Ave, Sunnyvale, CA 94087, USA", latitude: 37.3395547, longitude: -122.0426439, notificationRadius: 3)
        restaurantBaySushi.saveImage(image: UIImage(named: "demo-bay-sushi")!)
        categoryJapanese.addToRestaurants(restaurantBaySushi)
        
        // Chinese
        let restaurantShanghaiGarden = Restaurant.insertNewObject(id: "6a7235e2-2b87-4b6d-b760-cb79f1e7e351", name: "Shanghai Garden", rating: 3.9, address: "20956 Homestead Rd, Cupertino, CA 95014, USA", latitude: 37.3367452, longitude: -122.0401997, notificationRadius: 4)
        restaurantShanghaiGarden.saveImage(image: UIImage(named: "demo-shanghai-garden")!)
        categoryChinese.addToRestaurants(restaurantShanghaiGarden)
        
        let restaurantLeiGarden = Restaurant.insertNewObject(id: "7fed4e09-a046-440e-b512-2fef511cfd3c", name: "Lei Garden", rating: 3.8, address: "10125 Bandley Dr, Cupertino, CA 95014, USA", latitude: 37.3246344, longitude: -122.0347423, notificationRadius: -1)
        restaurantLeiGarden.saveImage(image: UIImage(named: "demo-lei-garden")!)
        categoryChinese.addToRestaurants(restaurantLeiGarden)

        let restaurantAppleGreenBistro = Restaurant.insertNewObject(id: "c83cbea9-6778-4a85-943d-96af0de9b3eb", name: "Apple Green Bistro", rating: 4.0, address: "10885 N Wolfe Rd, Cupertino, CA 95014, USA", latitude: 37.3357997, longitude: -122.0157513, notificationRadius: 1)
        restaurantAppleGreenBistro.saveImage(image: UIImage(named: "demo-apple-green")!)
        categoryChinese.addToRestaurants(restaurantAppleGreenBistro)
        
        // Cafe
        let restaurantBagelStreetCafe = Restaurant.insertNewObject(id: "b9e3362d-2e1c-4047-8957-ad61b6b73118", name: "Bagel Street Cafe", rating: 4.2, address: "10591 N De Anza Blvd, Cupertino, CA 95014, USA", latitude: 37.3311769, longitude: -122.031641, notificationRadius: 3)
        restaurantBagelStreetCafe.saveImage(image: UIImage(named: "demo-bagel-street-cafe")!)
        categoryCafe.addToRestaurants(restaurantBagelStreetCafe)
        
        let restaurantLaTerra = Restaurant.insertNewObject(id: "f21743f3-82ab-4fe7-8d6a-c74faf3c0351", name: "La Terra Bakery & Cafe", rating: 4.5, address: "19960 Homestead Rd, Cupertino, CA 95014, USA", latitude: 37.3367832, longitude: -122.0224656, notificationRadius: 2)
        restaurantLaTerra.saveImage(image: UIImage(named: "demo-la-terra")!)
        categoryCafe.addToRestaurants(restaurantLaTerra)

        let restaurantPaneraBread = Restaurant.insertNewObject(id: "a185e475-fc57-4685-a1c5-8d9cd5c64b8c", name: "Panera Bread", rating: 4.5, address: "20807 Stevens Creek Blvd, Cupertino, CA 95014, USA", latitude: 37.3231982, longitude: -122.0380849, notificationRadius: 1)
        restaurantPaneraBread.saveImage(image: UIImage(named: "demo-la-terra")!)
        categoryCafe.addToRestaurants(restaurantPaneraBread)
        
        saveContext()
    }
    
    /**
     Get direcotry url to store files
    
     - Returns: URL
     */
    func getDirecotryURL() -> URL {
        let fileManager = FileManager.default
        
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    
    // MARK: - Split view
    
    // make category table view controller on top when on iPhone (rather than iPad) devices

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? RestaurantMapViewController else { return false }
        if topAsDetailController.mapView == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }
    
    
    // MARK: - Core Data
    
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
