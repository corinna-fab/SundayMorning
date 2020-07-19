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

class UserDataViewController: UIViewController {
    
    @IBOutlet weak var totalRead: UILabel!
    @IBOutlet weak var totalUnread: UILabel!
    
    @IBOutlet weak var category_one: UILabel!
    @IBOutlet weak var category_two: UILabel!
    @IBOutlet weak var category_three: UILabel!
    @IBOutlet weak var category_four: UILabel!
    @IBOutlet weak var category_five: UILabel!

    var readCount: Int = 0
    var unreadCount: Int = 0
    
    var categoryArray = [String]()
    var categoryCount = [String: Int]()
    var categoryTotal: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startListeningForBooks()
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
                print("LIBRARY COUNT: \(count)")
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
                print("LIBRARY COUNT: \(count)")
                self?.unreadCount = count
                
                DispatchQueue.main.async {
                    self?.totalUnread.text = " \(String(count))"
                }
            case .failure(let error):
                print("failed to get unread book count: \(error)")
            }
        })
        
        DatabaseManager.shared.getCategories(with: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let categories):
                print("These are the categories: \(categories)")
                
                for category in categories {
                    if self?.categoryCount[category] != nil {
                        self?.categoryCount[category]! += 1
                        self?.categoryTotal += 1
                    } else {
                        self?.categoryCount[category] = 1
                        self?.categoryTotal += 1
                    }
                }
                
                self?.categoryArray = categories
                
                let sortedArray = self?.categoryCount.sorted { $0.1 < $1.1 }
//                let topFive = Array(arrayLiteral: self?.categoryCount.keys)
                
                print("Category count: \(sortedArray)")
//                self?.unreadCount = count
                DispatchQueue.main.async {
                    self?.category_one.text = sortedArray?[0].key
                    self?.category_two.text = sortedArray?[1].key
                    self?.category_three.text = sortedArray?[2].key
                    self?.category_four.text = sortedArray?[3].key
                    self?.category_five.text = sortedArray?[4].key
                }
            case .failure(let error):
                print("failed to get unread book count: \(error)")
            }
        })
        
    }
}
