//
//  BookDataProcesser.swift
//  Sunday Morning 2
//
//  Created by Corinna Fabre on 7/6/20.
//  Copyright © 2020 Corinna Fabre. All rights reserved.
//

import Foundation

class BookDataProcessor {
    
    static func mapJsonToMovies(object: [String: AnyObject]) -> [Book] {
        var mappedMovies: [Book] = []
        
        guard let movies = object["items"]! as? [[String: AnyObject]] else { return mappedMovies }
        
        for movie in movies {
//            print("THIS IS A MOVIE")
//            print(movie)
            guard let id = movie["id"] as? String,
                let name = movie["volumeInfo"]!["title"] as? String,
                let authorArray = movie["volumeInfo"]!["authors"] as? [String],
                let author = authorArray[0] as? String,
                let imageArray = movie["volumeInfo"]!["imageLinks"] as? AnyObject,
                let imageUrl = imageArray["thumbnail"] as? String,
                let description = movie["volumeInfo"]!["description"] as? String,
                let isbnArray = movie["volumeInfo"]!["industryIdentifiers"] as? [AnyObject],
                let isbn = isbnArray[0]["identifier"] as? String else { continue }

            let movieClass = Book(id: id, title: name, imageUrl: imageUrl, author: author, description: description, isbn: isbn, read: false)
            mappedMovies.append(movieClass)
            print(isbnArray)
        }
        print("This is all of them.")
        print(mappedMovies)
        return mappedMovies
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
