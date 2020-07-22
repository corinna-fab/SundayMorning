//
//  SavedBookDetailsViewController.swift
//  Sunday Morning 2
//
//  Created by Corinna Fabre on 7/11/20.
//  Copyright © 2020 Corinna Fabre. All rights reserved.
//

import UIKit

class SavedBookDetailsViewController: UIViewController {
    var scrollView: UIScrollView!
    
    @IBOutlet weak var bookCover: UIImageView!
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookAuthor: UILabel!
    @IBOutlet weak var bookDescription: UILabel!
    @IBOutlet weak var readStatus: UILabel!
    @IBOutlet weak var markReadButton: UIButton!
    @IBOutlet weak var dateRead: UILabel!
    @IBOutlet weak var bookCategories: UILabel!
    
    var book:Book?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookTitle.text = book?.title
        bookAuthor.text = book?.author
        
        bookDescription.text = book?.description
        
        bookCategories.text = book?.categories.map { "\($0)" }.joined(separator:"\n")
        
        dateRead.isHidden = true
        
        markReadButton.layer.cornerRadius = 15
        
        readStatus.layer.masksToBounds = true
        
        displayMovieImage(bookCover: book!)
        checkBook(book: book!)
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
                self.bookCover?.image = image
            })
        }).resume()
    }
    
    func checkBook(book: Book){
        DatabaseManager.shared.checkBook(with: book, completion: { success in
            if success {
                print("Yay! You read this book already.")
                DispatchQueue.main.async {
                    self.dateRead.isHidden = false
                    self.readStatus.text = "Read!"
                    self.markReadButton.isHidden = true
                    self.dateRead.text = "Date Read: \(self.book?.dateRead as! String)"
                }
            } else {
                print("Failed to check status of book.")
            }
        })
        self.readStatus.text = "Unread"
    }
    
    @IBAction func markRead(_ sender: UIButton) {
        DatabaseManager.shared.markRead(with: book!, completion: { success in
            if success {
                print("Yay! You read this book.")
                
                DispatchQueue.main.async {
                    self.readStatus.text = "Read!"
                    self.markReadButton.isHidden = true
                    self.dateRead.isHidden = false
                    self.dateRead.text = ""
                }
            } else {
                print("Failed to mark book as read.")
            }
        })
    }
}

extension SavedBookDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("Something")
    }
    
}

extension SavedBookDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.book?.categories.count)! as Int
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = self.book?.categories[indexPath.row]
        cell.layer.cornerRadius = 10
        return cell
    }
}
