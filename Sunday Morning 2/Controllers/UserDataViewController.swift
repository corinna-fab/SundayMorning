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
//import DBSphereTagCloudSwift
import MBCircularProgressBar
import SCLAlertView

class UserDataViewController: UIViewController {
    
    @IBOutlet weak var totalRead: UILabel!
    @IBOutlet weak var totalUnread: UILabel!
    var readCount: Int = 0
    var unreadCount: Int = 0
    
    @IBOutlet weak var category_one: UILabel!
    @IBOutlet weak var category_two: UILabel!
    @IBOutlet weak var category_three: UILabel!
    @IBOutlet weak var category_four: UILabel!
    @IBOutlet weak var category_five: UILabel!
    
    @IBOutlet weak var readingProgress: MBCircularProgressBarView!
    @IBOutlet weak var readingProgressCount: UILabel!
    var goalCount: Int = 1
    
    @IBOutlet weak var progressResults: UILabel!
    
    @IBOutlet weak var averagePerMonth: UILabel!
//    var margin: Int = 0
    
    var categoryArray = [String]()
    var categoryCount = [String: Int]()
    var categoryTotal: Int = 0
    var suggestedBooks: [Book] = []
    var suggestedBook: Book?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //GUAGE: https://www.youtube.com/watch?v=aylHkGVg-P4
        self.readingProgress.value = 0
        self.readingProgress.layer.cornerRadius = 20
        
        startListeningForBooks()
    }
    
    @IBAction func suggestionButtonPressed(_ sender: Any) {
        print("Too bad.")
        
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
        
        //        let timer = SCLAlertView.SCLTimeoutConfiguration.init(timeoutValue: 2.0, timeoutAction: {})
        let alertView = SCLAlertView(appearance: appearance)
        
        let subview = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width - 20, height: 200))
        let x = (subview.frame.width - 180) / 2
        
        let bookCover = UIImageView(frame: CGRect(x: 0, y: 0, width: 216, height: 200))
        bookCover.contentMode = .scaleAspectFit
        
        self.suggestedBook = self.suggestedBooks.randomElement()
        let url: String = (URL(string: self.suggestedBook?.imageUrl ?? "")?.absoluteString)!
        
        if url == "" {
            bookCover.image = #imageLiteral(resourceName: "Coming soon!")
        } else {
            URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) -> Void in
                if error != nil {
                    print(error!)
                    return
                }
                
                DispatchQueue.main.async(execute: {
                    let image = UIImage(data: data!)
                    bookCover.image = image
                })
            }).resume()
        }

        subview.addSubview(bookCover)
        
        alertView.customSubview = subview
        
        alertView.addButton("Generate   Another   Suggestion", backgroundColor: #colorLiteral(red: 0.367708087, green: 0.4341275096, blue: 0.3933157027, alpha: 1), action: {
            self.suggestedBook = self.suggestedBooks.randomElement()
            let url: String = (URL(string: self.suggestedBook?.imageUrl ?? "")?.absoluteString)!
            
            if url == "" {
                bookCover.image = #imageLiteral(resourceName: "Coming soon!")
            } else {
                URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) -> Void in
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    DispatchQueue.main.async(execute: {
                        let image = UIImage(data: data!)
                        bookCover.image = image
                    })
                }).resume()
            }
            
            subview.addSubview(bookCover)
        })
        
        alertView.addButton("Select   Book", backgroundColor: #colorLiteral(red: 0.367708087, green: 0.4341275096, blue: 0.3933157027, alpha: 1), action: {
            guard let vc = self.storyboard?.instantiateViewController(identifier: "savedBook") as? SavedBookDetailsViewController else {
                return
            }
            vc.book = self.suggestedBook
            alertView.hideView()
            self.navigationController?.pushViewController(vc, animated: true)
            print("You hit me")
    
        })
        
        alertView.addButton("Cancel", backgroundColor: #colorLiteral(red: 0.367708087, green: 0.4341275096, blue: 0.3933157027, alpha: 1)){
            alertView.hideView()
        }
        
        alertView.showEdit("", subTitle: "")
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        print("Total READ: \(readCount)")
        print("Total UNREAD: \(unreadCount)")
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        print("Starting to fetch books")

        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        DatabaseManager.shared.getGoalCount(with: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let goal):
                UIView.animate(withDuration: 1.0, animations: {
                    self?.readingProgress.value = CGFloat((self!.readCount * 100) / goal)
                    print("Goal: \(goal)")
                })
                
                self?.goalCount = goal
                
                let date = Date() // get a current date instance
                let dateFormatter = DateFormatter() // get a date formatter instance
                let calendar = dateFormatter.calendar // get a calendar instance
                let month = calendar?.component(.month, from: date) // Result: 4
                
                let perMonth = self!.goalCount / 12
