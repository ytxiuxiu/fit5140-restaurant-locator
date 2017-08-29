//
//  RestaurantTableViewCell.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 8/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//

import UIKit
import Cosmos

class RestaurantTableViewCell: UITableViewCell {
    
    @IBOutlet weak var restaurantPhotoImageView: UIImageView!
    
    @IBOutlet weak var restaurantNameLabel: UILabel!

    @IBOutlet weak var restaurantRatingView: CosmosView!
    
    @IBOutlet weak var restaurantAddressLabel: UILabel!
    
    @IBOutlet weak var restaurantDistanceLabel: UILabel!
    
    @IBOutlet weak var restaurantEditButton: UIImageView!
    
    @IBOutlet weak var restaurantEditButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var restaurantEditButtonRightConstraint: NSLayoutConstraint!
    
    var restaurant: Restaurant?
    
    var restaurantTableDelegate: RestaurantTableDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onRestaurantEditButtonTapped(_ sender: Any) {
        self.restaurantTableDelegate?.showEditRestaurant(restaurant: restaurant!)
    }
}
