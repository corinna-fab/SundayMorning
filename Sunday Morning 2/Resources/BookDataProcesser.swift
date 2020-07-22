//
//  BookDataProcesser.swift
//  Sunday Morning 2
//
//  Created by Corinna Fabre on 7/6/20.
//  Copyright © 2020 Corinna Fabre. All rights reserved.
//

import Foundation

class BookDataProcessor {
    
    static func mapJSONToBook(object: [String: AnyObject]) -> [Book] {
        var mappedBooks: [Book] = []
        
        guard let books = object["items"]! as? [[String: AnyObject]] else { return mappedBooks }
        for book in books {
            
            guard let id = book["id"] as? String,
                let name = book["volumeInfo"]!["title"] as? String,
                let authorArray = book["volumeInfo"]!["authors"] as? [String],
                let author = authorArray[0] as? String,
                let imageArray = book["volumeInfo"]!["imageLinks"] as? AnyObject,
                let imageUrl = imageArray["thumbnail"] as? String,
                let description = book["volumeInfo"]!["description"] as? String,
                let isbnArray = book["volumeInfo"]!["industryIdentifiers"] as? [AnyObject],
                let isbn = isbnArray[0]["identifier"] as? String,
                let pageCount = book["volumeInfo"]?["pageCount"] as? Int,
                //volumeInfo has categories
                let dateRead = "" as? String,
                var categories = book["volumeInfo"]?["categories"] as? [String] else { continue }

            let bookClass = Book(id: id, title: name, imageUrl: imageUrl, author: author, description: description, isbn: isbn, read: false, dateRead: dateRead, pageCount: pageCount, categories: categories, fiction: "NOT SET")
            mappedBooks.append(bookClass)
        }
        return mappedBooks
    }
}
