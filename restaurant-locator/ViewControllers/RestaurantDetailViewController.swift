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


protocol RestaurantDetailDelegate {
    func editRestaurant(restaurant: Restaurant)
}

class RestaurantDetailViewController: UIViewController, RestaurantDetailDelegate {

    @IBOutlet weak var restaurantImageView: UIImageView!
    
    @IBOutlet weak var restaurantRatingView: CosmosView!
    
    @IBOutlet weak var restaurantAddressLabel: UILabel!
    
    @IBOutlet weak var restaurantDistanceLabel: UILabel!
    
    @IBOutlet weak var restaurantAddedAtLabel: UILabel!
    
    @IBOutlet weak var restaurantNotificationRadiusLabel: UILabel!
    
    @IBOutlet weak var restaurantMapView: MKMapView!
    
    var delegate: RestaurantDelegate?
    
    var restaurant: Restaurant?
    
    var restaurantAnnotation: MKPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        editRestaurant(restaurant: restaurant!)
        
        // start loction
        self.restaurantMapView.showsUserLocation = true
        
        let editBarButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editBarButtonItemTapped(sender:)))
        navigationItem.rightBarButtonItem = editBarButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Location.sharedInstance.removeCallback(key: "restaurantDetailMap")
    }
    
    func movePin(latitude: CLLocationDegrees, longitude: CLLocationDegrees, alsoMoveTheMap: Bool = true) {
        if self.restaurantAnnotation == nil {
            self.restaurantAnnotation = MKPointAnnotation()
            
            self.restaurantMapView.addAnnotation(self.restaurantAnnotation!)
        }
        
        self.restaurantAnnotation?.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let region = Location().makeRegion(latitude: latitude, longitude: longitude)
        self.restaurantMapView.setRegion(region, animated: false)
    }
    
    func editBarButtonItemTapped(sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "editRestaurantViewController") as! AddRestaurantViewController
        
        controller.isEdit = true
        controller.restaurant = self.restaurant
        controller.delegate = self.delegate
        controller.restaurantDetailDelegate = self
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    // ✴️ Attributes:
    // StackOverflow: How to open maps App programmatically with coordinates in swift?
    //      https://stackoverflow.com/questions/28604429/how-to-open-maps-app-programmatically-with-coordinates-in-swift
    
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func editRestaurant(restaurant: Restaurant) {
        self.restaurantImageView.image = restaurant.getImage()
        self.restaurantRatingView.rating = restaurant.rating
        self.restaurantRatingView.settings.updateOnTouch = false
        
        self.restaurantAddressLabel.text = restaurant.address
        
        Location.sharedInstance.addCallback(key: "restaurantDetailDisntance", callback: {(latitude, longitude, cityId, cityName) in
            let distance = restaurant.calculateDistance(currentLocation: CLLocation(latitude: latitude, longitude: longitude))
            
            self.restaurantDistanceLabel.text = "\(Location.getDistanceString(distance: distance!)) from here"
            
            // one time call
            Location.sharedInstance.removeCallback(key: "restaurantDetailDisntance")
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
        
        movePin(latitude: restaurant.latitude, longitude: restaurant.longitude)
    }

}
