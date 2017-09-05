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
//      3. Address auto fill-in
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


/**
 Add Restaurant
 */
class AddRestaurantViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ValidationDelegate, MKLocalSearchCompleterDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var restaurantNameSearchTextField: SearchTextField!
    
    @IBOutlet weak var restaurantNameErrorLabel: UILabel!
    
    @IBOutlet weak var restaurantPhotoImageView: UIImageView!
    
    @IBOutlet weak var restaurantRatingView: CosmosView!
    
    @IBOutlet weak var restaurantRatingLabel: UILabel!
    
    @IBOutlet weak var restaurantAddressTextField: SearchTextField!
    
    @IBOutlet weak var restaurantAddressErrorLabel: UILabel!
    
    @IBOutlet weak var restaurantMapView: MKMapView!
    
    @IBOutlet weak var notificationPickerView: UIPickerView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var isEdit = false
    
    var restaurant: Restaurant?
    
    var category: Category?
    
    var restaurantTableDelegate: RestaurantTableDelegate?
    
    var restaurantDetailDelegate: RestaurantDetailDelegate?
    
    var restaurantAnnotationDelegate: RestaurantAnnotationDelegate?
    
    var categoryTableDelegate: CategoryTableDelegate?
    
    var userLocationLoaded = false
    
    var notificationPickerData = [String]()
    
    var restaurantAnnotation: MKPointAnnotation?
    
    let locationManager = CLLocationManager()
    
    let validator = Validator()
    
    var restaurantLatitude: CLLocationDegrees?
    
    var restaurantLongitude: CLLocationDegrees?
    
    var currentPin: MKPointAnnotation?
    
    /**
     Current radius selected
     */
    var currentRaidus = Location.radius.count   // Never by default (out of index)
    
    var radiusCircle: MKCircle?
    
    /**
     If the photo is selected
     */
    var isPhotoSelected = false
    
    /**
     The sort of the new restaurant should be
     */
    var sort: Int?
    
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Save button
        let saveBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(onAddButtonClicked(_:)))
        self.navigationItem.rightBarButtonItem = saveBarButtonItem
        
        // Map
        self.restaurantMapView.delegate = self
        
        // Notification picker
        self.notificationPickerView.delegate = self
        self.notificationPickerView.dataSource = self
        
        initRating()
        initPhoto()
        initAddress()
        initNotificationPicker()
        initValidation();
        
        if !isEdit {
            initAddMode()
        } else {
            initEditMode()
        }
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
    }
    
    // MARK: - Init
    /**
     Init rating
     */
    func initRating() {
        self.restaurantRatingView.settings.fillMode = .precise
        self.restaurantRatingView.didTouchCosmos = { rating in
            self.restaurantRatingLabel.text = String(format: "%.1f", rating)
        }
    }
    
    // ✴️ Attribute:
    // StackOverflow: UIImageView as button
    //      https://stackoverflow.com/questions/11330544/uiimageview-as-button
    
    /**
     Init photo
     */
    func initPhoto() {
        self.restaurantPhotoImageView.isUserInteractionEnabled = true
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(restaurantPhotoImageViewTapped(_:)))
        singleTap.numberOfTapsRequired = 1;
        self.restaurantPhotoImageView.addGestureRecognizer(singleTap)
    }
    
    /**
     Init address
     */
    func initAddress() {
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
                    self.showError(message: "Could not found location of this address.")
                } else {
                    let latitude = localSearchResponse?.boundingRegion.center.latitude
                    let longitude = localSearchResponse?.boundingRegion.center.longitude
                    
                    if let pinLatitude = latitude, let pinLongitude = longitude {
                        self.movePin(latitude: pinLatitude, longitude: pinLongitude)
                    } else {
                        self.showError(message: "Could not found location of this address.")
                    }
                }
            }
        }
    }
    
    /**
     Init notification picker
     */
    func initNotificationPicker() {
        // Never by default (out of index)
        self.notificationPickerView.selectRow(Location.radius.count, inComponent: 0, animated: false)
    }
    
    /**
     Init add mode
     */
    func initAddMode() {
        Location.shared.addCallback(key: "addRestaurantMap", callback: {(latitude, longitude) in
            
            // fill current address
            Location.getAddress(latitude: latitude, longitude: longitude, callback: { (address, error) in
                guard address != nil else {
                    // ignore the error
                    return
                }
                
                self.restaurantAddressTextField.text = address
            })
            
            self.movePin(latitude: latitude, longitude: longitude)
            
            // unsubscribe, just need location once
            Location.shared.removeCallback(key: "addRestaurantMap")
        })
    }
    
    /**
     Init edit mode
     */
    func initEditMode() {
        // fill all the fields with values
        self.restaurantNameSearchTextField.text = restaurant?.name
        if restaurant?.image != nil {
            self.isPhotoSelected = true
            self.restaurantPhotoImageView.image = restaurant?.getImage(defaultImage: UIImage(named: "photo-banner")!)
        } else {
            self.restaurantPhotoImageView.image = UIImage(named: "photo-add")
        }
        self.restaurantRatingView.rating = (restaurant?.rating)!
        self.restaurantRatingLabel.text = String(format: "%.1f", (restaurant?.rating)!)
        self.restaurantAddressTextField.text = restaurant?.address
        
        movePin(latitude: (restaurant?.latitude)!, longitude: (restaurant?.longitude)!)
        
        self.currentRaidus = Int((restaurant?.notificationRadius)!)
        if restaurant?.notificationRadius != -1 {
            self.notificationPickerView.selectRow(Int((restaurant?.notificationRadius)!), inComponent: 0, animated: false)
        } else {
            self.notificationPickerView.selectRow(Location.radius.count, inComponent: 0, animated: false)
        }
        
        // change title and button
        self.title = "Edit Restaurant"
    }
    
    /**
     Init validation
     */
    func initValidation() {
        self.validator.registerField(restaurantNameSearchTextField, errorLabel: restaurantNameErrorLabel, rules: [RequiredRule(message: "Give it a name!")])
        
        self.validator.registerField(restaurantAddressTextField, rules: [RequiredRule(message: "Where is this restaurant?")])
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
                self.showError(message: "Could not access to your camera")
            }
        })
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                self.showError(message: "Could not access to your photo library")
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            optionMenu.dismiss(animated: true, completion: nil)
        })
        
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(photoLibraryAction)
        optionMenu.addAction(cancelAction)
        
        
        // ✴️ Attribute:
        // StackOverflow: UIActionSheet from Popover with iOS8 GM
        //      https://stackoverflow.com/questions/25759885/uiactionsheet-from-popover-with-ios8-gm
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            optionMenu.popoverPresentationController?.sourceView = self.restaurantPhotoImageView
            optionMenu.popoverPresentationController?.sourceRect = self.restaurantPhotoImageView.bounds
        }
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject: AnyObject]) {
        self.restaurantPhotoImageView.image = image
        self.isPhotoSelected = true
        
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Address
    
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
    
    func movePin(latitude: CLLocationDegrees, longitude: CLLocationDegrees, alsoMoveTheMap: Bool = true) {
        if self.currentPin == nil {
            self.currentPin = MKPointAnnotation()
            
            // ✴️ Attributes:
            // StackOverflow: Swift Annotation Not Placed on MapView because viewForAnnotation not called
            //      https://stackoverflow.com/questions/41948828/swift-annotation-not-placed-on-mapview-because-viewforannotation-not-called
            DispatchQueue.main.async {
                self.restaurantMapView.addAnnotation(self.currentPin!)
            }
        }
        
        self.currentPin?.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        if alsoMoveTheMap {
            let region = Location.shared.makeRegion(latitude: latitude, longitude: longitude)
            self.restaurantMapView.setRegion(region, animated: true)
        }
    }
    
    
    // MARK: - Dragging pin
    
    // ✴️ Attributes:
    // StackOverflow: How to drag an annotation with MKMapView being dragged? (iOS)
    //      https://stackoverflow.com/questions/33188663/how-to-drag-an-annotation-with-mkmapview-being-dragged-ios
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "restaurantAnnotationView")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "restaurantAnnotationView")
        } else {
            annotationView?.annotation = annotation
        }
        annotationView?.image = UIImage(named: "pin-add")
        annotationView?.isDraggable = true
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == .ending {
            if let latitude = view.annotation?.coordinate.latitude, let longitude = view.annotation?.coordinate.longitude {
            
                Location.getAddress(latitude: latitude, longitude: longitude) { (address, error) in
                    guard address != nil else {
                        if error != nil {
                            print("Could not get address: \(error!)")
                        }
                        return
                    }
                    
                    self.restaurantAddressTextField.text = address
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        Location.getAddress(latitude: latitude, longitude: longitude) { (address, error) in
            guard address != nil else {
                if error != nil {
                    print("Could not get address: \(error!)")
                }
                return
            }
            
            self.restaurantAddressTextField.text = address
        }
        
        movePin(latitude: latitude, longitude: longitude, alsoMoveTheMap: false)
    }
    
    
    // MARK: - Notification Picker
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1    // 1 column
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Location.radiusText.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row < Location.radius.count {
            return Location.radiusText[row]
        } else {
            return "Never"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row < Location.radius.count {
            self.currentRaidus = row
        } else {
            self.currentRaidus = -1 // never notify
        }
    }
    
    
    // MARK: - Save
    
    // Save button tapped
    @IBAction func onAddButtonClicked(_ sender: Any) {
        validator.validate(self)
    }
    
    // Validation successful
    func validationSuccessful() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if let categories = categoryTableDelegate?.getAllCategories() {
            // Count how many restaurants have notification
            var count = 0
            for category in categories {
                if let restaurants = category.restaurants {
                    for restaurant in restaurants.allObjects as NSArray as! [Restaurant] {
                        guard count < 20 else {
                            return
                        }
                        
                        if restaurant.notificationRadius != -1 {
                            count = count + 1
                        }
                    }
                }
            }
            
            if count >= 20 {
                self.showError(message: "Sorry, you can only get notification for up to 20 restaurants.")
                return
            }
        }
        
        if !isEdit {
            if let latitude = self.currentPin?.coordinate.latitude, let longitude = self.currentPin?.coordinate.longitude {
                let uuid = UUID().uuidString
                let restaurant = Restaurant.insertNewObject(id: uuid, name: self.restaurantNameSearchTextField.text!, rating: self.restaurantRatingView.rating, address: restaurantAddressTextField.text!, latitude: latitude, longitude: longitude, notificationRadius: self.currentRaidus)
                
                self.category?.addToRestaurants(restaurant)
                
                if isPhotoSelected {
                    restaurant.saveImage(image: self.restaurantPhotoImageView.image!)
                }
                
                do {
                    try Data.shared.managedObjectContext.save()
                } catch {
                    self.showError(message: "Could not save restaurant: \(error)")
                }
                
                self.restaurantTableDelegate?.addRestaurant(restaurant: restaurant)
                self.categoryTableDelegate?.addRestaurant(restaurant: restaurant)
                appDelegate.restaurantMapDelegate?.addRestaurant(restaurant: restaurant)
                
                dismiss(animated: true, completion: nil)
            } else {
                self.showError(message: "Please pick the current location of this restaurant. You see this message may be because you have not let this application access to your location.")
                return
            }
            
        } else {
            if let latitude = self.currentPin?.coordinate.latitude, let longitude = self.currentPin?.coordinate.longitude {
                self.restaurant?.name = self.restaurantNameSearchTextField.text!
                self.restaurant?.rating = self.restaurantRatingView.rating
                self.restaurant?.address = restaurantAddressTextField.text!
                self.restaurant?.latitude = latitude
                self.restaurant?.longitude = longitude
                self.restaurant?.notificationRadius = Int64(self.currentRaidus)
                self.restaurant?.sort = Int64(self.sort ?? 0)
                
                if isPhotoSelected {
                    restaurant?.saveImage(image: self.restaurantPhotoImageView.image!)
                } else {
                    // ⚠️ TODO: delete the image
                }
                
                do {
                    try Data.shared.managedObjectContext.save()
                } catch {
                    self.showError(message: "Could not save restaurant: \(error)")
                }
                
                self.restaurantTableDelegate?.editRestaurant(restaurant: self.restaurant!)
                self.restaurantDetailDelegate?.editRestaurant(restaurant: self.restaurant!)
                self.restaurantAnnotationDelegate?.editRestaurant(restaurant: self.restaurant!)
                appDelegate.restaurantMapDelegate?.editRestaurant(restaurant: self.restaurant!)

            } else {
                self.showError(message: "Please pick the current location of this restaurant. You see this message may be because you have not let this application access to your location.")
                return
            }
        }
        
        let device = UIDevice.current.userInterfaceIdiom
        
        if device == .phone {
            self.navigationController?.popViewController(animated: true)
        } else if device == .pad {
            appDelegate.detailNavigationController?.popViewController(animated: true)
        }
    }
    
    // On validation failed
    func validationFailed(_ errors:[(Validatable ,ValidationError)]) {
        // show validation error
        var i = 0
        for (field, error) in errors {
            if let field = field as? UITextField {
                field.layer.borderColor = Colors.red(alpha: 0.7).cgColor
                field.layer.borderWidth = 1.0
            }
            
            if let label = error.errorLabel {
                // scroll to the first error
                if i == 0 {
                    scrollView.scrollToView(view: label, animated: true)
                }
                
                label.text = error.errorMessage
                label.isHidden = false
            }
            
            i = i + 1
        }
        
        
    }
    

}
