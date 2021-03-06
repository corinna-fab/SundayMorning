//
//  BookDetailsPageViewController.swift
//  Sunday Morning 2
//
//  Created by Corinna Fabre on 7/7/20.
//  Copyright © 2020 Corinna Fabre. All rights reserved.
//

import UIKit
import WebKit
import FirebaseAuth
import SCLAlertView

class CustomListsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    
    private var customListCollection = [List]()
    
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
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        DatabaseManager.shared.getAllLists(with: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let lists):
                guard !lists.isEmpty else {
                    print("nothing to see here")
                    return
                }
                self?.customListCollection = lists
                print("this is where the collection would go")
                DispatchQueue.main.async {
                    self?.table.reloadData()
                }
                
            case .failure(let error):
                print("failed to get books: \(error)")
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customListCollection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UITableViewCell
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = "\(customListCollection[indexPath.row].title)"
        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = customListCollection[indexPath.row]
        
        guard let vc = storyboard?.instantiateViewController(identifier: "allBooks") as? AllUserBooksViewController else {
            return
        }
        vc.picklength = model.pickLength
        vc.unreadOnly = model.unreadOnly
        //Setting the vc title puts the list title at the top of the page where "My Books" went before
        vc.title = model.title
        
        navigationController?.pushViewController(vc, animated: true)
    }


    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard table.indexPathForSelectedRow != nil else {
            return
        }
        let selectedList = customListCollection[table.indexPathForSelectedRow!.row]
        let destinationVC = segue.destination as! AllUserBooksViewController
        destinationVC.selectedList?.pickLength = selectedList.pickLength
        destinationVC.selectedList?.title = selectedList.title
        destinationVC.selectedList?.unreadOnly = selectedList.unreadOnly
    }
}
