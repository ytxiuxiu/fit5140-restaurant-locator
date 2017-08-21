//
//  DetailViewController.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 5/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//
//  ✴️ Attributes:
//      1. Map
//          Youtube Video: iOS Swift 3 - Setting up Mapkit
//              https://www.youtube.com/watch?v=wU1XN-Gk1LM
//          Youtube Video: How To Get The User's Current Location In xCode 8 (Swift 3.0)
//              https://www.youtube.com/watch?v=UyiuX8jULF4

import UIKit
import MapKit

// ✴️ Attribute:
// StackOverflow: Cropping image with Swift and put it on center position
//      https://stackoverflow.com/questions/32041420/cropping-image-with-swift-and-put-it-on-center-position

extension UIImage {
    func crop(to:CGSize) -> UIImage {
        guard let cgimage = self.cgImage else { return self }
        
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        
        let contextSize: CGSize = contextImage.size
        
        //Set to square
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        let cropAspect: CGFloat = to.width / to.height
        
        var cropWidth: CGFloat = to.width
        var cropHeight: CGFloat = to.height
        
        if to.width > to.height { // landscape
            cropWidth = contextSize.width
            cropHeight = contextSize.width / cropAspect
            posY = (contextSize.height - cropHeight) / 2
        } else if to.width < to.height { // portrait
            cropHeight = contextSize.height
            cropWidth = contextSize.height * cropAspect
            posX = (contextSize.width - cropWidth) / 2
        } else { // square
            if contextSize.width >= contextSize.height { // square on landscape (or square)
                cropHeight = contextSize.height
                cropWidth = contextSize.height * cropAspect
                posX = (contextSize.width - cropWidth) / 2
            } else { // square on portrait
                cropWidth = contextSize.width
                cropHeight = contextSize.width / cropAspect
                posY = (contextSize.height - cropHeight) / 2
            }
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cropWidth, height: cropHeight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!

        // Create a new image based on the imageRef and rotate back to the original orientation
        let cropped: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        return cropped
    }
}

protocol RestaurantMapDelegate {
    func addRestaurant(restaurant: Restaurant)
    func editRestaurant(restaurant: Restaurant)
    func deleteRestaurant(restaurant: Restaurant)
    func getNavigationController() -> UINavigationController
}

class RestaurantMapViewController: UIViewController, MKMapViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, RestaurantMapDelegate {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    // ✴️ Attribute:
    // StackOverflow: weak may only be applied to class and class-bound protocol types not <<errortype>>
    //      https://stackoverflow.com/questions/38005594/weak-may-only-be-applied-to-class-and-class-bound-protocol-types-not-errortype
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var radiusBarButton: UIBarButtonItem!
    
    let locationManager = CLLocationManager()
    
    var currentRadius = 3
    
    var currentLocation: CLLocationCoordinate2D?
    
    var lastCLLocation: CLLocation?
    
    var radiusCircle: MKCircle?
    
    var restaurants = [Restaurant]()
    
    var displayedRestaurants = [Restaurant]()
    
    var filteredRestaurants = [Restaurant]()
    
    var restaurantAnnotations = [RestaurantAnnotation]()
    
    var restaurantPinImages = [String: UIImage]()
    
    var mapInited = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("view did load")
        
        // menu icon
        // draw the menu button in portrait mode
        if let splitView = self.navigationController?.splitViewController, !splitView.isCollapsed {
            self.navigationItem.leftBarButtonItem = splitView.displayModeButtonItem
        }
        
