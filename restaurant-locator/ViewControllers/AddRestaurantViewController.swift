//
//  AddRestaurantViewController.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 6/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//
//  ✴️ Attributes:
//      1. Multiple Detail Split View
//          GitHub: dstarsboy/TMMultiDetailSplitView
//              https://github.com/dstarsboy/TMMultiDetailSplitView
//      2. CocoaPods
//          Website: CocoaPods.org
//              https://cocoapods.org/
//      3. Form auto fill-in
//          Website: Zomato API - Zomato Developers
//              https://developers.zomato.com/api
//          GitHub: apasccon/SearchTextField
//              https://github.com/apasccon/SearchTextField
//      4. Rating
//          GitHub: evgenyneu/Cosmos
//              https://github.com/evgenyneu/Cosmos
//      5. Scroll View
//          Website: UIScrollView Tutorial: Getting Started
//              https://www.raywenderlich.com/159481/uiscrollview-tutorial-getting-started
//      6. Picker View
//          Website: iOS9 UIPickerView Example and Tutorial in Swift and Objective-C
//              http://codewithchris.com/uipickerview-example/


import UIKit
import SearchTextField
import MapKit
import CoreLocation
import Cosmos
import Alamofire

class AddRestaurantViewController: UIViewController, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var restaurantNameSearchTextField: SearchTextField!
    
    @IBOutlet weak var restaurantPhotoImageView: UIImageView!
    
    @IBOutlet weak var restaurantRatingView: CosmosView!
    
    @IBOutlet weak var restaurantAddressTextField: UITextField!
    
    @IBOutlet weak var restaurantMapView: MKMapView!
    
    @IBOutlet weak var notificationPickerView: UIPickerView!
    
    var userLocationLoaded = false
    
    var restaurantSearchResult = [Restaurant]()
    
    var notificationPickerData = [String]()
    
    var restaurantAnnotation: MKPointAnnotation?
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ⚠️ TODO: image size
        self.restaurantPhotoImageView.contentMode = .scaleAspectFit
        
        // rating
        self.restaurantRatingView.settings.fillMode = .precise
        
        // start loction
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        // restaurant suggestion
        self.restaurantNameSearchTextField.theme.bgColor = UIColor.white
        
        // on item selected
        self.restaurantNameSearchTextField.itemSelectionHandler = { filteredResults, itemPosition in
            let restaurant = self.restaurantSearchResult[itemPosition]
            
            // fill the form
            self.restaurantNameSearchTextField.text = restaurant.sName
            self.restaurantAddressTextField.text = restaurant.sAddress
            self.restaurantRatingView.rating = restaurant.fRating!
            
            // download the image
            let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
            Alamofire.download(restaurant.sImageURL!, to: destination)
                .downloadProgress { progress in
                    print("Download Progress: \(progress.fractionCompleted)")
                }
                .responseData { response in
                    if response.error == nil || response.error.debugDescription.contains("already exists"), let imagePath = response.destinationURL?.path {
                        self.restaurantPhotoImageView.image = UIImage(contentsOfFile: imagePath)
                    }
                }
            
            // add an annotation
            if let lastAnnotation = self.restaurantAnnotation {
                self.restaurantMapView.removeAnnotation(lastAnnotation)
            }
            self.restaurantAnnotation = MKPointAnnotation()
            self.restaurantAnnotation?.coordinate = restaurant.oCoordinate!
            self.restaurantAnnotation?.title = restaurant.sName
            self.restaurantMapView.addAnnotation(self.restaurantAnnotation!)
            
            let region = self.makeRegion(latitude: (restaurant.oCoordinate?.latitude)!, longitude: (restaurant.oCoordinate?.longitude)!)
            self.restaurantMapView.setRegion(region, animated: true)
        }
        
        // on user stop typing
        self.restaurantNameSearchTextField.userStoppedTypingHandler = {
            if let keyword = self.restaurantNameSearchTextField.text {
                if keyword.characters.count > 1 {
                    // show the loading indicator
                    self.restaurantNameSearchTextField.showLoadingIndicator()
                    
                    // search restaurants from zomato
                    
                    do {
                        try Zomato.sharedInstance.searchRestaurants(keyword: keyword, closure: {(restaurants: [Restaurant]) in
                            var items = [SearchTextFieldItem]()
                            self.restaurantSearchResult.removeAll()
                        
                            for restaurant in restaurants {
                                self.restaurantSearchResult.append(restaurant)

                                let item = SearchTextFieldItem(title: restaurant.sName, subtitle: restaurant.sAddress/*, image: UIImage(named: "")*/)
                                items.append(item)
                            }
                        
                            self.restaurantNameSearchTextField.filterItems(items)
                            self.restaurantNameSearchTextField.stopLoadingIndicator()
                        })
                    } catch is Error {
                        // ⚠️ TODO: error handling
                    }
                }
            }
        }
        
        // notification picker
        self.notificationPickerData = ["Within 50m", "Within 250m", "Within 500m", "Within 1km", "Never"]
        self.notificationPickerView.delegate = self
        self.notificationPickerView.dataSource = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Location
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0] // most recent location
        
        // show on the map
        if !userLocationLoaded {    // only move to the user location at the first time
            let region = makeRegion(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            self.restaurantMapView.setRegion(region, animated: true)
            userLocationLoaded = true
        }
        self.restaurantMapView.showsUserLocation = true
    }
    
    func makeRegion(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> MKCoordinateRegion {
        let coordinateLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let coordinateSpan: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        return MKCoordinateRegionMake(coordinateLocation, coordinateSpan)
    }
    
    
    // MARK: - Notification Picker
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1    // 1 column
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.notificationPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return notificationPickerData[row]
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func onCancelButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
