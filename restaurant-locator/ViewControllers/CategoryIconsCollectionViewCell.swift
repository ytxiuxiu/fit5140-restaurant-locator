//
//  CategoryIconsCollectionViewCell.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 5/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//

import UIKit

class CategoryIconsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryIconImageView: UIImageView!
    
    func highlight() {
        self.categoryIconImageView.backgroundColor = Colors.blue(alpha: 0.5)
    }
    
    func lowlight() {
        self.categoryIconImageView.backgroundColor = UIColor.clear
    }
    
}