//                print("Per Month: \(perMonth)")
                let shouldBeAt = perMonth * month!
//                print("Should Be At: \(shouldBeAt)")
                let difference = self!.readCount - shouldBeAt
//                print("Difference: \(difference)")
                
                if difference < 0 {
                    self?.progressResults.text = "You are \(abs(difference)) books behind"
                    print("You are \(abs(difference)) books behind")
                } else if difference == 0 {
                    self?.progressResults.text = "You are exactly on track"
                    print("You are exactly on track")
                } else if difference > 0 {
                    self?.progressResults.text = "You are \(abs(difference)) books ahead"
                    print("You are \(difference) books ahead")
                }
                
                let averagingPerMonth = (self!.readCount / month!)
                print("Averaging per month: \(averagingPerMonth)")
                self?.averagePerMonth.text = "\(averagingPerMonth)"
                
                self?.readingProgressCount.text = "\(self!.readCount) / \(goal) books"
                
            case .failure(let error):
                print("failed to get book count: \(error)")
            }
        })
    }
    
    private func startListeningForBooks() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        print("Starting to fetch books")

        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        DatabaseManager.shared.getAllBooks(with: safeEmail, unreadOnly: false, length: "", genre: "", category: "", completion: { [weak self] result in
            switch result {
            case .success(let conversations):
                print("successfully got book models")
                print("\(conversations)")
                guard !conversations.isEmpty else {
                    print("nothing to see here")
                    return
                }
                print("LIBRARY COUNT: \(conversations.count)")
                self?.suggestedBooks = conversations
                
            case .failure(let error):
                print("failed to get the books for the reader insights page: \(error)")
            }
        })
        
        DatabaseManager.shared.getBookCount(with: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let count):
//                print("LIBRARY COUNT: \(count)")
                self?.readCount = count
                
                DispatchQueue.main.async {
                    self?.totalRead.text = "\(String(count))"
                }
            case .failure(let error):
                print("failed to get book count: \(error)")
            }
        })
        
        DatabaseManager.shared.getUnreadBookCount(with: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let count):
//                print("LIBRARY COUNT: \(count)")
                self?.unreadCount = count
                
                DispatchQueue.main.async {
                    self?.totalUnread.text = " \(String(count))"
                }
            case .failure(let error):
                print("failed to get unread book count: \(error)")
            }
        })
        
        DatabaseManager.shared.getGoalCount(with: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let goal):
                self?.goalCount = goal
                
            case .failure(let error):
                print("failed to get book count: \(error)")
            }
        })
        
        DatabaseManager.shared.getCategories(with: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let categories):
//                print("These are the categories: \(categories)")
                
                for category in categories {
                    if category == "Fiction" || category == "Nonfiction" {
                        continue
                    }
                    
                    if self?.categoryCount[category] != nil {
                        self?.categoryCount[category]! += 1
                        self?.categoryTotal += 1
                    } else {
                        self?.categoryCount[category] = 1
                        self?.categoryTotal += 1
                    }
                }
                
                self?.categoryArray = categories
                
                var sortedArray = self?.categoryCount.sorted { $0.1 > $1.1 }

                DispatchQueue.main.async {
                    self?.category_one.text = "\(sortedArray![0].key) (\(sortedArray![0].value) books)"
                    self?.category_two.text = "\(sortedArray![1].key) (\(sortedArray![1].value) books)"
                    self?.category_three.text = "\(sortedArray![2].key) (\(sortedArray![2].value) books)"
                    self?.category_four.text = "\(sortedArray![3].key) (\(sortedArray![3].value) books)"
                    self?.category_five.text = "\(sortedArray![4].key) (\(sortedArray![4].value) books)"
                }
            case .failure(let error):
                print("failed to get unread book count: \(error)")
            }
        })
    }
}
