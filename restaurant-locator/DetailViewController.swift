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

class DetailViewController: UIViewController, MKMapViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    // ✴️ Attribute:
    // StackOverflow: weak may only be applied to class and class-bound protocol types not <<errortype>>
    //      https://stackoverflow.com/questions/38005594/weak-may-only-be-applied-to-class-and-class-bound-protocol-types-not-errortype
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var radiusBarButton: UIBarButtonItem!
    
    let locationManager = CLLocationManager()
    
    let radiusText = ["< 50m", "< 100m", "< 250m", "< 500m", "< 1km"]
    
    let radius = [50.0, 100.0, 250.0, 500.0, 1000.0]
    
    var currentRadius = 3
    
    var currentLocation: CLLocationCoordinate2D?
    
    var radiusCircle: MKCircle?
    
    var restaurants = [Restaurant]()
    
    var restaurantAnnotations = [RestaurantAnnotation]()
    
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // menu icon
        // draw the menu button in portrait mode
        if let splitView = self.navigationController?.splitViewController, !splitView.isCollapsed {
            self.navigationItem.leftBarButtonItem = splitView.displayModeButtonItem
        }
        // ⚠️ TODO: change open master button icon to menu - not working
        self.navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: nil, action: nil)
        
        
        let restaurant = Restaurant(name: "Restore Cafe Bar", url: "", thumbURL: "", imageURL: "", rating: 3.1, address: "18 Derby Road, Caulfield East, Caulfield, Melbourne", latitude: -37.876051, longitude: 145.042027)
        restaurants.append(restaurant)
        
        
        mapView.delegate = self
        
        // start loction
        Location.sharedInstance.addCallback(key: "mainMap", callback: {(latitude, longitude, cityId, cityName) in
            // prepare region
            self.currentLocation = CLLocationCoordinate2DMake(latitude, longitude)
            let coordinateSpan: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
            let coordinateRegion: MKCoordinateRegion = MKCoordinateRegionMake(self.currentLocation!, coordinateSpan)
            
            self.mapView.setRegion(coordinateRegion, animated: true)
            
            // add radius circle
            // ✴️ Attribute:
            // StackOverflow: Draw a circle of 1000m radius around users location in MKMapView
            //      https://stackoverflow.com/questions/9056451/draw-a-circle-of-1000m-radius-around-users-location-in-mkmapview
            
            self.showRadiusCircle()
            self.showRestaurants(restaurants: self.filterRestaurants())
        })
        
        configureView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // self.navigationItem.leftBarButtonItem?.image = UIImage(named: "menu")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Location.sharedInstance.removeCallback(key: "mainMap")
    }
    
    var detailItem: NSDate? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    func showRadiusCircle() {
        if let oldCircle = self.radiusCircle {
            self.mapView.remove(oldCircle)
        }
        if let location = self.currentLocation {
            self.radiusCircle = MKCircle(center: location, radius: self.radius[self.currentRadius])
            self.mapView.add(self.radiusCircle!)
        }
    }
    
    func filterRestaurants() -> [Restaurant] {
        return self.restaurants.filter() {
            let restaurant = $0
            
            if let location = self.currentLocation {
                let distanceToCurrentLocation = restaurant.calculateDistance(currentLocation: CLLocation(latitude: location.latitude, longitude: location.longitude))
                
                if let distance = distanceToCurrentLocation {
                    return distance < self.radius[self.currentRadius]
                } else {
                    return false;
                }
            } else {
                return false;
            }
        }
    }
    
    
    // show restaurant annotations on the map
    // ✴️ Attribute:
    // StackOverflow: iOS Swift MapKit Custom Annotation [closed]
    //      https://stackoverflow.com/questions/38274115/ios-swift-mapkit-custom-annotation
    // Website: Working with MapKit: Annotations and Shape Rendering
    //      http://www.appcoda.com/mapkit-beginner-guide/
    
    func showRestaurants(restaurants: [Restaurant]) {
        self.mapView.removeAnnotations(self.restaurantAnnotations)
        
        for restaurant in restaurants {
            let restaurantAnnotation = RestaurantAnnotation(image: UIImage(named: "amarillo")!, name: restaurant.sName, address: restaurant.sAddress, isNotification: true, notificationDistance: 250)
            restaurantAnnotation.coordinate = CLLocationCoordinate2D(latitude: restaurant.fLatitude, longitude: restaurant.fLongitude)
                
            let restaurantAnnotationView = MKPinAnnotationView(annotation: restaurantAnnotation, reuseIdentifier: "restaurantPin")
                
            self.restaurantAnnotations.append(restaurantAnnotationView.annotation! as! RestaurantAnnotation)
            self.mapView.addAnnotation(restaurantAnnotationView.annotation! as! RestaurantAnnotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "restaurantPin") ?? MKAnnotationView()

        if !(annotation is RestaurantAnnotation) {
            return nil
        }
        let restaurantAnnotation = annotation as! RestaurantAnnotation
        
        annotationView.annotation = annotation
        annotationView.canShowCallout = false
        annotationView.image = generatePinImage(for: restaurantAnnotation)
        
        return annotationView
    }
    
    // generate pin image for a restaurant annotation
    // ✴️ Attribute:
    // StackOverflow: Saving an image on top of another image in Swift
    // https://stackoverflow.com/questions/29062225/saving-an-image-on-top-of-another-image-in-swift
    
    func generatePinImage(for restaurantAnnotation: RestaurantAnnotation) -> UIImage {
        if restaurantAnnotation.pinImage == nil {
            let pinSize = CGSize(width: 53, height: 59)
            let backgroundSize = CGSize(width: 50, height: 56)
            let imageSize = CGSize(width: 40, height: 40)
            let cropedRestaurantImage = restaurantAnnotation.image.crop(to: imageSize)
            let pinBackgroundImage = UIImage(named: "pin")
            let notificationImage = UIImage(named: "notification")
            
            UIGraphicsBeginImageContext(pinSize)
            
            cropedRestaurantImage.draw(in: CGRect(origin: CGPoint(x: 8, y: 8), size: imageSize))
            pinBackgroundImage?.draw(in: CGRect(origin: CGPoint(x: 3, y: 3), size: backgroundSize))
            notificationImage?.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: 16, height: 16)))
            
            restaurantAnnotation.pinImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        return restaurantAnnotation.pinImage!
    }
    
    // customized annotation
    // ✴️ Attribute:
    // Website: How To Completely Customise Your Map Annotations Callout Views
    //      http://sweettutos.com/2016/03/16/how-to-completely-customise-your-map-annotations-callout-views/
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if !(view.annotation is RestaurantAnnotation) {
            return
        }
        let restaurantAnnotation = view.annotation as! RestaurantAnnotation
        
        let views = Bundle.main.loadNibNamed("RestaurantCalloutView", owner: nil, options: nil)
        let calloutView = views?[0] as! RestaurantCalloutView
        
        calloutView.restaurantImageView.image = restaurantAnnotation.image
        calloutView.restaurantNameLabel.text = restaurantAnnotation.name
        calloutView.restaurantAddressLabel.text = restaurantAnnotation.address
        
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height * 0.52)
        calloutView.layer.cornerRadius = 5
        view.addSubview(calloutView)
        
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
        return radiusText.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return radiusText[row]
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
            
            let radiusText = self.radiusText[self.currentRadius]
            self.radiusBarButton.title = radiusText
            
            self.showRadiusCircle();
            self.showRestaurants(restaurants: self.filterRestaurants())
            
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
}

