//
//  BookDetailsPageViewController.swift
//  Sunday Morning 2
//
//  Created by Corinna Fabre on 7/7/20.
//  Copyright © 2020 Corinna Fabre. All rights reserved.
//

import UIKit
import WebKit
import RealmSwift
import FirebaseAuth

class BookDetailsPageViewController: UIViewController {
    
    var author: String = ""
    var bookTitle: String = ""
    var imageUrl: String = ""
    var id: String = ""
    var bookData: AnyObject = "" as! AnyObject
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var bookCoverImage: UIImageView!
    @IBOutlet weak var bookDescription: UILabel!
    @IBOutlet weak var isbn: UILabel!
    @IBOutlet weak var review: UILabel!
    
    var book:Book?
    
    private let realm = try! Realm()
    public var completionHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        bookCoverImage.image = #imageLiteral(resourceName: "book_cover")
//        bookCoverImage.layer.borderColor = #colorLiteral(red: 0.9973656535, green: 0.9274361134, blue: 0.6675162315, alpha: 1)
//        bookCoverImage.layer.borderWidth = 10
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
            //Clear the fields
        titleLabel.text = ""
        authorLabel.text = ""
        bookDescription.text = ""
        isbn.text = ""
        //Check book
        guard book != nil else {
            return
        }
        //Set title
        titleLabel.text = book?.title
        authorLabel.text = book?.author
//        bookDescription.text = "No description"
//        print(book?.description)
        
        if book?.description != "" {
            bookDescription.text = book?.description
        } else {
            bookDescription.text = "No description available."
        }
        
        isbn.text = book?.isbn
        fetchReview(isbn: book!.isbn)
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
        let bookURL = "http://idreambooks.com/api/books/reviews.json?key=60a5d80efa3e745eb4191bd16dcaac6cf5cacdd8"
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
//                    print("This is data: \(data!)")
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
//                                    print("This is an object")
                    //                print(object["items"])
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
        print(book?.title as Any)
        
        realm.beginWrite()
        let newItem = BookItem()
        newItem.author = book?.author as! String
        newItem.title = book?.title as! String
        newItem.bookDescription = book?.description as! String
        newItem.id = book?.id as! String
        newItem.imageUrl = book?.imageUrl as! String
        newItem.email = FirebaseAuth.Auth.auth().currentUser?.email as! String
        newItem.dateAdded = Date()
        
        realm.add(newItem)
        
        try! realm.commitWrite()
        
        completionHandler?()
        navigationController?.popToRootViewController(animated: true)
        }
}

//class BookList: Object {
//    dynamic var book: Book = Book(id: "", title: "", imageUrl: "", author: "", description: "", isbn: "")
//    @objc dynamic var date: Date = Date()
//    dynamic var email: String = (FirebaseAuth.Auth.auth().currentUser?.email!)
//}
