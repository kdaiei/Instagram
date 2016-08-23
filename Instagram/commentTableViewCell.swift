//
//  commentTableViewCell.swift
//  Instagram
//
//  Created by kobayashi on 2016/08/22.
//  Copyright © 2016年 hirotaka.kobayashi. All rights reserved.
//

import UIKit

class commentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func setComentData(name:String, comment:String = "") {
        nameLabel.text = name
        
        if "" != comment {
            commentLabel.text = comment
        }
    }
    
}
