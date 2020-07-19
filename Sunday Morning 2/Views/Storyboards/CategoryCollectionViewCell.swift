//
//  CategoryCollectionViewCell.swift
//  Sunday Morning 2
//
//  Created by Corinna Fabre on 7/17/20.
//  Copyright © 2020 Corinna Fabre. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public func configure(with label: String){
        categoryLabel.text = label
        categoryLabel.sizeToFit()
        categoryLabel.numberOfLines = 0
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "CategoryCollectionViewCell", bundle: nil)
    }
}
