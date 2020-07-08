//
//  Book.swift
//  Sunday Morning 2
//
//  Created by Corinna Fabre on 7/6/20.
//  Copyright © 2020 Corinna Fabre. All rights reserved.
//

import Foundation

class Book {
    var id: String = ""
    var title: String = ""
    var imageUrl: String = ""
    var author: String = ""
    var description: String = ""
    var isbn: String = ""
    
    init(id: String, title: String, imageUrl: String, author: String, description: String, isbn: String) {
        self.id = id
        self.title = title
        self.imageUrl = imageUrl
        self.author = author
        self.description = description
        self.isbn = isbn
    }
}
