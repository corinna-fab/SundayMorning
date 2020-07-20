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
    
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void){
        self.database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                print("Failed")
                return
            }
            completion(.success(value))
        }
    }
}

//Mark: - Searches users for new conversations
extension DatabaseManager {
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

//Conversation Collection = [MessageThreads]
//MessageThreads = [Message]
//Mark: - Sending messages/conversations
///This extension maps out the conversation schema
extension DatabaseManager {
    ///Creates a new conversation with target user email and first message sent
    
    //This will be equivalent to creating a new list or the root list
    public func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void){
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
            let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
                return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        let ref = database.child("\(safeEmail)")
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("User not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            var message = ""
            
            switch firstMessage.kind{
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .custom(_):
                break
            }
            
            let conversationID = "conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String: Any] = [
                "id": conversationID,
                "name": name,
                "other_user_email": otherUserEmail,
                "latest_message": [
                    "date": dateString,
                    "is_read": false,
                    "message": message]]
            
            let recipient_newConversationData: [String: Any] = [
                "id": conversationID,
                "name": currentName,
                "other_user_email": safeEmail,
                "latest_message": [
                    "date": dateString,
                    "is_read": false,
                    "message": message]]
            
            //Update recipient conversation entry
            self.database.child("\(otherUserEmail)/conversations/").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    // append
                    conversations.append(recipient_newConversationData)
                    self?.database.child("\(otherUserEmail)/conversations/").setValue(conversationID)
                } else {
                    //create
                    self?.database.child("\(otherUserEmail)/conversations/").setValue([recipient_newConversationData])
                }
            })
            
            //Update current user conversation entry
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                //conversation array exists for current user
                // append
                // otherwise create
                
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(conversationID: conversationID, name: name, firstMessage: firstMessage, completion: completion)
                })
            } else {
                //conversation array does not exist
                //create it
                userNode["conversations"] = [
                    newConversationData
                ]
                
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(conversationID: conversationID, name: name, firstMessage: firstMessage, completion: completion)
                })
            }
        })
    }
    
    private func finishCreatingConversation(conversationID: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void){
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        
        switch firstMessage.kind{
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .custom(_):
            break
        }
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "name": name,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false]
        
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]]
        database.child("\(conversationID)").setValue(value, withCompletionBlock: {error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    ///Fetches and returns all conversations for the user with passed in email
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void){
        print("EMAIL: \(email)")
        database.child("\(email)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedtoFetch))
                return
            }
            
//            print("PRINTING: \(value)")
            
            print("So far so good")
            
            for message in value {
                print("\(message.keys)")
                //                print("\(message.lat)")
            }
            
            let conversations: [Conversation] = value.compactMap({dictionary in
                guard let conversationId = dictionary["id"] as? String,
                    let name = dictionary["name"] as? String,
                    let otherUserEmail = dictionary["other_user_email"] as? String,
                    let latestMessage = dictionary["latest_message"] as? [String: Any],
                    let date = latestMessage["date"] as? String,
                    let message = latestMessage["message"] as? String,
                    let isRead = latestMessage["is_read"] as? Bool else {
                        return nil
                }
                
                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                print("TEXT: \(latestMessageObject).text")
                return Conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObject)
            })
            completion(.success(conversations))
            print("PLEASE FOR THE LOVE OF GOD")
        })
    }
    
    ///Get all messages for a given conversation
    public func getAllMessagesforConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void){
        print("CONVERSATION ID: \(id)")
        database.child("\(id)/messages").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedtoFetch))
                return
            }
            
//            print("PRINTING: \(value)")
            
            print("So far so good")
            
            for message in value {
                print("\(message.keys)")
                //                print("\(message.lat)")
            }
            
            let messages: [Message] = value.compactMap({dictionary in
                guard let name = dictionary["name"] as? String,
                    let isRead = dictionary["is_read"] as? Bool,
                    let messageID = dictionary["id"] as? String,
                    let content = dictionary["content"] as? String,
                    let senderEmail = dictionary["sender_email"] as? String,
                    let type = dictionary["type"] as? String,
                    let dateString = dictionary["date"] as? String,
                    let date = ChatViewController.dateFormatter.date(from: dateString) else {
                        return nil
                }
                
                let sender = Sender(photoURL: "", senderId: senderEmail, displayName: name)
                
                return Message(sender: sender, messageId: messageID, sentDate: date, kind: .text(content))
            })
            completion(.success(messages))
            print("PLEASE FOR THE LOVE OF GOD")
        })
    }
    
    ///Sends a message with target conversation and message
    public func sendMessage(to conversation: String, otherUserEmail: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void){
        //add new message to messages
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }
            
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            let messageDate = newMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch newMessage.kind{
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .custom(_):
                break
            }
            
            guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(false)
                return
            }
            
            let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
            
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "name": name,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_email": currentUserEmail,
                "is_read": false]
            
            currentMessages.append(newMessageEntry)
            strongSelf.database.child("\(conversation)/messages").setValue(currentMessages, withCompletionBlock: { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                strongSelf.database.child("\(currentEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    guard var currentUserConversations = snapshot.value as? [[String: Any]] else {
                        completion(false)
                        return
                    }
                    
                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": message
                    ]
                    
                    var targetConversation: [String: Any]?
                    
                    var position = 0
                    
                    for conversationDictionary in currentUserConversations {
                        if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                            targetConversation = conversationDictionary
                            break
                        }
                        position += 1
                    }
                    targetConversation?["latest_message"] = updatedValue
                    
                    guard let finalConversation = targetConversation else {
                        completion(false)
                        return
                    }
                    
                    currentUserConversations[position] = finalConversation
                    strongSelf.database.child("\(currentEmail)/conversations").setValue(currentUserConversations, withCompletionBlock: { _, error in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        //Update latest message for recipient user
                        //GO BACK TO THE END OF LESSON 13 FOR THIS
                        
                        completion(true)
                    })
                })
            })
        })
        //update sender latest message
        //update recipient latest message
    }
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
    public func getAllBooks(with email: String, unreadOnly: Bool, length: String, completion: @escaping (Result<[Book], Error>) -> Void){
        print("USER ID: \(email)")
        database.child("\(email)/allBooks").observe(.value, with: { snapshot in
            guard var value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedtoFetch))
                return
            }
            
