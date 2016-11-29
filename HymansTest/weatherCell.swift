//
//  weatherCell.swift
//  HymansTest
//
//  Created by Swapnil Dhanwal on 29/11/16.
//  Copyright © 2016 Swapnil Dhanwal. All rights reserved.
//

import UIKit

class weatherCell: UITableViewCell {

    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var max: UILabel!
    @IBOutlet weak var min: UILabel!
    @IBOutlet weak var windspeed: UILabel!
    @IBOutlet weak var conditions: UILabel!
    @IBOutlet weak var clouds: UILabel!
    @IBOutlet weak var pressure: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
