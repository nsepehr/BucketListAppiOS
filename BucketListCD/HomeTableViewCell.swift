//
//  HomeTableViewCell.swift
//  BucketListCD
//
//  Created by Nima Sepehr on 12/9/15.
//  Copyright © 2015 Nima Sepehr. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    
    @IBOutlet weak var taskimage: UIImageView!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var createDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
