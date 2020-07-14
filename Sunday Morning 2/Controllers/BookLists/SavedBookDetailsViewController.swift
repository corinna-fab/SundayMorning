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
    
    var book:Book?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookTitle.text = book?.title
        bookAuthor.text = book?.author
        
        bookDescription.text = book?.description
        // Do any additional setup after loading the view.
        //FIX LOGIC HERE ABOUT WHAT THIS SHOWS
        
//        if isRead == false {
//            readStatus.text = "To Be Read"
//            print("This book has doubly been: \(isRead)")
//        } else {
//            readStatus.text = "Read!"
//            markReadButton.isHidden = true
//            print("Please just work already")
//        }
        
        markReadButton.layer.cornerRadius = 15
        
        readStatus.layer.masksToBounds = true
        
        displayMovieImage(bookCover: book as! Book)
        checkBook(book: book as! Book)
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
                    self.readStatus.text = "Read!"
                    self.markReadButton.isHidden = true
                    self.readStatus.text = "Read"
                }
            } else {
                print("Failed to mark book as read.")
                self.readStatus.text = "Unread"
            }
        })
        self.readStatus.text = "Unread"
    }
    
    @IBAction func markRead(_ sender: UIButton) {
        DatabaseManager.shared.markRead(with: book!, completion: { success in
        if success {
                print("Yay! You read this book.")
            } else {
                print("Failed to mark book as read.")
            }
        })
        
        DispatchQueue.main.async {
            self.readStatus.text = "Read!"
            self.markReadButton.isHidden = true
        }
    }
}
