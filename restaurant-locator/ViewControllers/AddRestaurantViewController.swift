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

class AddRestaurantViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        Location.sharedInstance.addCallback(key: "addRestaurantMap", callback: {(latitude, longitude, cityId, cityName) in
            if !self.userLocationLoaded {    // only move to the user location at the first time
                let region = Location().makeRegion(latitude: latitude, longitude: longitude)
                self.restaurantMapView.setRegion(region, animated: true)
                self.userLocationLoaded = true
            }
        })
        
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
            
            let region = Location().makeRegion(latitude: (restaurant.oCoordinate?.latitude)!, longitude: (restaurant.oCoordinate?.longitude)!)
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
        
        // photo
        // ✴️ Attribute:
        // StackOverflow: UIImageView as button
        //      https://stackoverflow.com/questions/11330544/uiimageview-as-button
        
        self.restaurantPhotoImageView.isUserInteractionEnabled = true
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(restaurantPhotoImageViewTapped(_:)))
        singleTap.numberOfTapsRequired = 1;
        self.restaurantPhotoImageView.addGestureRecognizer(singleTap)
        
        // notification picker
        self.notificationPickerData = ["Within 50m", "Within 250m", "Within 500m", "Within 1km", "Never"]
        self.notificationPickerView.delegate = self
        self.notificationPickerView.dataSource = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Location.sharedInstance.removeCallback(key: "addRestaurantMap")
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
