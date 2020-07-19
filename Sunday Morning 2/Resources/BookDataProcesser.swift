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
        print(object)
        var mappedBooks: [Book] = []
        
        guard let books = object["items"]! as? [[String: AnyObject]] else { return mappedBooks }
        print("KEYS: \(books[0]["volumeInfo"])")
        for book in books {
            print("THIS IS A MOVIE")
            
//            print(movie)
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

            print("Movie categories: \(categories)")
            let movieClass = Book(id: id, title: name, imageUrl: imageUrl, author: author, description: description, isbn: isbn, read: false, dateRead: dateRead, pageCount: pageCount, categories: categories, fiction: "NOT SET")
            print("Movie categories after put in Book model: \(movieClass.categories)")
            mappedBooks.append(movieClass)
            print("Movies after new book is added: \(mappedBooks)")
//            print(isbnArray)
        }
        print("This is all of them.")
        print(mappedBooks)
        return mappedBooks
    }
    
        static func mapJsonToReview(object: [String: AnyObject]) {
//            var mappedMovies: [Book] = []
            print(object["book"]!["critic_reviews"])
            
            guard let book_reviews = object["book"]!["critic_reviews"] else { return print("Failed")}
            
            print("These are the book reviews: \(book_reviews)")
//            for review in book_reviews! {
//                print review["pos_or_neg"]
//            }
            
//            guard let movies = object["book"]! as? [String: AnyObject] else { return print("Failed") }
            
//            for movie in movies {
//                print("THIS IS A MOVIE")
    //            print(movie)
                
//                guard let id = movie["id"] as? String,
//                    let name = movie["volumeInfo"]!["title"] as? String,
//                    let authorArray = movie["volumeInfo"]!["authors"] as? [String],
//                    let author = authorArray[0] as? String,
//                    let imageArray = movie["volumeInfo"]!["imageLinks"] as? AnyObject,
//                    let imageUrl = imageArray["thumbnail"] as? String,
//                    let description = movie["volumeInfo"]!["description"] as? String,
//                    let isbnArray = movie["volumeInfo"]!["industryIdentifiers"] as? [AnyObject],
//                    let isbn = isbnArray[0]["identifier"] as? String else { continue }
//
//                let movieClass = Book(id: id, title: name, imageUrl: imageUrl, author: author, description: description, isbn: isbn)
//                mappedMovies.append(movieClass)
//                print(isbnArray)
            }
//            print("This is all of them.")
//            print(mappedMovies)
//            return mappedMovies
        }

//}
