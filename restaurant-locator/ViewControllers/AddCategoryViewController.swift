//
//  AddCategoryViewController.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 5/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//
//  ✴️ Attributes:
//  1. Collection View:
//      Youtube Video: UICollectionView Tutorial: How to Style an iOS Collection View
//          https://www.youtube.com/watch?v=sPTUJZ88HGA
//      Youtube Video: UICollectionView Tutorial: How to Style an iOS Collection View II
//          https://www.youtube.com/watch?v=btIq1JoybBk
//      StackOverflow: uicollectionview remove top padding
//          https://stackoverflow.com/questions/43023384/uicollectionview-remove-top-padding
//      StackOverflow: How can I highlight selected UICollectionView cells? (Swift)
//          https://stackoverflow.com/questions/30598664/how-can-i-highlight-selected-uicollectionview-cells-swift
//  2. Category Icons:
//      Designed by Madebyoliver from Flaticon
//          https://www.flaticon.com/packs/gastronomy-set
//  3. View Border:
//      StackOverflow: UIView with rounded corners and drop shadow?
//          https://stackoverflow.com/questions/4754392/uiview-with-rounded-corners-and-drop-shadow

import UIKit


class AddCategoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    
    @IBOutlet weak var categoryIconsCollectionView: UICollectionView!
    
    @IBOutlet weak var categoryIconsCollectionViewLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var categoryView: UIView!
    
    @IBOutlet weak var categoryIconImageView: UIImageView!
    
    @IBOutlet weak var categoryNameTextField: UITextField!
    
    @IBOutlet weak var categoryColor: UISegmentedControl!
    
    var categoryIcon: Int?
    
    var selectedCategoryIcon: CategoryIconsCollectionViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // category name view
        self.categoryView.layer.borderColor = Constants().colors["grey"]?.cgColor
        self.categoryView.layer.borderWidth = 1
        self.categoryView.layer.cornerRadius = 5
        
        // category icons collection
        self.categoryIconsCollectionView.delegate = self
        self.categoryIconsCollectionView.dataSource = self
        
        // category icons collection layout
        // TODO: change size after rotating - not working
        let cellSize = self.view.frame.width / CGFloat(Int(self.view.frame.width / 60))
        self.categoryIconsCollectionViewLayout.itemSize = CGSize(width: cellSize, height: cellSize)
        self.categoryIconsCollectionViewLayout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 5, right: 2)
        self.categoryIconsCollectionViewLayout.minimumInteritemSpacing = 2
        self.categoryIconsCollectionViewLayout.minimumLineSpacing = 5
        
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
        cell.categoryIconImageView.isOpaque = false
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 28
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryIconCell", for: indexPath) as! CategoryIconsCollectionViewCell
        
        // TODO: not working
        self.categoryIconImageView.image = UIImage(named: "category-\(indexPath.row + 1)")
        
        // TODO: highlight - not working
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryIconCell", for: indexPath) as! CategoryIconsCollectionViewCell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func onAddCategoryButtonClicked(_ sender: Any) {
        
    }
    

}
