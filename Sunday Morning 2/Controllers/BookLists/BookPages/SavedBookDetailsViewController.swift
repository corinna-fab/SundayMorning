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
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var bookCover: UIImageView!
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookAuthor: UILabel!
    @IBOutlet weak var bookDescription: UILabel!
    @IBOutlet weak var readStatus: UILabel!
    @IBOutlet weak var markReadButton: UIButton!
    @IBOutlet weak var dateRead: UILabel!
    
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
        
        dateRead.isHidden = true
        
        markReadButton.layer.cornerRadius = 15
        
        readStatus.layer.masksToBounds = true
        
        displayMovieImage(bookCover: book as! Book)
        checkBook(book: book as! Book)
        
        
        collectionView.register(CategoryCollectionViewCell.nib(), forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
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
                print("Failed to mark book as read.")
//
//                self.dateRead.isHidden = true
//                self.readStatus.text = "Unread"
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

extension SavedBookDetailsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        print("Something")
    }
}

extension SavedBookDetailsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.book?.categories.count)! as Int
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
        cell.categoryLabel.text = self.book?.categories[indexPath.row]
        cell.layer.cornerRadius = 10
        return cell
    }
}

extension SavedBookDetailsViewController: UICollectionViewDelegateFlowLayout {
    
}
