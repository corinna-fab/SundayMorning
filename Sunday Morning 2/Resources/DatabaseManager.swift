//
//  DatabaseManager.swift
//  Sunday Morning 2
//
//  Created by Corinna Fabre on 7/4/20.
//  Copyright © 2020 Corinna Fabre. All rights reserved.
//

import Foundation
import FirebaseDatabase

//"final" means that this class cannot be subclassed
final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
}
//MARK: - Account Managemenet
extension DatabaseManager {
    
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void)){
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            
            completion(true)
            
        })
    }
        
    //Email not listed because it's being used as the key -- all other information stored here
    /// Inserts new user to database
    public func insertUser(with user: BookAppUser) {
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ])
    }
}

struct BookAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
//    let profilePictureUrl: URL
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