//            print("PRINTING: \(value)")
            
            print("So far so good")
            
            for book in value {
                print("\(book["read"]!)")
                //                print("\(message.lat)")
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
            print("PLEASE FOR THE LOVE OF GOD")
        })
    }
    
    ///Get all UNREAD books for a given user
    public func getUnreadBooks(with email: String, completion: @escaping (Result<[Book], Error>) -> Void){
        print("USER ID: \(email)")

        database.child("\(email)/allBooks").observe(.value, with: { snapshot in
            guard var value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedtoFetch))
                return
            }
            
            //RESOURCE: https://www.hackingwithswift.com/example-code/language/remove-all-instances-of-an-object-from-an-array
            value.removeAll { $0["read"] as! Int == 1 }
                        
            let books: [Book] = value.compactMap({dictionary in
                guard let id = dictionary["id"] as? String,
                    let title = dictionary["title"] as? String,
                    let imageUrl = dictionary["imageUrl"] as? String,
                    let author = dictionary["author"] as? String,
                    let descripton = dictionary["description"] as? String,
                    let isbn = dictionary["isbn"] as? String,
                    let read = dictionary["read"] as? Bool,
                    let dateRead = dictionary["dateRead"] as? String,
                    let pageCount = dictionary["pageCount"] as? Int,
                    let categories = dictionary["categories"] as? [String],
                    let fiction = dictionary["fiction"] as? String else {
                        return nil
                }
                
                return Book(id: id, title: title, imageUrl: imageUrl, author: author, description: descripton, isbn: isbn, read: read, dateRead: dateRead, pageCount: pageCount, categories: categories, fiction: fiction)
            })
        
            
            completion(.success(books))
//            print("PLEASE FOR THE LOVE OF GOD")
//            print("THESE ARE BOOKS: \(books)")
        })
    }
    
    
    ///Marks a book in the user's folder as read
    public func markRead(with readBook: Book, completion: @escaping (Bool) -> Void){
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
            self.database.child("\(currentEmail)/allBooks/\(i!)/read").setValue(true)
            
            
            let today = Date()
            let formatter1 = DateFormatter()
            formatter1.dateStyle = .short
//            print(formatter1.string(from: today))
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
//                print("SNAP: \(String(snapshot.value))")
                
                if snapshot.value as! Int == 1 {
                    print("We did it!")
                    
                    completion(true)
                }
                
            })
        })
    }
    
    ///Get books by length
    public func getBooksByLength(with email: String, length: String, completion: @escaping (Result<[Book], Error>) -> Void){
        print("USER ID: \(email)")
        
        
        
        database.child("\(email)/allBooks").observe(.value, with: { snapshot in
            guard var value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedtoFetch))
                return
            }
            
            //RESOURCE: https://www.hackingwithswift.com/example-code/language/remove-all-instances-of-an-object-from-an-array
            
            
            if length == "short" {
                value.removeAll { ($0["pageCount"] as! Int) > 300 }
            } else if length == "medium" {
                value.removeAll { 300 < ($0["pageCount"] as! Int) && ($0["pageCount"] as! Int)  < 600 }
            } else if length == "long" {
                value.removeAll { ($0["pageCount"] as! Int) < 900 }
            }
            
            let books: [Book] = value.compactMap({dictionary in
                guard let id = dictionary["id"] as? String,
                    let title = dictionary["title"] as? String,
                    let imageUrl = dictionary["imageUrl"] as? String,
                    let author = dictionary["author"] as? String,
                    let descripton = dictionary["description"] as? String,
                    let isbn = dictionary["isbn"] as? String,
                    let read = dictionary["read"] as? Bool,
                    let dateRead = dictionary["dateRead"] as? String,
                    let pageCount = dictionary["pageCount"] as? Int,
                    let categories = dictionary["categories"] as? [String],
                    let fiction = dictionary["ficion"] as? String else {
                        return nil
                }
                
                return Book(id: id, title: title, imageUrl: imageUrl, author: author, description: descripton, isbn: isbn, read: read, dateRead: dateRead, pageCount: pageCount, categories: categories, fiction: fiction)
            })
            
            completion(.success(books))
            //            print("PLEASE FOR THE LOVE OF GOD")
            //            print("THESE ARE BOOKS: \(books)")
        })
    }
}

