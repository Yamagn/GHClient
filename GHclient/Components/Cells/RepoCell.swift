//
//  RepoCell.swift
//  GHClient
//
//  Created by ymgn on 2020/01/12.
//  Copyright © 2020 ymgn. All rights reserved.
//

import UIKit

class RepoCell: UITableViewCell {
    @IBOutlet weak var repoTypeImage: UIImageView!
    @IBOutlet weak var repoName: UILabel!
    @IBOutlet weak var repoDesc: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
