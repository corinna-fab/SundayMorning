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

class TESTViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    
    private let refreshControl = UIRefreshControl()
    private var bookData = [BookItem]()
    private let realm = try! Realm()
    public var completionHandler: (() -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bookData = realm.objects(BookItem.self).map({$0})
        refreshControl.addTarget(self, action: #selector(refreshBookData(_:)), for: .valueChanged)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.refreshControl = refreshControl
        table.delegate = self
        table.dataSource = self
    }
    
    @objc private func refreshBookData(_ sender: Any) {
        // Fetch Weather DataBookData()
        bookData = realm.objects(BookItem.self).map({$0})
        table.reloadData()
        
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel!.text = bookData[indexPath.row].title
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //Open to screen where we can see additional info
    }

    func refresh(){
        bookData = realm.objects(BookItem.self).map({$0})
        table.reloadData()
    }
    
}

class BookItem: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var imageUrl: String = ""
    @objc dynamic var author: String = ""
    @objc dynamic var bookDescription: String = ""
    @objc dynamic var isbn: String = ""
    @objc dynamic var dateAdded: Date = Date()
    @objc dynamic var email: String = (FirebaseAuth.Auth.auth().currentUser?.email!) as! String
}
