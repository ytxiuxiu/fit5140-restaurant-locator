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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
