//
//  CacheManager.swift
//  Sunday Morning 2
//
//  Created by Corinna Fabre on 7/7/20.
//  Copyright © 2020 Corinna Fabre. All rights reserved.
//

import Foundation

class CacheManager {
    
    static var cache = [String: Data]()
    
    static func setImageCache(_ url: String, _ data: Data ) {
        //Store the image and use the URL as the key
        cache[url] = data
    }
    
    static func getImageCache(_ url: String) -> Data? {
        //Try to get the data for the specified url
        return cache[url]
    }
}
