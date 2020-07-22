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
import SCLAlertView

//SCROLLVIEW RESOURCE: https://www.youtube.com/watch?v=Rvlto4x2bzQ

class BookDetailsPageViewController: UIViewController {
    var database = Database.database().reference()
    private var bookCollection = [Book]()
    
    var isNewBook = false
    
    @IBOutlet weak var fromReview: UILabel!
    
    var author: String = ""
    var bookTitle: String = ""
    var imageUrl: String = ""
    var id: String = ""
//    var bookData: AnyObject = "" as! AnyObject
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var bookCoverImage: UIImageView!
    @IBOutlet weak var bookDescription: UILabel!
    @IBOutlet weak var pageCount: UILabel!
    
    var book:Book?

//    public var completionHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        titleLabel.text = ""
        authorLabel.text = ""
        bookDescription.text = ""
        //Check book
        guard book != nil else {
            return
        }
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

        displayBookCover(bookCover: book as! Book)
    }

    func displayBookCover(bookCover: Book) {
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

    @IBAction func didTapAddToCollection() {
        
        if isNewBook {
            DatabaseManager.shared.addNewBook(with: book!, completion: { success in
            if success {
                print("Message sent")
                self.isNewBook = false
                let appearance = SCLAlertView.SCLAppearance(
                    kTitleFont: UIFont(name: "Farah", size: 20)!,
                    kTextFont: UIFont(name: "Farah", size: 14)!,
                    kButtonFont: UIFont(name: "Farah", size: 14)!,
                    showCloseButton: false,
                    showCircularIcon: false,
                    contentViewColor: #colorLiteral(red: 0.5667160749, green: 0.6758385897, blue: 0.56330055, alpha: 1),
                    contentViewBorderColor: #colorLiteral(red: 0.247261852, green: 0.2675772011, blue: 0.2539684772, alpha: 1)
                )
                
                let timer = SCLAlertView.SCLTimeoutConfiguration.init(timeoutValue: 2.0, timeoutAction: {})
                
                SCLAlertView(appearance: appearance).showTitle(
                    "Success!", // Title of view
                    subTitle: "Book has been added.", // String of view
                    timeout: timer, // Duration to show before closing automatically, default: 0.0
                    completeText: "Done", // Optional button value, default: ""
                    style: .success, // Styles - see below.
                    colorStyle: 1,
                    colorTextButton: 1
                )
            } else {
                    print("Failed to send")
                }
            })
        } else {
            
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: UIFont(name: "Farah", size: 20)!,
                kTextFont: UIFont(name: "Farah", size: 14)!,
                kButtonFont: UIFont(name: "Farah", size: 14)!,
                showCloseButton: false,
                showCircularIcon: false,
                shouldAutoDismiss: false,
                contentViewColor: #colorLiteral(red: 0.5667160749, green: 0.6758385897, blue: 0.56330055, alpha: 1),
                contentViewBorderColor: #colorLiteral(red: 0.247261852, green: 0.2675772011, blue: 0.2539684772, alpha: 1)
            )
            
            book?.fiction = "Fiction"
            
            let alertView = SCLAlertView(appearance: appearance)
            let txt = alertView.addTextField("Category")
            
            let subview = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width - 20, height: 100))
            let x = (subview.frame.width - 180) / 2
            
            let categoryLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 216, height: 100))
            categoryLabel.contentMode = .scaleToFill
            categoryLabel.font.withSize(15)
            categoryLabel.numberOfLines = 0
            categoryLabel.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            categoryLabel.lineBreakMode = .byWordWrapping
            categoryLabel.text = self.book?.categories.joined(separator:", ")
            subview.addSubview(categoryLabel)
            
            alertView.customSubview = subview
            
            alertView.addButton("Add Category", backgroundColor: #colorLiteral(red: 0.367708087, green: 0.4341275096, blue: 0.3933157027, alpha: 1), action: {
                self.book?.categories.append(txt.text! as String)
                print(self.book?.categories)
                categoryLabel.text = self.book?.categories.joined(separator:", ")
//                subview.addSubview(categoryLabel)
                alertView.customSubview = subview
                
            })
            
            
            alertView.addButton("Update genre", backgroundColor: #colorLiteral(red: 0.367708087, green: 0.4341275096, blue: 0.3933157027, alpha: 1), action: {
                let alertViewPopUp = SCLAlertView(appearance: appearance)
                alertViewPopUp.addButton("Nonfiction", backgroundColor: #colorLiteral(red: 0.367708087, green: 0.4341275096, blue: 0.3933157027, alpha: 1), action: {
                    self.book?.fiction = "Nonfiction"
                    alertViewPopUp.hideView()
                })
                alertViewPopUp.addButton("Fiction", backgroundColor: #colorLiteral(red: 0.367708087, green: 0.4341275096, blue: 0.3933157027, alpha: 1), action: {
                    self.book?.fiction = "Fiction"
                    alertViewPopUp.hideView()
                })
                alertViewPopUp.showSuccess("Select Genre", subTitle: "Please select the appropriate genre")
            })
            
            alertView.addButton("Done", backgroundColor: #colorLiteral(red: 0.367708087, green: 0.4341275096, blue: 0.3933157027, alpha: 1)){
                DatabaseManager.shared.addNewBook(with: self.book!, completion: { success in
                if success {
                    print("Message sent. WOO. Here's the book: \(self.book?.fiction)")
                    let appearance = SCLAlertView.SCLAppearance(
                        kTitleFont: UIFont(name: "Farah", size: 20)!,
                        kTextFont: UIFont(name: "Farah", size: 14)!,
                        kButtonFont: UIFont(name: "Farah", size: 14)!,
                        showCloseButton: false,
                        showCircularIcon: false,
                        contentViewColor: #colorLiteral(red: 0.5667160749, green: 0.6758385897, blue: 0.56330055, alpha: 1),
                        contentViewBorderColor: #colorLiteral(red: 0.247261852, green: 0.2675772011, blue: 0.2539684772, alpha: 1)
                    )
                    
                    let timer = SCLAlertView.SCLTimeoutConfiguration.init(timeoutValue: 2.0, timeoutAction: {})
                    
                    SCLAlertView(appearance: appearance).showTitle(
                        "Success!", // Title of view
                        subTitle: "Book has been added.", // String of view
                        timeout: timer, // Duration to show before closing automatically, default: 0.0
                        completeText: "Done", // Optional button value, default: ""
                        style: .success, // Styles - see below.
                        colorStyle: 1,
                        colorTextButton: 1
                    )
                    
                    alertView.hideView()
                } else {
                    print("Failed to send")
                    
                }
            })}
            
            alertView.addButton("Cancel", backgroundColor: #colorLiteral(red: 0.367708087, green: 0.4341275096, blue: 0.3933157027, alpha: 1)){
                alertView.hideView()
            }
            
            alertView.showEdit("Add Categories", subTitle: "What   categories    would    you    like    to    add?")
        }
    }
}
