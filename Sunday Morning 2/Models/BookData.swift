//
//  BookData.swift
//  Sunday Morning
//
//  Created by Corinna Fabre on 7/1/20.
//  Copyright © 2020 Corinna Fabre. All rights reserved.
//

import Foundation

struct BookData: Decodable {
    let totalItems: Int
    let items: [Items]
}

struct Items: Decodable {
    let volumeInfo: VolumeInfo
}

struct VolumeInfo: Decodable {
    let title: String
    let authors: [String]
    let publishedDate: String
}
