//
//  AddCategoryViewController.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 5/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//
//  ✴️ Attributes:
//      1. Collection View:
//          Youtube Video: UICollectionView Tutorial: How to Style an iOS Collection View
//              https://www.youtube.com/watch?v=sPTUJZ88HGA
//          Youtube Video: UICollectionView Tutorial: How to Style an iOS Collection View II
//              https://www.youtube.com/watch?v=btIq1JoybBk
//          StackOverflow: uicollectionview remove top padding
//              https://stackoverflow.com/questions/43023384/uicollectionview-remove-top-padding
//          StackOverflow: How can I highlight selected UICollectionView cells? (Swift)
//              https://stackoverflow.com/questions/30598664/how-can-i-highlight-selected-uicollectionview-cells-swift
//      2. Category Icons:
//          Designed by Madebyoliver from Flaticon
//              https://www.flaticon.com/packs/gastronomy-set
//      3. View Border:
//          StackOverflow: UIView with rounded corners and drop shadow?
//              https://stackoverflow.com/questions/4754392/uiview-with-rounded-corners-and-drop-shadow
//      3. Validation:
//          GitHub: SwiftValidatorCommunity/SwiftValidator
//              https://github.com/SwiftValidatorCommunity/SwiftValidator


import UIKit
import SwiftValidator


/**
 Add Category
 */
class AddCategoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ValidationDelegate {
    
    @IBOutlet weak var categoryIconsCollectionView: UICollectionView!
    
    @IBOutlet weak var categoryIconsCollectionViewLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var categoryView: UIView!
    
    @IBOutlet weak var categoryIconImageView: UIImageView!
    
    @IBOutlet weak var categoryNameTextField: UITextField!
    
    @IBOutlet weak var categoryNameErrorLabel: UILabel!
    
    @IBOutlet weak var categoryColor: UISegmentedControl!
    
    var isEdit = false
    
    var category: Category?
    
    var restaurantTableDelegate: RestaurantTableDelegate?
    
    var categoryTableDelegate: CategoryTableDelegate?
    
    /**
     The sort of this new category should be
     */
    var sort: Int?
    
    /**
     Currently selected category icon
     */
    var selectedCategoryIcon = 1
    
    let validator = Validator()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Save button
        let saveBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(onAddCategoryButtonClicked(_:)))
        self.navigationItem.rightBarButtonItem = saveBarButtonItem
        
        // Register category color segment event
        self.categoryColor.addTarget(self, action: #selector(onColorSegmentedValueChanged(sender:)), for: .valueChanged)
        
        // Init
        initCategoryIconCollection()
        initValidation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the tab bar
        if UIDevice.current.userInterfaceIdiom == .phone {
            tabBarController?.tabBar.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.categoryIconsCollectionView.selectItem(at: IndexPath(row: selectedCategoryIcon - 1, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.top)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Init
    
    /**
     Init category icon collection
     */
    func initCategoryIconCollection() {
        // category icons collection
        self.categoryIconsCollectionView.delegate = self
        self.categoryIconsCollectionView.dataSource = self
        
        // category icons collection layout
        // ⚠️ TODO: change size after rotating - not working
        let cellSize = self.view.frame.width / CGFloat(Int(self.view.frame.width / 60))
        self.categoryIconsCollectionViewLayout.itemSize = CGSize(width: cellSize, height: cellSize)
        self.categoryIconsCollectionViewLayout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 5, right: 2)
        self.categoryIconsCollectionViewLayout.minimumInteritemSpacing = 2
        self.categoryIconsCollectionViewLayout.minimumLineSpacing = 5
    }
    
    /**
     Init validation
     */
    func initValidation() {
        validator.registerField(categoryNameTextField, errorLabel: categoryNameErrorLabel, rules: [RequiredRule(message: "Give it a name")])
        
        if isEdit {
            self.categoryNameTextField.text = category?.name
            
            let color = Int((category?.color)!)
            self.categoryColor.selectedSegmentIndex = color
            self.categoryColor.tintColor = Colors.categorySegmentColors[color]
            
            let icon = Int((category?.icon)!)
            self.selectedCategoryIcon = icon
            self.categoryIconImageView.image = UIImage(named: "category-\(icon)")
            
            self.title = "Edit Category"
        }
    }
    
    // MARK: - Category Icons Collection Lifecycle
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryIconCell", for: indexPath) as! CategoryIconsCollectionViewCell
        
        cell.categoryIconImageView.image = UIImage(named: "category-\(indexPath.row + 1)")
        cell.categoryIconImageView.backgroundColor = UIColor.clear
        cell.categoryIconImageView.isOpaque = false
        cell.categoryIconImageView.layer.cornerRadius = 5
        
        if indexPath.row == self.selectedCategoryIcon - 1 {
            cell.highlight()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 28
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryIconsCollectionViewCell
        
        cell.highlight()
        
        self.categoryIconImageView.image = UIImage(named: "category-\(indexPath.row + 1)")
        self.selectedCategoryIcon = indexPath.row + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryIconsCollectionViewCell
        
        cell.lowlight()
    }
    
    // MARK: Color Segment
    
    func onColorSegmentedValueChanged(sender: UISegmentedControl) {
        sender.tintColor = Colors.categorySegmentColors[sender.selectedSegmentIndex]
    }

    
    // MARK: Save
    
    // Save button tapped
    @IBAction func onAddCategoryButtonClicked(_ sender: Any) {
        validator.validate(self)
    }
    
    // Validation successful
    func validationSuccessful() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if !isEdit {
            // For editing
            
            if let sort = self.sort {
                let uuid = UUID().uuidString
                let category = Category.insertNewObject(id: uuid, name: self.categoryNameTextField.text!, color: categoryColor.selectedSegmentIndex, icon: selectedCategoryIcon, sort: sort)
                
                do {
                    try Data.shared.managedObjectContext.save()
                    
                    categoryTableDelegate?.addCategory(category: category)
                    
                    dismiss(animated: true, completion: nil)
                } catch {
                    if (error.localizedDescription.contains("NSConstraintConflict")) {
                        self.showError(message: "You already have a category with the same name.")
                    } else {
                        self.showError(message: "Could not save category: \(error)")
                    }
                    return
                }
                
                
            } else {
                fatalError("No sort provided")
            }
        } else {
            // For adding
            
            category?.name = self.categoryNameTextField.text!
            category?.color = Int64(categoryColor.selectedSegmentIndex)
            category?.icon = Int64(selectedCategoryIcon)
            
            restaurantTableDelegate?.editCategory(category: category!)
            categoryTableDelegate?.editCategory(category: category!)
            
            do {
                try Data.shared.managedObjectContext.save()
            } catch {
                self.showError(message: "Could not save category: \(error)")
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
        for (field, error) in errors {
            if let field = field as? UITextField {
                field.layer.borderColor = Colors.red(alpha: 0.7).cgColor
                field.layer.borderWidth = 1.0
            }
            error.errorLabel?.text = error.errorMessage // works if you added labels
            error.errorLabel?.isHidden = false
        }
    }

}
