//
//  BookManager.swift
//  Sunday Morning
//
//  Created by Corinna Fabre on 7/1/20.
//  Copyright © 2020 Corinna Fabre. All rights reserved.
//

import Foundation

protocol BookDelegate {
    func booksFetched(_ books:[BookData])
}

struct BookManager {
    let bookURL = "https://www.googleapis.com/books/v1/volumes?&key=\(K.GOOGLE_API_KEY)"
    
//    var searchResults:
    var delegate: BookDelegate?
    
    func fetchBook(bookName: String) {
        let urlString = "\(bookURL)&q=\(bookName)"
        performRequest(urlString: urlString)
    }
    
    func performRequest(urlString: String) {
//        1. Create URL
        if let url = URL(string: urlString) {
            //        2. Create a URLSession
            let session = URLSession(configuration: .default)
//            3. Give the session a task
            let task = session.dataTask(with: url){ (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                
                if let safeData = data {
                   let searchResults = self.parseJSON(bookData: safeData)
                }
            }
//            4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(bookData: Data) {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(BookData.self, from: bookData)
            self.delegate?.booksFetched([decodedData])
            print("\(decodedData.totalItems) total results")
            print(decodedData.items[0].volumeInfo.title)
            print(decodedData.items[0].volumeInfo.publishedDate)
            print(decodedData.items[0].volumeInfo.authors[0])
            
        } catch {
            print(error)
        }
    }
    
    
}
