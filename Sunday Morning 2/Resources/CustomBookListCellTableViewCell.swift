//
//  CustomSearchCellTableViewCell.swift
//  Sunday Morning 2
//
//  Created by Corinna Fabre on 7/6/20.
//  Copyright © 2020 Corinna Fabre. All rights reserved.
//

import UIKit

class CustomBookListTableViewCell: UITableViewCell {

    @IBOutlet var bookImageView: UIImageView!
    @IBOutlet var bookTitle: UILabel!
    @IBOutlet var bookAuthor: UILabel!
    @IBOutlet var favButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
