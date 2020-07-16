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
import SCLAlertView

class CustomListsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    
    private var conversations = [List]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.delegate = self
        table.dataSource = self
        
        startListeningForBooks()
    }
    
    private func startListeningForBooks() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        print("Starting to fetch books")
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        DatabaseManager.shared.getAllLists(with: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let conversations):
                print("successfully got book models")
                print("\(conversations)")
                guard !conversations.isEmpty else {
                    print("nothing to see here")
                    return
                }
                print("LIST COUNT: \(conversations.count)")
                self?.conversations = conversations
                print("this is where the collection would go")
                DispatchQueue.main.async {
                    self?.table.reloadData()
                }
                
            case .failure(let error):
                //                self?.tableView.isHidden = true
                //                self?.noConversationsLabel.isHidden = false
                print("failed to get books: \(error)")
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UITableViewCell
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = "\(conversations[indexPath.row].title)"
//        cell.bookAuthor.text = conversations[indexPath.row].author
        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = conversations[indexPath.row]
//        print("\(model.title)")
        
        guard let vc = storyboard?.instantiateViewController(identifier: "savedBook") as? SavedBookDetailsViewController else {
            return
        }
//        vc.book = model
        //        vc.bookTitle.text = model.title as! String
        //        vc.bookAuthor.text = model.author as! String
        //        vc.bookDescription.text = model.description as! String
        
        navigationController?.pushViewController(vc, animated: true)
        print("You hit me")
        //Open to screen where we can see additional info
    }


    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Confirm that a book was selected
        guard table.indexPathForSelectedRow != nil else {
            return
        }
        //Get a reference to the video tapped on
        let selectedBook = conversations[table.indexPathForSelectedRow!.row]
        //get a reference to the detail view controller
        let destinationVC = segue.destination as! BookDetailsPageViewController
        //Set the property of the detail view controller
//        destinationVC.book = selectedBook
    }
}
