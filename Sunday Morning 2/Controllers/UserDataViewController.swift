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

class UserDataViewController: UIViewController {
    
    @IBOutlet weak var totalLibraryCount: UILabel!
    @IBOutlet weak var totalTBRCount: UILabel!
    
    var count: Int = 0
    
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
                self?.count = count
                
                DispatchQueue.main.async {
                    self?.totalLibraryCount.text = String(count)
                }
            case .failure(let error):
                print("failed to get book count: \(error)")
            }
        })
        
        DatabaseManager.shared.getUnreadBookCount(with: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let count):
                print("LIBRARY COUNT: \(count)")
                self?.count = count
                
                DispatchQueue.main.async {
                    self?.totalTBRCount.text = String(count)
                }
            case .failure(let error):
                print("failed to get unread book count: \(error)")
            }
        })
    }
}
