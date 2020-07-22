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
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
//MARK: - Account Management
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
    /// Inserts new user to database
    public func insertUser(with user: BookAppUser, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
            ], withCompletionBlock: { error, _ in
                guard error == nil else {
                    print("Failed to write to database")
                    completion(false)
                    return
                }
                
                self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                    if var usersCollection = snapshot.value as? [[String: String]] {
                        //append to user dictionary
                        let newElement = ["name": user.firstName + " " + user.lastName,
                                          "email": user.safeEmail]
                        usersCollection.append(newElement)
                        
                        self.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            completion(true)
                        })
                    } else {
                        //create that array
                        let newCollection: [[String: String]] = [
                            ["name": user.firstName + " " + user.lastName,
                             "email": user.safeEmail]
                        ]
                        
                        self.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            completion(true)
                        })
                    }
                })
        })
    }
    /// Saves user goals and preferences
    public func addUserDetails(goal: Int, favoriteCategories: [String], completion: @escaping (Bool) -> Void){
        //add new message to messages
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        self.database.child("\(currentEmail)/goal2020").setValue(goal)
        self.database.child("\(currentEmail)/favoriteCategories").setValue(favoriteCategories)
        
        completion(true)
    }
    
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void){
        self.database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                print("Failed")
                return
            }
            completion(.success(value))
        }
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedtoFetch))
                return
            }
            completion(.success(value))
        })
    }
    
    public enum DatabaseError: Error {
        case failedtoFetch
    }
}

//MARK: - User book actions
extension DatabaseManager {
    ///Adds a book to the user's "allBooks" folder
    public func addNewBook(with newBook: Book, completion: @escaping (Bool) -> Void){
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        database.child("\(currentEmail)/allBooks").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }
            
            var currentBooks: [[String: Any]]
            // HELP FROM HERE: https://stackoverflow.com/questions/35682683/checking-if-firebase-snapshot-is-equal-to-nil-in-swift
            if snapshot.value is NSNull {
                print("NULL")
                currentBooks = [[String: Any]]()
            } else {
                currentBooks = snapshot.value as! [[String : Any]]
            }
            
            let bookToAdd: [String: Any] = [
                "id": newBook.id as String,
                "author": newBook.author as String,
                "title": newBook.title as String,
                "description": newBook.description as String,
                "isbn": newBook.isbn as String,
                "imageUrl": newBook.imageUrl as String,
                "read": false,
                "dateRead": newBook.dateRead!,
                "pageCount": newBook.pageCount!,
                "categories": newBook.categories as [String],
                "fiction": newBook.fiction as String,
            ]

            currentBooks.append(bookToAdd)
            
            self?.addCategories(updatedCategories: newBook.categories, completion: { result in
                guard result == nil else {
                    completion(false)
                    return
                }
                completion(true)
            })