        // get data
        self.restaurants = Restaurant.fetchAll()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // start loction
        Location.shared.addCallback(key: "mainMap", callback: {(latitude, longitude) in
            self.currentLocation = CLLocationCoordinate2DMake(latitude, longitude)
            
            if !self.mapInited {
                let coordinateSpan: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
                let coordinateRegion: MKCoordinateRegion = MKCoordinateRegionMake(self.currentLocation!, coordinateSpan)
                
                self.mapView.setRegion(coordinateRegion, animated: true)
                self.mapInited = true
            }
            
            self.showRadiusCircle()
            self.filterRestaurants()
            self.showRestaurants()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Location.shared.removeCallback(key: "mainMap")
    }
    
    // add radius circle
    // ✴️ Attribute:
    // StackOverflow: Draw a circle of 1000m radius around users location in MKMapView
    //      https://stackoverflow.com/questions/9056451/draw-a-circle-of-1000m-radius-around-users-location-in-mkmapview
    
    func showRadiusCircle() {
        if let oldCircle = self.radiusCircle {
            self.mapView.remove(oldCircle)
        }
        if let location = self.currentLocation {
            self.radiusCircle = MKCircle(center: location, radius: Location.radius[self.currentRadius])
            self.mapView.add(self.radiusCircle!)
        }
    }
    
    func filterRestaurants() {
        self.filteredRestaurants = self.restaurants.filter() {
            let restaurant = $0
            
            if let location = self.currentLocation {
                let distanceToCurrentLocation = restaurant.calculateDistance(currentLocation: CLLocation(latitude: location.latitude, longitude: location.longitude))
                
                if let distance = distanceToCurrentLocation {
                    return distance < Location.radius[self.currentRadius]
                } else {
                    return false;
                }
            } else {
                return false;
            }
        }
    }
    
    
    @IBAction func onCenterButtonTapped(_ sender: Any) {
        let coordinateSpan: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let coordinateRegion: MKCoordinateRegion = MKCoordinateRegionMake(self.mapView.userLocation.coordinate, coordinateSpan)
        
        self.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    // show restaurant annotations on the map
    // ✴️ Attributes:
    // StackOverflow: iOS Swift MapKit Custom Annotation [closed]
    //      https://stackoverflow.com/questions/38274115/ios-swift-mapkit-custom-annotation
    // Website: Working with MapKit: Annotations and Shape Rendering
    //      http://www.appcoda.com/mapkit-beginner-guide/
    
    func showRestaurants() {
        
        // ✴️ Attributes:
        // StackOverflow: Set operations (union, intersection) on Swift array?
        //      https://stackoverflow.com/questions/24589181/set-operations-union-intersection-on-swift-array
        // Documentation: subtract(_:)
        //      https://developer.apple.com/documentation/swift/set/1779475-subtract

        var toBeRemoved: Set<Restaurant> = Set(displayedRestaurants)
        var toBeAdded: Set<Restaurant> = Set(filteredRestaurants)
        let displayed: Set<Restaurant> = Set(displayedRestaurants)
        
        // restaurants to be removed = last displayed restaurants - newly filtered restaurants
        toBeRemoved.subtract(toBeAdded)
        
        // restaurants to be added = newly filtered restaurants - last displayed restaurants
        toBeAdded.subtract(displayed)
        
        for restaurantAnnotation in restaurantAnnotations {
            if toBeRemoved.contains(restaurantAnnotation.restaurant!) {
                self.mapView.removeAnnotation(restaurantAnnotation)
            }
        }
        
        for restaurant in toBeAdded {
            let restaurantAnnotation = RestaurantAnnotation()
            restaurantAnnotation.coordinate = CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude)
            restaurantAnnotation.restaurant = restaurant

            self.restaurantAnnotations.append(restaurantAnnotation)
            self.mapView.addAnnotation(restaurantAnnotation)
        }
        
        self.displayedRestaurants = self.filteredRestaurants
    }
    
    // ✴️ Attribute:
    // Website: Building The Perfect IOS Map (II): Completely Custom Annotation Views
    //      https://digitalleaves.com/blog/2016/12/building-the-perfect-ios-map-ii-completely-custom-annotation-views/
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is RestaurantAnnotation) {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "restaurantAnnotationView") as? RestaurantAnnotationView
        
        if annotationView == nil {
            annotationView = RestaurantAnnotationView(annotation: annotation, reuseIdentifier: "restaurantAnnotationView")
        } else {
            annotationView?.annotation = annotation
        }

        let restaurantAnnotation = annotation as! RestaurantAnnotation
        
        // ✴️ Attribute:
        // StackOverflow: MKAnnotation image offset with custom pin image
        //      https://stackoverflow.com/questions/8165262/mkannotation-image-offset-with-custom-pin-image
        
        annotationView?.centerOffset = CGPoint(x: 3, y: -59 / 2)
        annotationView?.image = generatePinImage(for: restaurantAnnotation)
        annotationView?.navigationController = self.navigationController
        annotationView?.restaurant = restaurantAnnotation.restaurant
        annotationView?.restaurantMapViewController = self
        
        return annotationView
    }
    
    
    // generate pin image for a restaurant annotation
    // ✴️ Attribute:
    // StackOverflow: Saving an image on top of another image in Swift
    // https://stackoverflow.com/questions/29062225/saving-an-image-on-top-of-another-image-in-swift
    