//Handles data analytics
extension DatabaseManager {
    ///Get all books for a given user
    public func getBookCount(with email: String, completion: @escaping (Result<Int, Error>) -> Void){
//        print("USER ID: \(email)")
        database.child("\(email)/allBooks").observe(.value, with: { snapshot in
            guard var value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedtoFetch))
                return
            }
            
            value.removeAll { $0["read"] as! Int == 0 }
//            print("LIBRARY COUNT: \(value.count)")

            completion(.success(value.count))
//            print("PLEASE FOR THE LOVE OF GOD")
        })
    }
    
    public func getUnreadBookCount(with email: String, completion: @escaping (Result<Int, Error>) -> Void){
//        print("USER ID: \(email)")
        database.child("\(email)/allBooks").observe(.value, with: { snapshot in
            guard var value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedtoFetch))
                return
            }
            value.removeAll { $0["read"] as! Int == 1 }
//            print("LIBRARY COUNT: \(value.count)")

            completion(.success(value.count))
//            print("PLEASE FOR THE LOVE OF GOD")
        })
    }
    
    public func getGoalCount(with email: String, completion: @escaping (Result<Int, Error>) -> Void){
//        print("USER ID: \(email)")
        database.child("\(email)/goal2020").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? Int else {
                completion(.failure(DatabaseError.failedtoFetch))
                return
            }
            completion(.success(value))
//            print("PLEASE FOR THE LOVE OF GOD")
        })
    }
    
    public func getOnTrackStatus(with email: String, completion: @escaping (Result<Int, Error>) -> Void){
//        print("USER ID: \(email)")
        
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

//Handles lists
extension DatabaseManager {
    ///Adds a book to the user's "allBooks" folder
    public func addNewList(unreadOnly: Bool, pickLength: String, title: String, completion: @escaping (Bool) -> Void){
                    //add new message to messages
                    guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                        completion(false)
                        return
                    }
                    
                    let currentEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
                    print("CURRENT EMAIL: \(currentEmail)")
                    
                    database.child("\(currentEmail)/customLists").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                        guard let strongSelf = self else {
                            return
                        }
                        
                        var currentLists: [[String: Any]]
            //            var currentBooks = [[String: Any]]()
                        // HELP FROM HERE: https://stackoverflow.com/questions/35682683/checking-if-firebase-snapshot-is-equal-to-nil-in-swift
                        print("\(snapshot.value)")
                        if snapshot.value is NSNull {
                            print("NULL")
                            currentLists = [[String: Any]]()
                        } else {
                            currentLists = snapshot.value as! [[String : Any]]
                            print("Bad boys bad boys")
                        }
                        
            //            guard var currentBooks = snapshot.value as? [[String: Any]] else {
            //                print("Bad boys bad boys")
            //                return
            //            }
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
                        print("BOOK TO ADD: \(listToAdd)")
                        currentLists.append(listToAdd)
                        print("CURRENT BOOKS: \(currentLists)")
                        strongSelf.database.child("\(currentEmail)/customLists").setValue(currentLists, withCompletionBlock: { error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            //Update latest message for recipient user
                            //GO BACK TO THE END OF LESSON 13 FOR THIS
                            
                            completion(true)
                        })
                    })
                }
    ///Gets all user's custom lists
    public func getAllLists(with email: String, completion: @escaping (Result<[List], Error>) -> Void){
        print("USER ID: \(email)")
        database.child("\(email)/customLists").observe(.value, with: { snapshot in
            guard var value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedtoFetch))
                return
            }
            
//            print("PRINTING: \(value)")
            
            print("So far so good")
            
            
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

extension DatabaseManager {
///Adds books categories to user's category folder
    //It would make more sense to go back and write the Firebase folder as its own hash map, which would take up a lot less room
    public func addCategories(updatedCategories: [String], completion: @escaping (Bool) -> Void){
        //add new message to messages
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
            print("\(snapshot.value)")
            if snapshot.value is NSNull {
                print("NULL")
                currentCategories = [String]()
            } else {
                currentCategories = snapshot.value as! [String]
                print("Bad boys bad boys")
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
        print("USER ID: \(email)")
        
        database.child("\(email)/categories").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [String] else {
                completion(.failure(DatabaseError.failedtoFetch))
                return
            }
            
            completion(.success(value))
        })
    }
}