            strongSelf.database.child("\(currentEmail)/allBooks").setValue(currentBooks, withCompletionBlock: { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
                })
        })
    }
    
    ///Get all books for a given user
    public func getAllBooks(with email: String, unreadOnly: Bool, length: String, genre: String, category: String, completion: @escaping (Result<[Book], Error>) -> Void){
        database.child("\(email)/allBooks").observe(.value, with: { snapshot in
            guard var value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedtoFetch))
                return
            }

            if unreadOnly == true {
                value.removeAll { $0["read"] as! Int == 1 }
            }
            
            value.removeAll { $0["pageCount"] == nil }
            
            if length == "Short" {
                value.removeAll { ($0["pageCount"] as! Int) > 300 }
            } else if length == "Medium" {
                value.removeAll { 300 < ($0["pageCount"] as! Int) || ($0["pageCount"] as! Int)  < 600 }
            } else if length == "Long" {
                value.removeAll { ($0["pageCount"] as! Int) < 900 }
            }
            
            if genre == "Fiction" {
                value.removeAll { ($0["fiction"] as! String == "Nonfiction") }
            } else if genre == "Nonfiction" {
                value.removeAll { ($0["fiction"] as! String == "Fiction") }
            }
            
            if category != "" {
                value.removeAll { ($0["categories"] as! Array<String>).contains(category) == false }
            }
            
            let books: [Book] = value.compactMap({dictionary in
                guard let id = dictionary["id"] as? String,
                    let title = dictionary["title"] as? String,
                    let imageUrl = dictionary["imageUrl"] as? String,
                    let author = dictionary["author"] as? String,
                    let descripton = dictionary["description"] as? String,
                    let isbn = dictionary["isbn"] as? String,
                    let read = false as? Bool,
                    let dateRead = dictionary["dateRead"] as? String,
                    let pageCount = dictionary["pageCount"] as? Int,
                    let categories = dictionary["categories"] as? [String],
                    let fiction = dictionary["fiction"] as? String else {
                        return nil
                }
                
                return Book(id: id, title: title, imageUrl: imageUrl, author: author, description: descripton, isbn: isbn, read: read, dateRead: dateRead, pageCount: pageCount, categories: categories, fiction: fiction)
            })
            completion(.success(books))
        })
    }

    ///Marks a book in the user's folder as read
    public func markRead(with readBook: Book, completion: @escaping (Bool) -> Void){
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        database.child("\(currentEmail)/allBooks").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            let i = value.firstIndex(where: { $0["isbn"] as! String == readBook.isbn })
            self.database.child("\(currentEmail)/allBooks/\(i!)/read").setValue(true)
            
            
            let today = Date()
            let formatter1 = DateFormatter()
            formatter1.dateStyle = .short
            self.database.child("\(currentEmail)/allBooks/\(i!)/dateRead").setValue(formatter1.string(from: today))
            completion(true)
        })
    }
    
    ///Checks to see if the user has read the book or not
    public func checkBook(with readBook: Book, completion: @escaping (Bool) -> Void){
        //add new message to messages
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        database.child("\(currentEmail)/allBooks").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            let i = value.firstIndex(where: { $0["isbn"] as! String == readBook.isbn })
            
            self.database.child("\(currentEmail)/allBooks/\(i!)/read").observe(.value, with: {snapshot in
                
                if snapshot.value as! Int == 1 {
                    completion(true)
                }
                
            })
        })
    }
}

//MARK: - Handles data analytics
extension DatabaseManager {
    ///Get all books for a given user
    public func getBookCount(with email: String, completion: @escaping (Result<Int, Error>) -> Void){
        database.child("\(email)/allBooks").observe(.value, with: { snapshot in
            guard var value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedtoFetch))
                return
            }
            
            value.removeAll { $0["read"] as! Int == 0 }

            completion(.success(value.count))
        })
    }
    
    public func getUnreadBookCount(with email: String, completion: @escaping (Result<Int, Error>) -> Void){
        database.child("\(email)/allBooks").observe(.value, with: { snapshot in
            guard var value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedtoFetch))
                return
            }
            value.removeAll { $0["read"] as! Int == 1 }

            completion(.success(value.count))
        })
    }
    
    public func getGoalCount(with email: String, completion: @escaping (Result<Int, Error>) -> Void){
        database.child("\(email)/goal2020").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? Int else {
                completion(.failure(DatabaseError.failedtoFetch))
                return
            }
            completion(.success(value))
        })
    }
    
    public func getOnTrackStatus(with email: String, completion: @escaping (Result<Int, Error>) -> Void){
        
        var goalCount: Int = 0
        var readCount: Int = 0
            
        getGoalCount(with: email, completion: { result in
            switch result {
            case .success(let goal):
                goalCount = goal
                print("Goal Count: \(goalCount)")
            case .failure(let error):
                print("failed to get book count: \(error)")
            }
        })
        
        getBookCount(with: email, completion: { result in
            switch result {
            case .success(let goal):
                readCount = goal
                print("Read Count: \(readCount)")
            case .failure(let error):
                print("failed to get book count: \(error)")
            }
        })
    
        print("Check goal outside: \(goalCount)")
        let perMonthGoal = (goalCount / 12)
        print("You should be reading this many books per month: \(perMonthGoal)")
        let date = Date() // get a current date instance
        let dateFormatter = DateFormatter() // get a date formatter instance
        let calendar = dateFormatter.calendar // get a calendar instance
        let month = calendar?.component(.month, from: date) // Result: 4
        print("Month: \(month)")
        
        print("You should be at: \(month! * perMonthGoal)")
        
        if (month! * perMonthGoal) < readCount {
            print("You are behind schedule by: \((month! * perMonthGoal) - readCount) books")
        } else {
            print("You are on track")
        }
        
        let margin = (month! * perMonthGoal) - readCount
        
        completion(.success(margin))
    }
}

