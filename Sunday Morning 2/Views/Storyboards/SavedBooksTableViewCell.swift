//
//  SavedBooksTableViewCell.swift
//  Sunday Morning 2
//
//  Created by Corinna Fabre on 7/11/20.
//  Copyright © 2020 Corinna Fabre. All rights reserved.
//

import UIKit

class SavedBooksTableViewCell: UITableViewCell {

    @IBOutlet weak var bookCover: UIImageView!
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookAuthor: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
