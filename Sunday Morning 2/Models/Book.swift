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
    var read: Bool = false
    var dateRead: String?
    var pageCount: Int?
    var categories: [String] = [""]
    var fiction: String = ""
    
    init(id: String, title: String, imageUrl: String, author: String, description: String, isbn: String, read: Bool, dateRead: String, pageCount: Int, categories: [String], fiction: String) {
        self.id = id
        self.title = title
        self.imageUrl = imageUrl
        self.author = author
        self.description = description
        self.isbn = isbn
        self.read = false
        self.dateRead = dateRead
        self.pageCount = pageCount
        self.categories = categories
        self.fiction = fiction
    }
}
