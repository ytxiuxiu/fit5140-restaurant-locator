//
//  CategoryTableViewCell.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 6/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var categoryImageView: UIImageView!
    
    @IBOutlet weak var categoryNameLabel: UILabel!
    
    @IBOutlet weak var numberOfRestaurantsLabel: UILabel!
    
    @IBOutlet weak var categoryEditButton: UIButton!

    @IBOutlet weak var categoryEditButtonWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var categoryEditButtonRightConstraint: NSLayoutConstraint!
    
    var category: Category?
    
    var categoryTableDelegate: CategoryTableDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onCategoryEditButtonTapped(_ sender: Any) {
        self.categoryTableDelegate?.showEditCategory(category: category!)
    }
    
}
