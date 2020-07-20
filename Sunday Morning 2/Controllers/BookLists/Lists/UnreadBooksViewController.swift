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

class UnreadBooksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    var unreadOnly: Bool = false
    var picklength: String = ""
    var genre: String = ""
    
    @IBAction func handleSelection(_ sender: UIButton) {
        choiceCollection.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    @IBAction func handleLengthSelection(_ sender: Any) {
        lengthCollection.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func handleStatusSelection(_ sender: Any) {
        readStatusCollection.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBOutlet var lengthCollection: [UIButton]!
    @IBOutlet var readStatusCollection: [UIButton]!
    @IBOutlet var choiceCollection: [UIButton]!
    
    
    private let refreshControl = UIRefreshControl()
//    private var bookData = [BookItem]()
//    private let realm = try! Realm()
//    public var completionHandler: (() -> Void)?
    
    private var conversations = [Book]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl.addTarget(self, action: #selector(refreshBookData(_:)), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Book List ...")
        refreshControl.tintColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        
//        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        let nib = UINib(nibName: "SavedBooksTableViewCell", bundle: nil)
        table.register(nib, forCellReuseIdentifier: "SavedBooksTableViewCell")
        table.refreshControl = refreshControl
        table.delegate = self
        table.dataSource = self
        
        startListeningForBooks()
    }
    
    ///Tells the table to refresh upon pull down
    //https://cocoacasts.com/how-to-add-pull-to-refresh-to-a-table-view-or-collection-view
    @objc private func refreshBookData(_ sender: Any) {

        table.reloadData()
        
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
    }
    
    enum Lengths: String {
        case short = "Short"
        case medium = "Medium"
        case long = "Long"
    }
    
    @IBAction func lengthTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let length = Lengths(rawValue: title) else {
            return
        }
        
        switch length {
        case .short:
            print("I'm short")
            picklength = "Short"
            
            startListeningForBooks()
            table.reloadData()
            
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        case .medium:
            print("I'm medium")
            picklength = "Medium"
            
            startListeningForBooks()
            table.reloadData()
            
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        case .long:
            print("I'm long")
            picklength = "Long"
            
            startListeningForBooks()
            table.reloadData()
            
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        default:
            print("Default.")
        }
    }
    
    //Change this to fiction/non-fiction
    @IBAction func didSwitchtoUnreadOnly() {
        print("ADD!")
        
        if unreadOnly == false {
            unreadOnly = true
            
            startListeningForBooks()
            table.reloadData()
            
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        } else {
            unreadOnly = false
            startListeningForBooks()
            table.reloadData()
            
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private func startListeningForBooks() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        print("Starting to fetch books")

        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        DatabaseManager.shared.getAllBooks(with: safeEmail, unreadOnly: unreadOnly, length: picklength, genre: genre, completion: { [weak self] result in
            switch result {
            case .success(let conversations):
                print("successfully got book models")
                print("\(conversations)")
                guard !conversations.isEmpty else {
                    print("nothing to see here")
                    return
                }
                
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedBooksTableViewCell", for: indexPath) as! SavedBooksTableViewCell
        cell.accessoryType = .disclosureIndicator
        cell.bookAuthor.text = conversations[indexPath.row].author
        cell.bookTitle.text = conversations[indexPath.row].title
        displayMovieImage(indexPath.row, cell: cell)
//        cell.textLabel?.numberOfLines = 0
//        cell.textLabel!.text = conversations[indexPath.row].title
        return cell
    }
    
    func displayMovieImage(_ row: Int, cell: SavedBooksTableViewCell) {
        let url: String = (URL(string: conversations[row].imageUrl)?.absoluteString)!
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                let image = UIImage(data: data!)
                cell.bookCover?.image = image
            })
        }).resume()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = conversations[indexPath.row]
        print("\(model.title)")
        
        guard let vc = storyboard?.instantiateViewController(identifier: "savedBook") as? SavedBookDetailsViewController else {
            return
        }
        vc.book = model
        
        navigationController?.pushViewController(vc, animated: true)
        print("You hit me")
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//     if (editingStyle == .delete){
//            let item = conversations[indexPath.row]
//            try! self.realm.write({
//                self.realm.delete(item)
//            })
//            bookData.remove(at: indexPath.row)
//            tableView.deleteRows(at:[indexPath], with: .automatic)
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      if indexPath.row !=  nil {
          return 125
       }

       // Use the default size for all other rows.
       return UITableView.automaticDimension
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
        destinationVC.book = selectedBook
    }
    
    func refresh(){
        table.reloadData()
    }
    
}
//
//class BookItem: Object {
//    @objc dynamic var id: String = ""
//    @objc dynamic var title: String = ""
//    @objc dynamic var imageUrl: String = ""
//    @objc dynamic var author: String = ""
//    @objc dynamic var bookDescription: String = ""
//    @objc dynamic var isbn: String = ""
//    @objc dynamic var dateAdded: Date = Date()
////    @objc dynamic var email: String = (FirebaseAuth.Auth.auth().currentUser?.email!)!
//}
//
//class BookCell: UITableViewCell {
//    @IBOutlet var title : UILabel?
//    @IBOutlet var author : UILabel?
//}
