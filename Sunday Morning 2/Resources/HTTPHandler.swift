//
//  HTTPHandler.swift
//  Sunday Morning 2
//
//  Created by Corinna Fabre on 7/6/20.
//  Copyright © 2020 Corinna Fabre. All rights reserved.
//

import Foundation

class HTTPHandler {
    static func getJSON(urlString: String, completionHandler: @escaping (Data?) -> (Void)) {
        //Check cache before downloading data
        
        let urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: urlString!)
        
        print("URL being used is \(url!)")
        let session = URLSession.shared
        let task = session.dataTask(with: url!) { data, response, error in
            if let data = data {
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                print("request completed with code: \(statusCode)")
                if (statusCode == 200) {
                    print("return to completion handler with the data")
                    completionHandler(data as Data)
                }
            } else if let error = error {
                print("***There was an error making the HTTP request***")
                print(error.localizedDescription)
                completionHandler(nil)
            }
        }
        task.resume()
    }
}
