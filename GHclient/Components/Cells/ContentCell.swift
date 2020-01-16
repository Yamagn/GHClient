//
//  ContentCell.swift
//  GHclient
//
//  Created by ymgn on 2020/01/16.
//  Copyright © 2020 ymgn. All rights reserved.
//

import UIKit

class ContentCell: UITableViewCell {
    @IBOutlet weak var contentType: UIImageView!
    @IBOutlet weak var contentName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