//MARK: - Handles lists
extension DatabaseManager {
    ///Adds a book to the user's "allBooks" folder
    public func addNewList(unreadOnly: Bool, pickLength: String, title: String, completion: @escaping (Bool) -> Void){
                    //add new message to messages
                    guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                        completion(false)
                        return
                    }
                    
                    let currentEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
                    
                    database.child("\(currentEmail)/customLists").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                        guard let strongSelf = self else {
                            return
                        }
                        
                        var currentLists: [[String: Any]]
                        // HELP FROM HERE: https://stackoverflow.com/questions/35682683/checking-if-firebase-snapshot-is-equal-to-nil-in-swift
                        print("\(snapshot.value)")
                        if snapshot.value is NSNull {
                            print("NULL")
                            currentLists = [[String: Any]]()
                        } else {
                            currentLists = snapshot.value as! [[String : Any]]
                        }

                        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                            completion(false)
                            return
                        }
                        
                        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
                        
                        let listToAdd: [String: Any] = [
                            "title": title as! String,
                            "unreadOnly": unreadOnly as! Bool,
                            "pickLength": pickLength as! String
                        ]
                        currentLists.append(listToAdd)
                        strongSelf.database.child("\(currentEmail)/customLists").setValue(currentLists, withCompletionBlock: { error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            completion(true)
                        })
                    })
                }
    ///Gets all user's custom lists
    public func getAllLists(with email: String, completion: @escaping (Result<[List], Error>) -> Void){
        database.child("\(email)/customLists").observe(.value, with: { snapshot in
            guard var value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedtoFetch))
                return
            }
            
            let lists: [List] = value.compactMap({dictionary in
                guard let title = dictionary["title"] as? String,
                    let unreadOnly = dictionary["unreadOnly"] as? Bool,
                    let pickLength = dictionary["pickLength"] as? String else {
                        return nil
                }
                
                return List(title: title, unreadOnly: unreadOnly, pickLength: pickLength)
            })
            completion(.success(lists))
        })
    }
}

//MARK: - Handles categories
extension DatabaseManager {
///Adds books categories to user's category folder
    //It would make more sense to go back and write the Firebase folder as its own hash map, which would take up a lot less room
    public func addCategories(updatedCategories: [String], completion: @escaping (Bool) -> Void){
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        database.child("\(currentEmail)/categories").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }
            
            var currentCategories: [String]
            // HELP FROM HERE: https://stackoverflow.com/questions/35682683/checking-if-firebase-snapshot-is-equal-to-nil-in-swift
            if snapshot.value is NSNull {
                print("NULL")
                currentCategories = [String]()
            } else {
                currentCategories = snapshot.value as! [String]
            }
            
            currentCategories.append(contentsOf: updatedCategories)
            
            strongSelf.database.child("\(currentEmail)/categories").setValue(currentCategories, withCompletionBlock: { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            })
        })
    }
    
    ///Gets all categories of books the user has saved
    public func getCategories(with email: String, completion: @escaping (Result<[String], Error>) -> Void){
        
        database.child("\(email)/categories").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [String] else {
                completion(.failure(DatabaseError.failedtoFetch))
                return
            }
            
            completion(.success(value))
        })
    }
}

struct BookAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
}
