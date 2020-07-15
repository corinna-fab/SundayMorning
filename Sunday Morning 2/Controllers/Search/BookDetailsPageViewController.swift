//
//  BookDetailsPageViewController.swift
//  Sunday Morning 2
//
//  Created by Corinna Fabre on 7/7/20.
//  Copyright © 2020 Corinna Fabre. All rights reserved.
//

import UIKit
import WebKit
//import RealmSwift
import FirebaseAuth
import FirebaseDatabase

class BookDetailsPageViewController: UIViewController {
    var database = Database.database().reference()
    private var bookCollection = [Book]()
    
    var isNewBook = false
    
    @IBOutlet weak var fromReview: UILabel!
    
    var author: String = ""
    var bookTitle: String = ""
    var imageUrl: String = ""
    var id: String = ""
    var bookData: AnyObject = "" as! AnyObject
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var bookCoverImage: UIImageView!
    @IBOutlet weak var bookDescription: UILabel!
    @IBOutlet weak var pageCount: UILabel!
    
    var book:Book?
    
//    private let realm = try! Realm()
    public var completionHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            //Clear the fields
        titleLabel.text = ""
        authorLabel.text = ""
        bookDescription.text = ""
        //Check book
        guard book != nil else {
            return
        }
        //Set title
        titleLabel.text = book?.title
        authorLabel.text = book?.author
        
        if book?.pageCount != nil {
            pageCount.text = "\((book?.pageCount)!) p"
            
            
            
            if (book?.pageCount)! < 300 {
                pageCount.backgroundColor = #colorLiteral(red: 0.5667160749, green: 0.6758385897, blue: 0.56330055, alpha: 1)
            } else if (book?.pageCount)! < 600 {
                pageCount.backgroundColor = #colorLiteral(red: 0.9953779578, green: 0.9648614526, blue: 0.7624365687, alpha: 1)
            } else {
                pageCount.backgroundColor = #colorLiteral(red: 0.8597211838, green: 0.7501529455, blue: 0.6944079995, alpha: 1)
            }
            
        } else {
            pageCount.isHidden = true
        }
        
        if book?.description != "" {
            bookDescription.text = book?.description
        } else {
            bookDescription.text = "No description available."
        }
        
//        isbn.text = book?.isbn
        print("\(book?.read)")
        displayMovieImage(bookCover: book as! Book)
        fetchReview(isbn: book!.isbn)
    }

    func displayMovieImage(bookCover: Book) {
        let url: String = (URL(string: bookCover.imageUrl)?.absoluteString)!
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                let image = UIImage(data: data!)
                self.bookCoverImage?.image = image
            })
        }).resume()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
//    */

    func fetchReview(isbn: String) {
        let bookURL = "http://idreambooks.com/api/books/reviews.json?key=\(K.DREAM_API)"
        let urlString = "\(bookURL)&isbn=\(isbn)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error)
                    return
                }
                if let safeData = data {
print("This is data: \(data!)")
//                    if let movieReviewInfo = self.parse(data: safeData) {
//                        print("We did it.")
//                    }
//                    guard let mime = response?.mimeType, mime == "application/json" else {
//                        print("Wrong MIME type!")
//                        return
//                    }
//
//                    do {
//                        let json = try JSONSerialization.jsonObject(with: data!, options: [])
////                        self.bookData = json
//                        print(json)
//                    } catch {
//                        print("JSON error: \(error.localizedDescription)")
//                    }
                    let object = JSONParser.parse(data: data!)
                    //            print("Object: \(object!["totalItems"])")
                                
                                if let object = object {
                                    print("This is an object")
                                    print(object.keys)
//                                    print("Object: \(object["total_results"])")
//                                    print("Object: \(object["book"])")
                                    BookDataProcessor.mapJsonToReview(object: object)
                                }
                }
            }
            task.resume()
        }
    }

