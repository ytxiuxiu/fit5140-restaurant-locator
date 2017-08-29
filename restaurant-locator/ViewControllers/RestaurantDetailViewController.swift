//
//  RestaurantDetailViewController.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 16/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//

import UIKit
import Cosmos
import MapKit


/**
 Restaurant Detail Delegate
 */
protocol RestaurantDetailDelegate {
    
    /**
     Edit restaurant, it should update the detail of the restaurant
     
     - Parameters:
        - restaurant: Restaurant edited
     */
    func editRestaurant(restaurant: Restaurant)
}


/**
 Restaurant Detail
 */
class RestaurantDetailViewController: UIViewController, RestaurantDetailDelegate {

    @IBOutlet weak var restaurantImageView: UIImageView!
    
    @IBOutlet weak var restaurantRatingView: CosmosView!
    
    @IBOutlet weak var restaurantRatingLabel: UILabel!
    
    @IBOutlet weak var restaurantAddressLabel: UILabel!
    
    @IBOutlet weak var restaurantDistanceLabel: UILabel!
    
    @IBOutlet weak var restaurantAddedAtLabel: UILabel!
    
    @IBOutlet weak var restaurantNotificationRadiusLabel: UILabel!
    
    @IBOutlet weak var restaurantMapView: MKMapView!
    
    @IBOutlet weak var categoryLabel: UILabel!

    var restaurantTableDelegate: RestaurantTableDelegate?
    
    var restaurantAnnotationDelegate: RestaurantAnnotationDelegate?
    
    var restaurant: Restaurant?
    
    var restaurantAnnotation: MKPointAnnotation?
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateRestaurantDetail(restaurant: restaurant!)
        
        self.restaurantMapView.showsUserLocation = true
        
        let editBarButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editBarButtonItemTapped(sender:)))
        navigationItem.rightBarButtonItem = editBarButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            tabBarController?.tabBar.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Location.shared.removeCallback(key: "restaurantDetailMap")
    }
    
    
    // MARK: - Tools
    
    /**
     Move pin to a certain location

     - Parameters:
        - latitude: Latitude
        - longitude: Longitude
        - alsoMoveTheMap: Whether also move the map to the location
     */
    func movePin(latitude: CLLocationDegrees, longitude: CLLocationDegrees, alsoMoveTheMap: Bool = true) {
        if self.restaurantAnnotation == nil {
            self.restaurantAnnotation = MKPointAnnotation()
            
            self.restaurantMapView.addAnnotation(self.restaurantAnnotation!)
        }
        
        self.restaurantAnnotation?.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let region = Location().makeRegion(latitude: latitude, longitude: longitude)
        self.restaurantMapView.setRegion(region, animated: false)
    }
    
    /**
     Update restaurant detail
     
     - Parameters:
        - restaurant: Restaurant to be updated according to
     */
    func updateRestaurantDetail(restaurant: Restaurant) {
        self.title = restaurant.name
        self.restaurantImageView.image = restaurant.getImage(defaultImage: UIImage(named: "photo-banner")!)
        self.restaurantRatingView.rating = restaurant.rating
        self.restaurantRatingLabel.text = String(format: "%.1f", restaurant.rating)
        self.restaurantRatingView.settings.updateOnTouch = false
        
        self.restaurantAddressLabel.text = restaurant.address
        
        Location.shared.addCallback(key: "restaurantDetailDisntance", callback: {(latitude, longitude) in
            let distance = restaurant.calculateDistance(currentLocation: CLLocation(latitude: latitude, longitude: longitude))
            
            self.restaurantDistanceLabel.text = "\(Location.getDistanceString(distance: distance!)) from here"
            
            // one time call
            Location.shared.removeCallback(key: "restaurantDetailDisntance")
        })
        
        // ✴️ Attributes:
        // StackOverflow: Date Format in Swift
        //      https://stackoverflow.com/questions/35700281/date-format-in-swift
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy"
        self.restaurantAddedAtLabel.text = dateFormatter.string(from: restaurant.addedAt as Date)
        
        if restaurant.notificationRadius != -1 {
            self.restaurantNotificationRadiusLabel.text = Location.radiusText[Int(restaurant.notificationRadius)]
        } else {
            self.restaurantNotificationRadiusLabel.text = "Never"
        }
        
        self.categoryLabel.text = restaurant.category?.name
        
        movePin(latitude: restaurant.latitude, longitude: restaurant.longitude)
    }
    
    
    // MARK: - Events
    
    // ✴️ Attributes:
    // StackOverflow: How to open maps App programmatically with coordinates in swift?
    //      https://stackoverflow.com/questions/28604429/how-to-open-maps-app-programmatically-with-coordinates-in-swift
    
    // On navigation (to this restaurant) tapped
    @IBAction func onNavigationButtonTapped(_ sender: Any) {
        let coordinates = CLLocationCoordinate2D(latitude: (restaurant?.latitude)!, longitude: (restaurant?.longitude)!)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, 1000, 1000)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = restaurant?.name
        mapItem.openInMaps(launchOptions: options)
    }
    
    // One edit bar button item tapped
    func editBarButtonItemTapped(sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "editRestaurantViewController") as! AddRestaurantViewController
        
        controller.isEdit = true
        controller.restaurant = self.restaurant
        controller.restaurantTableDelegate = self.restaurantTableDelegate
        controller.restaurantDetailDelegate = self
        controller.restaurantAnnotationDelegate = self.restaurantAnnotationDelegate
        
        self.navigationController?.pushViewController(controller, animated: true)
    }

}
