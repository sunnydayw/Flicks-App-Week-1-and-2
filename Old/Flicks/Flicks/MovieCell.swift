//
//  MovieCell.swift
//  Flicks
//
//  Created by QingTian Chen on 1/27/16.
//  Copyright © 2016 QingTian Chen. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moiveTimeLabel: UILabel!
    @IBOutlet weak var movieScroeLabel: UILabel!
    @IBOutlet weak var moviePopularLabel: UILabel!
    @IBOutlet weak var movieTaglineLabel: UILabel!
    @IBOutlet weak var posterView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
