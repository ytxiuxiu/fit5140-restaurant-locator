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


class AddCategoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ValidationDelegate {

    
    @IBOutlet weak var categoryIconsCollectionView: UICollectionView!
    
    @IBOutlet weak var categoryIconsCollectionViewLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var categoryView: UIView!
    
    @IBOutlet weak var categoryIconImageView: UIImageView!
    
    @IBOutlet weak var categoryNameTextField: UITextField!
    
    @IBOutlet weak var categoryNameErrorLabel: UILabel!
    
    @IBOutlet weak var categoryColor: UISegmentedControl!
    
    @IBOutlet weak var topSpaceConstraint: NSLayoutConstraint!
    
    var delegate: CategoryDelegate?
    
    var categoryIcon: Int?
    
    var sort: Int?
    
    var selectedCategoryIcon: CategoryIconsCollectionViewCell?
    
    let validator = Validator()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // category color
        self.categoryColor.addTarget(self, action: #selector(onColorSegmentedValueChanged(sender:)), for: .valueChanged)
        
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
        
        // validation
        validator.registerField(categoryNameTextField, errorLabel: categoryNameErrorLabel, rules: [RequiredRule(message: "Give it a name")])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.categoryIconsCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.top)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Category Icons Collection
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryIconCell", for: indexPath) as! CategoryIconsCollectionViewCell
        
        cell.categoryIconImageView.image = UIImage(named: "category-\(indexPath.row + 1)")
        cell.categoryIconImageView.backgroundColor = UIColor.clear
//        print("Cell init: \(cell.categoryIconImageView.backgroundColor?.cgColor.components)")
        cell.categoryIconImageView.isOpaque = false
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 28
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath) as! CategoryIconsCollectionViewCell
        
//        cell.highlight()
        
        self.categoryIconImageView.image = UIImage(named: "category-\(indexPath.row + 1)")
        self.categoryIcon = indexPath.row + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath) as! CategoryIconsCollectionViewCell
        
//        cell.lowlight()
    }
    
    // MARK: Color Segment
    
    func onColorSegmentedValueChanged(sender: UISegmentedControl) {
        sender.tintColor = Colors.categoryColors[sender.selectedSegmentIndex]
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
    
    // MARK: Save
    
    @IBAction func onAddCategoryButtonClicked(_ sender: Any) {
        
        validator.validate(self)
        
    }
    
    func validationSuccessful() {
        
        if let sort = self.sort, let categoryIcon = self.categoryIcon {
            let category = Category.insertNewObject(name: self.categoryNameTextField.text!, color: categoryColor.selectedSegmentIndex, icon: categoryIcon, sort: sort)
            
            do {
                try Data.shared.managedObjectContext.save()
            } catch {
                fatalError("Could not save category: \(error)")
            }
            
            delegate?.addCategory(category: category)
            
            dismiss(animated: true, completion: nil)
        } else {
            // ⚠️ TODO: error handling
        }
    }
    
    func validationFailed(_ errors:[(Validatable ,ValidationError)]) {
        // show validation error
        for (field, error) in errors {
            if let field = field as? UITextField {
                field.layer.borderColor = Colors.red.cgColor
                field.layer.borderWidth = 1.0
            }
            error.errorLabel?.text = error.errorMessage // works if you added labels
            error.errorLabel?.isHidden = false
        }
    }

}
