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
                let imageUrl = "https://images-na.ssl-images-amazon.com/images/I/41yudIp+dmL._SX348_BO1,204,203,200_.jpg" as? String else { continue }

            let movieClass = Book(id: id, title: name, imageUrl: imageUrl)
            mappedMovies.append(movieClass)
        }
        print("This is all of them.")
        return mappedMovies
    }

}
