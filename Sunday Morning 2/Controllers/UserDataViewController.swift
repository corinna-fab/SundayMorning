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
import DBSphereTagCloudSwift
import MBCircularProgressBar

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
    var goalCount: Int = 1
    
    @IBOutlet weak var progressResults: UILabel!
    
    @IBOutlet weak var averagePerMonth: UILabel!
//    var margin: Int = 0
    
    var categoryArray = [String]()
    var categoryCount = [String: Int]()
    var categoryTotal: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //GUAGE: https://www.youtube.com/watch?v=aylHkGVg-P4
        self.readingProgress.value = 0
        self.readingProgress.layer.cornerRadius = 20
        
        startListeningForBooks()
    }
    
    @IBAction func suggestionButtonPressed(_ sender: Any) {
        print("Too bad.")
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
                
//                print("Catergory count: \(sortedArray)")
//                self?.unreadCount = count
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
    
    private func checkForOnTrack(){

    }
}
