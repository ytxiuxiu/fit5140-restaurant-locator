//
//  CategoryIconsCollectionViewCell.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 5/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//

import UIKit


/**
 Cell for category icon collection
 */
class CategoryIconsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryIconImageView: UIImageView!
    
    
    /**
     Highlight this cell
     */
    func highlight() {
        self.categoryIconImageView.backgroundColor = Colors.blue(alpha: 0.5)
    }
    
    /**
     Lowlight this cell
     */
    func lowlight() {
        self.categoryIconImageView.backgroundColor = UIColor.clear
    }
    
}