//        func parse (data: Data) -> [String: AnyObject]? {
//    //        let options = JSONSerialization.ReadingOptions()
//            do {
//                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//                    print("JSON successfully parsed.")
//    //            print(json!["totalItems"])
//    //            print(json!["items"])
//                print(json!["book"])
//                return json! as [String : AnyObject]
//
//            } catch (let parseError){
//                print("There was an error parsing the JSON: \"\(parseError.localizedDescription)\"")
//            }
//            return nil
//        }
//        
//        func parseDataIntoMovies(data: Data?) -> Void {
//            if let data = data {
//                print("Yup, this is data")
//                let object = JSONParser.parse(data: data)
//    //            print("Object: \(object!["totalItems"])")
//
//                if let object = object {
//                    print("This is an object")
//    //                print(object["items"])
//                    self.searchResults = BookDataProcessor.mapJsonToMovies(object: object)
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                        self.totalResults.text = "\(object["totalItems"] ?? "Zero" as AnyObject) total results)"
//                    }
//                }
//            }
//        }

    @IBAction func didTapAddToCollection() {
        print("ADD!")
        
        if isNewBook {
            //create convo in database
            print("I'm creating")
            DatabaseManager.shared.addNewBook(with: book!, completion: { success in
            if success {
                    print("Message sent")
                    self.isNewBook = false
                } else {
                    print("Failed to send")
                }
            })
        } else {
            
            //append to existing data
            print("I'm DUMB")
            DatabaseManager.shared.addNewBook(with: book!, completion: { success in
                if success {
                    print("Message sent. WOO")
                } else {
                    print("Failed to send")
                    
                }
            })
            
        }
        
//        let bookToAdd: [String: String] = [
//            "id": book?.id as! String,
//            "author": book?.author as! String,
//            "title": book?.title as! String,
//            "description": book?.description as! String,
//            "isbn": book?.isbn as! String,
//            "imageUrl": book?.imageUrl as! String
//        ]
//
//        let user = UserDefaults.standard.value(forKey: "email")
//////        print("\(user)")
//        let safeUser = DatabaseManager.safeEmail(emailAddress: user as! String)
//        database.child("\(safeUser)/allBooks/").append(bookToAdd)

        
        ///print("\(safeUser)")
////        print("\(self.ref.child("users"))")
//        guard let book = book else {
//            return
//        }
//        print("\(book.title)")
//        print("\(database.child("\(safeUser)/toBeRead"))")
        

//
//
//
//            if isNewConversation {
//                //create convo in database
//
//                DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: message, completion: { [weak self] success in
//                    if success {
//                        print("Message sent")
//                        self?.isNewConversation = false
//                    } else {
//                        print("Failed to send")
//                    }
//                })
//            } else {
//                guard let conversationId = conversationId, let name = self.title else {
//                    return
//                }
//                //append to existing data
//                DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: name, newMessage: message, completion: { success in
//                    if success {
//                        print("Message sent. WOO")
//                    } else {
//                        print("Failed to send")
//                    }
//                })
//            }
        }
        
//        print(book?.title as Any)
//
//        realm.beginWrite()
//        let newItem = BookItem()
//        newItem.author = book?.author as! String
//        newItem.title = book?.title as! String
//        newItem.bookDescription = book?.description as! String
//        newItem.id = book?.id as! String
//        newItem.imageUrl = book?.imageUrl as! String
////        newItem.email = FirebaseAuth.Auth.auth().currentUser?.email as! String
//        newItem.dateAdded = Date()
//
//        realm.add(newItem)
//
//        try! realm.commitWrite()
//
//        completionHandler?()
        
        //Post the data to firebase
        
        
//        navigationController?.popToRootViewController(animated: true)
//        }
}

//class BookList: Object {
//    dynamic var book: Book = Book(id: "", title: "", imageUrl: "", author: "", description: "", isbn: "")
//    @objc dynamic var date: Date = Date()
//    dynamic var email: String = (FirebaseAuth.Auth.auth().currentUser?.email!)
//}

//Mark: - Check if book is already in collection
extension BookDetailsPageViewController {
    //Custom alert (iOS Academy video)
    private func checkList() {
        
    }
}
