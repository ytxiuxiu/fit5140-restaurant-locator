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
import SwiftValidator


class AddRestaurantViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ValidationDelegate, MKLocalSearchCompleterDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var restaurantNameSearchTextField: SearchTextField!
    
    @IBOutlet weak var restaurantNameErrorLabel: UILabel!
    
    @IBOutlet weak var restaurantPhotoImageView: UIImageView!
    
    @IBOutlet weak var restaurantRatingView: CosmosView!
    
    @IBOutlet weak var restaurantAddressTextField: SearchTextField!
    
    @IBOutlet weak var restaurantAddressErrorLabel: UITextField!
    
    @IBOutlet weak var restaurantMapView: MKMapView!
    
    @IBOutlet weak var notificationPickerView: UIPickerView!
    
    @IBOutlet weak var topSpaceConstraint: NSLayoutConstraint!
    
    var category: Category?
    
    var delegate: RestaurantDelegate?
    
    var userLocationLoaded = false
    
    var restaurantSearchResult = [ZomatoRestaurant]()
    
    var notificationPickerData = [String]()
    
    var restaurantAnnotation: MKPointAnnotation?
    
    let locationManager = CLLocationManager()
    
    let validator = Validator()
    
    var restaurantLatitude: CLLocationDegrees?
    
    var restaurantLongitude: CLLocationDegrees?
    
    var currentPin: MKPointAnnotation?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ⚠️ TODO: image size
        self.restaurantPhotoImageView.contentMode = .scaleAspectFit
        
        // rating
        self.restaurantRatingView.settings.fillMode = .precise
        
        // start loction
        Location.sharedInstance.addCallback(key: "addRestaurantMap", callback: {(latitude, longitude, cityId, cityName) in
            
            // fill current address
            Location.getAddress(latitude: latitude, longitude: longitude, callback: { (address) in
                if address != nil {
                    self.restaurantAddressTextField.text = address
                }
            })
            
            self.movePin(latitude: latitude, longitude: longitude)
            
            // unsubscribe, just need location once
            Location.sharedInstance.removeCallback(key: "addRestaurantMap")
        })
        
        // restaurant suggestion
        self.restaurantNameSearchTextField.theme.bgColor = UIColor.white

        // on user stop typing
        self.restaurantNameSearchTextField.userStoppedTypingHandler = {
            if let keyword = self.restaurantNameSearchTextField.text {
                if keyword.characters.count > 1 {
                    // show the loading indicator
                    self.restaurantNameSearchTextField.showLoadingIndicator()
                    
                    // search restaurants from zomato
                    
                    do {
                        try Zomato.sharedInstance.searchRestaurants(keyword: keyword, closure: {(restaurants: [ZomatoRestaurant]) in
                            var items = [SearchTextFieldItem]()
                            self.restaurantSearchResult.removeAll()
                        
                            for restaurant in restaurants {
                                self.restaurantSearchResult.append(restaurant)

                                let item = SearchTextFieldItem(title: restaurant.name, subtitle: restaurant.address/*, image: UIImage(named: "")*/)
                                items.append(item)
                            }
                        
                            self.restaurantNameSearchTextField.filterItems(items)
                            self.restaurantNameSearchTextField.stopLoadingIndicator()
                        })
                    } catch {
                        // ⚠️ TODO: error handling
                    }
                }
            }
        }
        
        // on item selected
        self.restaurantNameSearchTextField.itemSelectionHandler = { filteredResults, itemPosition in
            let restaurant = self.restaurantSearchResult[itemPosition]
            
            // fill the form
            self.restaurantNameSearchTextField.text = restaurant.name
            self.restaurantAddressTextField.text = restaurant.address
            self.restaurantRatingView.rating = restaurant.rating
            
            // download the image
            if let imageURL = restaurant.imageURL {
                let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
                Alamofire.download(imageURL, to: destination)
                    .downloadProgress { progress in
                        print("Download Progress: \(progress.fractionCompleted)")
                    }
                    .responseData { response in
                        if response.error == nil || response.error.debugDescription.contains("already exists"), let imagePath = response.destinationURL?.path {
                            self.restaurantPhotoImageView.image = UIImage(contentsOfFile: imagePath)
                        }
                }
            }
            
            // add an annotation
            if let lastAnnotation = self.restaurantAnnotation {
                self.restaurantMapView.removeAnnotation(lastAnnotation)
            }
            
            self.restaurantAnnotation = MKPointAnnotation()
            self.restaurantAnnotation?.coordinate = CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude)
            self.restaurantAnnotation?.title = restaurant.name
            self.restaurantMapView.addAnnotation(self.restaurantAnnotation!)
            
            let region = Location().makeRegion(latitude: restaurant.latitude, longitude: restaurant.longitude)
            self.restaurantMapView.setRegion(region, animated: true)
        }
        
        // photo
        // ✴️ Attribute:
        // StackOverflow: UIImageView as button
        //      https://stackoverflow.com/questions/11330544/uiimageview-as-button
        
        self.restaurantPhotoImageView.isUserInteractionEnabled = true
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(restaurantPhotoImageViewTapped(_:)))
        singleTap.numberOfTapsRequired = 1;
        self.restaurantPhotoImageView.addGestureRecognizer(singleTap)
        
        // notification picker
        self.notificationPickerData = ["< 50m", "< 100m", "< 250m", "< 500m", "< 1km", "Never"]
        self.notificationPickerView.delegate = self
        self.notificationPickerView.dataSource = self
        
        
        // address
        self.restaurantAddressTextField.theme.bgColor = UIColor.white
        
        self.restaurantAddressTextField.userStoppedTypingHandler = {
            if let keyword = self.restaurantAddressTextField.text {
                if keyword.characters.count > 1 {
                    // show the loading indicator
                    self.restaurantAddressTextField.showLoadingIndicator()
                    
                    let completer = MKLocalSearchCompleter()
                    completer.delegate = self
                    completer.queryFragment = keyword
                }
            }
        }
        
        // ✴️ Attribute:
        // Website: [Swift MapKit Tutorial Series] How to search a place, address or POI on the map
        //      http://sweettutos.com/2015/04/24/swift-mapkit-tutorial-series-how-to-search-a-place-address-or-poi-in-the-map/
        
        self.restaurantAddressTextField.itemSelectionHandler = { filteredResults, itemPosition in
            let item = filteredResults[itemPosition]
            let address = "\(item.title), \(item.subtitle ?? "")"
            
            self.restaurantAddressTextField.text = address
            
            let localSearchRequest = MKLocalSearchRequest()
            localSearchRequest.naturalLanguageQuery = address
            
            let localSearch = MKLocalSearch(request: localSearchRequest)
            localSearch.start { (localSearchResponse, error) -> Void in
                if localSearchResponse == nil {
                    fatalError("Could not found location of this address")
                } else {
                    let latitude = localSearchResponse?.boundingRegion.center.latitude
                    let longitude = localSearchResponse?.boundingRegion.center.longitude
                    
                    if let pinLatitude = latitude, let pinLongitude = longitude {
                        self.movePin(latitude: pinLatitude, longitude: pinLongitude)
                    } else {
                        fatalError("Could not found location of this address")
                    }
                }
            }
        }
        
        // validation
        
        self.validator.registerField(restaurantNameSearchTextField, errorLabel: restaurantNameErrorLabel, rules: [RequiredRule(message: "Give it a name!")])
        
        self.validator.registerField(restaurantAddressTextField, rules: [RequiredRule(message: "Where is this restaurant?")])
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
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
    
    
    // MARK: - Photo
    
    // ✴️ Attribute:
    // Website: Choosing Images with UIImagePickerController in Swift
    //      http://www.codingexplorer.com/choosing-images-with-uiimagepickercontroller-in-swift/
    // Website: Action Sheet Tutorial in iOS8 with Swift
    //      https://www.ioscreator.com/tutorials/action-sheet-tutorial-ios8-swift
    // Website: How to Access Photo Camera and Library in Swift
    //      https://turbofuture.com/cell-phones/Access-Photo-Camera-and-Library-in-Swift
    
    func restaurantPhotoImageViewTapped(_ sender: UIImageView) {
        let optionMenu = UIAlertController(title: nil, message: "Choose a photo for the restaurant", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            // not working on a simulator, please use real device to test
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                // ⚠️ TODO: error handling
            }
        })
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                // ⚠️ TODO: error handling
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(photoLibraryAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.restaurantPhotoImageView.image = pickedImage
        } else {
            // ⚠️ TODO: error handling
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Address
    
    // Auto complete address
    // ✴️ Attributes:
    // StackOverflow: How to implement auto-complete for address using Apple Map Kit
    //      https://stackoverflow.com/questions/33380711/how-to-implement-auto-complete-for-address-using-apple-map-kit
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        var items = [SearchTextFieldItem]()
        
        for result in completer.results {
            let item = SearchTextFieldItem(title: result.title, subtitle: result.subtitle)
            items.append(item)
        }
        
        self.restaurantAddressTextField.filterItems(items)
        self.restaurantAddressTextField.stopLoadingIndicator()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        self.restaurantAddressTextField.stopLoadingIndicator()
    }
    
    func movePin(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        if self.currentPin == nil {
            self.currentPin = MKPointAnnotation()
            
            let currentPinAnnotationView = MKPinAnnotationView(annotation: currentPin, reuseIdentifier: "currentPin")
            
            self.restaurantMapView.addAnnotation(currentPinAnnotationView.annotation!)
        }
        
        self.currentPin?.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let region = Location().makeRegion(latitude: latitude, longitude: longitude)
        self.restaurantMapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "currentPin") ?? MKAnnotationView()
        
        annotationView.isDraggable = true
        
        return annotationView
    }
    
    // MARK: Navigation Bar
    
    // Add extra top space for compat screen as a navigation bar will be added to this popover
    // ✴️ Attributes:
    // StackOverflow: How to change constraints programmatically that is added from storyboard?
    //      https://stackoverflow.com/questions/40583602/how-to-change-constraints-programmatically-that-is-added-from-storyboard
    // StackOverflow: How to add Navigation bar to a view without Navigation controller
    //      https://stackoverflow.com/questions/23859785/how-to-add-navigation-bar-to-a-view-without-navigation-controller
    
    func addExtraTopSpaceForCompatScreen() {
        topSpaceConstraint.constant = UIApplication.shared.statusBarFrame.height + 44   // status bar + navigation bar + original top
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Save
    
    @IBAction func onCancelButtonClicked(_ sender: Any) {
        // self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onAddButtonClicked(_ sender: Any) {
        validator.validate(self)
    }
    
    
    
    func validationSuccessful() {
        
//        let restaurant = Restaurant.insertNewObject(name: restaurantNameSearchTextField.text, rating: restaurantRatingView.rating, address: restaurantAddressTextField.text, latitude: , longitude: <#T##Double#>)
//        
//        if let sort = self.sort, let categoryIcon = self.categoryIcon {
//            let category = Category.insertNewObject(name: self.categoryNameTextField.text!, color: categoryColor.selectedSegmentIndex, icon: categoryIcon, sort: sort)
//            
//            do {
//                try Data.shared.managedObjectContext.save()
//            } catch {
//                fatalError("Could not save category: \(error)")
//            }
//            
//            delegate?.addCategory(category: category)
//            
//            dismiss(animated: true, completion: nil)
//        } else {
//            // ⚠️ TODO: error handling
//        }
    }
    
    func validationFailed(_ errors:[(Validatable ,ValidationError)]) {
        // show validation error
        for (field, error) in errors {
            if let field = field as? UITextField {
                field.layer.borderColor = Colors.red.cgColor
                field.layer.borderWidth = 1.0
            }
            error.errorLabel?.text = error.errorMessage
            error.errorLabel?.isHidden = false
        }
    }
    

}
