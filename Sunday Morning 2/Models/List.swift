//
//  List.swift
//  Sunday Morning 2
//
//  Created by Corinna Fabre on 7/15/20.
//  Copyright © 2020 Corinna Fabre. All rights reserved.
//

import Foundation

class List {
    var title: String = ""
    var unreadOnly: Bool = false
    var pickLength: String = ""
    
    init(title: String, unreadOnly: Bool, pickLength: String) {
        self.title = title
        self.unreadOnly = unreadOnly
        self.pickLength = pickLength
    }
}


