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
import CoreLocation

class DetailViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    // ✴️ Attribute:
    // StackOverflow: weak may only be applied to class and class-bound protocol types not <<errortype>>
    //      https://stackoverflow.com/questions/38005594/weak-may-only-be-applied-to-class-and-class-bound-protocol-types-not-errortype
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    
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
        
        // start loction
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0] // most recent location
        
        // get zomato geocode
        Zomato.sharedInstance.getGeoCode(lat: location.coordinate.latitude, lng: location.coordinate.longitude, closure: {(cityId: Int, cityName: String) in
            print(cityId)
            print(cityName)
        })
        
        // prepare region
        let coordinateLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let coordinateSpan: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let coordinateRegion: MKCoordinateRegion = MKCoordinateRegionMake(coordinateLocation, coordinateSpan)
        
        // show on the map
        self.mapView.setRegion(coordinateRegion, animated: true)
        self.mapView.showsUserLocation = true
        
    }

    var detailItem: NSDate? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

