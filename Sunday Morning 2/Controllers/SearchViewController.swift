//
//  SearchViewController.swift
//  Sunday Morning
//
//  Created by Corinna Fabre on 7/1/20.
//  Copyright © 2020 Corinna Fabre. All rights reserved.
//

//import UIKit
//
//class SearchViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, BookDelegate {
//
//    @IBOutlet weak var searchTextField: UITextField!
////    @IBOutlet weak var bookTitle: UILabel!
////    @IBOutlet weak var bookAuthor: UILabel!
////    @IBOutlet weak var totalResults: UILabel!
//    @IBOutlet weak var tableView: UITableView!
//
//    var searchResults: [Book] = []
//
//    @IBAction func search (sender: UIButton) {
//        let searchTerm = searchTextField.text!
//
//        retrieveBooksByTitle(searchTerm: searchTerm)
//
//    }
//
//    func retrieveBooksByTitle(searchTerm: String){
//        let bookURL = "https://www.googleapis.com/books/v1/volumes?&key=AIzaSyAgTZF2g0DfyJC5mCBg9v_tD2cp3oyXx5w"
//        let urlString = "\(bookURL)&q=\(searchTerm)"
//        HTTPHandler.getJSON(urlString: urlString, completionHandler: parseDataToBooks)
//    }
//
//    func parseDataToBooks(data: Data?) -> Void {
//        if let data = data {
//            print("This is DATA: \(data)")
//            let object = JSONParser.parse(data: data)
//
//            if let object = object {
//                print("This is OBJECT: \(object)")
//                self.searchResults = BookDataProcessor.mapJsontoBooks(object: object, booksKey: "Search")
//
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//            }
//        }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        searchTextField.delegate = self
//        //Set itself as the datasource and the delegate
//        tableView.dataSource = self
//        tableView.delegate = self
//    }
//
//    //Mark: - Model Delegate Methods
//    @IBAction func searchPressed(_ sender: UIButton) {
//        searchTextField.endEditing(true)
//        let searchTerm = searchTextField.text!
//
//        retrieveBooksByTitle(searchTerm: searchTerm)
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        searchTextField.endEditing(true)
//        let searchTerm = searchTextField.text!
//
//        retrieveBooksByTitle(searchTerm: searchTerm)
//        return true
//    }
//
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        if textField.text != "" {
//            return true
//        } else {
//            textField.placeholder = "Type something here"
//            return false
//        }
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        var searchTerm = searchTextField.text!
//
//        retrieveBooksByTitle(searchTerm: searchTerm)
//    }
//
//    @IBAction func backPressed(_ sender: UIButton) {
//        self.dismiss(animated: true, completion: nil)
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return searchResults.count
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let bookCell = tableView.dequeueReusableCell(withIdentifier: "bookSearchCell", for: indexPath) as! CustomBookListTableViewCell
//
//        let idx: Int  = indexPath.row
//        bookCell.AddBooktoList.tag = idx
//        bookCell.bookTitle.text = searchResults[idx].title
//        bookCell.bookAuthor.text = searchResults[idx].author
//
//        displayBookImage(idx, bookCell: bookCell)
//        return bookCell
//    }
//
//    func displayBookImage(_ row: Int, bookCell: CustomBookListTableViewCell){
//        let url: String = (URL(string: searchResults[row].imageURL)?.absoluteString)!
//        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) -> Void in
//            if error != nil {
//                print(error!)
//                return
//            }
//
//            DispatchQueue.main.async(execute: {
//                let image = UIImage(data: data!)
//                bookCell.bookImageView?.image = image
//            })
//            }).resume()
//    }
//}
////MARK: -
//
//extension SearchViewController {
//    func didUpdateSearch(_ bookManager: BookManager ,book: BookModel){
//        DispatchQueue.main.async {
//            self.bookTitle.text = book.title
//            self.bookAuthor.text = book.author
//        }
//    }
//
//    func didFailWithError(error: Error) {
//        print(error)
//    }
//}

import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: AllSavedBooksViewController!
    var searchResults: [Book] = []
    
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var totalResults: UILabel!
    
    @IBAction func search(sender: UIButton) {
        print("Searching for \(self.searchTextField.text!)")
        
        var searchTerm = searchTextField.text!
        if searchTerm.count > 2 {
            retrieveMoviesByTerm(searchTerm: searchTerm)
        }
    }
    
    @IBAction func addFav (sender: UIButton) {
        print("Item #\(sender.tag) was selected as a favorite")
//        self.delegate.favoriteMovies.append(searchResults[sender.tag])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Search Results"
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // grouped vertical sections of the tableview
        return 1
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 0.1
//    }
//
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // at init/appear ... this runs for each visible cell that needs to render
        let moviecell = tableView.dequeueReusableCell(withIdentifier: "bookSearchCell", for: indexPath) as! CustomBookListTableViewCell
        
        let idx: Int = indexPath.row
//        moviecell.favButton.tag = idx
        
        //title
        moviecell.bookTitle?.text = searchResults[idx].title
        //year
//        moviecell.bookAuthor?.text = searchResults[idx].year
        // image
        displayMovieImage(idx, moviecell: moviecell)
        
        return moviecell
    }
    
    func displayMovieImage(_ row: Int, moviecell: CustomBookListTableViewCell) {
        let url: String = (URL(string: searchResults[row].imageUrl)?.absoluteString)!
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                let image = UIImage(data: data!)
                moviecell.bookImageView?.image = image
            })
        }).resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func retrieveMoviesByTerm(searchTerm: String) {
//        let url = "https://www.omdbapi.com/?apikey=PlzBanMe&s=\(searchTerm)&type=movie&r=json"
        let bookURL = "https://www.googleapis.com/books/v1/volumes?&key=AIzaSyAgTZF2g0DfyJC5mCBg9v_tD2cp3oyXx5w"
        let url = "\(bookURL)&q=\(searchTerm)"
        HTTPHandler.getJSON(urlString: url, completionHandler: parseDataIntoMovies)
    }
    
    func parseDataIntoMovies(data: Data?) -> Void {
        if let data = data {
            print("Yup, this is data")
            let object = JSONParser.parse(data: data)
//            print("Object: \(object!["totalItems"])")
            
            if let object = object {
                print("This is an object")
                print(object["items"])
                self.searchResults = BookDataProcessor.mapJsonToMovies(object: object)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.totalResults.text = "\(object["totalItems"] ?? "Zero" as AnyObject) total results)"
                }
            }
        }
    }
}
