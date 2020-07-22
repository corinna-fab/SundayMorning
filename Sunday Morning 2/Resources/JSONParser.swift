//
//  JSONParser.swift
//  Sunday Morning 2
//
//  Created by Corinna Fabre on 7/6/20.
//  Copyright © 2020 Corinna Fabre. All rights reserved.
//

import Foundation

class JSONParser {
    static func parse (data: Data) -> [String: AnyObject]? {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                print("JSON successfully parsed.")
            return json! as [String : AnyObject]
        } catch (let parseError){
            print("There was an error parsing the JSON: \"\(parseError.localizedDescription)\"")
        }
        return nil
    }
}
