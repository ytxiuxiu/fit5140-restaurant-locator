//
//  AddCategoryViewController.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 5/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//
//  Attributes:
//  1. Collection View:
//      Youtube Video: UICollectionView Tutorial: How to Style an iOS Collection View
//          https://www.youtube.com/watch?v=sPTUJZ88HGA
//      Youtube Video: UICollectionView Tutorial: How to Style an iOS Collection View II
//          https://www.youtube.com/watch?v=btIq1JoybBk
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
    
    @IBOutlet weak var categoryNameView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // category name view
        self.categoryNameView.layer.borderColor = UIColor(red: 128, green: 128, blue: 128, alpha: 1).cgColor
        self.categoryNameView.layer.cornerRadius = 5
        
        // category icons collection
        self.categoryIconsCollectionView.delegate = self
        self.categoryIconsCollectionView.dataSource = self
        
        let cellSize = Int(self.view.frame.width / (self.view.frame.width / 60))
        categoryIconsCollectionViewLayout.itemSize = CGSize(width: cellSize, height: cellSize)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Category Icons Collection
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryIconCell", for: indexPath) as! CategoryIconsCollectionViewCell
        
        cell.categoryIconImageView.image = UIImage(named: "category-\(indexPath.row + 1)")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 28
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