    func generatePinImage(for restaurantAnnotation: RestaurantAnnotation) -> UIImage {
        let restaurant = restaurantAnnotation.restaurant
        let restaurantPinImage = restaurantPinImages[restaurant?.image ?? ""]
        
        if restaurantPinImage != nil {
            return restaurantPinImage!
        } else {
            let pinSize = CGSize(width: 53, height: 59)
            let backgroundSize = CGSize(width: 50, height: 56)
            let imageSize = CGSize(width: 40, height: 40)
            let cropedRestaurantImage = restaurant?.getImage().crop(to: imageSize)
            let pinBackgroundImage = UIImage(named: "pin")
            let notificationImage = UIImage(named: "notification")
            
            UIGraphicsBeginImageContext(pinSize)
            
            cropedRestaurantImage?.draw(in: CGRect(origin: CGPoint(x: 8, y: 8), size: imageSize))
            pinBackgroundImage?.draw(in: CGRect(origin: CGPoint(x: 3, y: 3), size: backgroundSize))
            
            if restaurant?.notificationRadius != -1 {
                notificationImage?.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: 16, height: 16)))
            }
            
            restaurantAnnotation.image = UIGraphicsGetImageFromCurrentImageContext()
            
            // cache pin image
            restaurantPinImages.updateValue(restaurantAnnotation.image!, forKey: (restaurant?.image ?? "")!)
            
            UIGraphicsEndImageContext()
            
            return restaurantPinImages[restaurant!.image ?? ""]!
        }
        
        
    }
    
    // customized annotation
    // ✴️ Attribute:
    // Website: How To Completely Customise Your Map Annotations Callout Views
    //      http://sweettutos.com/2016/03/16/how-to-completely-customise-your-map-annotations-callout-views/
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if !(view.annotation is RestaurantAnnotation) {
            return
        }
        
        // move map to the pin
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
    }
    
    // draw radius circle
    // ✴️ Attribute:
    // StackOverflow: Draw a circle of 1000m radius around users location in MKMapView
    //      https://stackoverflow.com/questions/9056451/draw-a-circle-of-1000m-radius-around-users-location-in-mkmapview
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.red
            circle.fillColor = UIColor(red: 50, green: 0, blue: 0, alpha: 0.1)
            circle.lineWidth = 2
            return circle
        } else {
            return MKPolylineRenderer()
        }
    }
    
    
    // MARK: Radius Picker
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Location.radiusText.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Location.radiusText[row]
    }
    
    
    // ✴️ Attribute
    // StackOverflow: Sizing a UIPickerView inside a UIAlertView
    //      https://stackoverflow.com/questions/41361177/sizing-a-uipickerview-inside-a-uialertview
    
    @IBAction func onRadiusClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Filter Restaurants", message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert);
        alert.isModalInPopover = true;
        
        let picker = UIPickerView(frame: CGRect(x: 0, y: 50, width: 260, height: 162))
        picker.delegate = self
        picker.selectRow(self.currentRadius, inComponent: 0, animated: false)
        
        // add an action button
        let filterAction: UIAlertAction = UIAlertAction(title: "Filter", style: .default) { action -> Void in
            
            self.currentRadius = picker.selectedRow(inComponent: 0)
            
            // change radius bar button text
            // ✴️ Attribute
            // StackOverflow: How to change the text of a BarButtonItem on the NavigationBar?
            //      https://stackoverflow.com/questions/12257522/how-to-change-the-text-of-a-barbuttonitem-on-the-navigationbar
            
            let radiusText = Location.radiusText[self.currentRadius]
            self.radiusBarButton.title = radiusText
            
            self.showRadiusCircle()
            self.filterRestaurants()
            self.showRestaurants()
            
            self.dismiss(animated: true, completion: nil)
        }
        let dismissAction: UIAlertAction = UIAlertAction(title: "Back", style: .cancel) { action -> Void in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(filterAction)
        alert.addAction(dismissAction)
        alert.view.addSubview(picker)
        
        present(alert, animated: true, completion: nil)
    }
    
    func addRestaurant(restaurant: Restaurant) {
        self.restaurants.append(restaurant)
        
        self.filterRestaurants()
        self.showRestaurants()
    }
    
    func editRestaurant(restaurant: Restaurant) {
        for restaurantAnnotation in restaurantAnnotations {
            if restaurantAnnotation.restaurant == restaurant {
                
                // ✴️ Attribute
                // StackOverflow: iOS refresh annotations on mapview
                //      https://stackoverflow.com/questions/14131345/ios-refresh-annotations-on-mapview
                
                self.mapView.removeAnnotation(restaurantAnnotation)
                restaurantPinImages.remove(at: restaurantPinImages.index(forKey: restaurant.image ?? "")!)
                
                restaurantAnnotation.coordinate = CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude)
                restaurantAnnotation.image = self.generatePinImage(for: restaurantAnnotation)
                
                self.mapView.addAnnotation(restaurantAnnotation)
                break;
            }
        }
    }
    
    func deleteRestaurant(restaurant: Restaurant) {
        var i = 0
        for oldRestaurant in restaurants {
            if oldRestaurant == restaurant {
                break
            }
            i = i + 1
        }
        restaurants.remove(at: i)
        restaurantPinImages.remove(at: restaurantPinImages.index(forKey: restaurant.image ?? "")!)
        
        self.filterRestaurants()
        self.showRestaurants()
    }
    
    func getNavigationController() -> UINavigationController {
        return self.navigationController!
    }
    
}

