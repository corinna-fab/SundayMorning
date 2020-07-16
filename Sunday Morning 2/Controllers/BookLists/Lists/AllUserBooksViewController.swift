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

//TO DO: Make header update with list name, My Books as default
class AllUserBooksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    @IBOutlet weak var readOrUnreadButton: UIButton!
    
    var unreadOnly: Bool = false
    var picklength: String = ""
    var listTitle: String? = ""
    
    var selectedList: List?
    
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
    @IBOutlet weak var saveListButton: UIButton!
    
    @IBAction func saveList(_ sender: UIButton) {
        //Send to database here
        print("Click")
        
        //ALERTVIEW RESOURCE: https://github.com/vikmeup/SCLAlertView-Swift
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "Farah", size: 20)!,
            kTextFont: UIFont(name: "Farah", size: 14)!,
            kButtonFont: UIFont(name: "Farah", size: 14)!,
            showCloseButton: false,
            showCircularIcon: false,
            contentViewColor: #colorLiteral(red: 0.5667160749, green: 0.6758385897, blue: 0.56330055, alpha: 1),
            contentViewBorderColor: #colorLiteral(red: 0.247261852, green: 0.2675772011, blue: 0.2539684772, alpha: 1)
        )
        
        let alertView = SCLAlertView(appearance: appearance)
        let txt = alertView.addTextField("List   name")
        alertView.addButton("Done", backgroundColor: #colorLiteral(red: 0.367708087, green: 0.4341275096, blue: 0.3933157027, alpha: 1)) {
//            print("\(txt.text)")
            DatabaseManager.shared.addNewList(unreadOnly: self.unreadOnly, pickLength: self.picklength, title: (txt.text ?? "Saved User List") as String, completion: { success in
                if success {
                    print("Message sent. WOO")
                    let timer = SCLAlertView.SCLTimeoutConfiguration.init(timeoutValue: 2.0, timeoutAction: {})
                    SCLAlertView(appearance: appearance).showTitle(
                        "YAY!", // Title of view
                        subTitle: "List successfully saved.", // String of view
                        timeout: timer, // Duration to show before closing automatically, default: 0.0
                        completeText: "Done", // Optional button value, default: ""
                        style: .success, // Styles - see below.
                        colorStyle: 1,
                        colorTextButton: 1
                    )
//                    let appearance = SCLAlertView.SCLAppearance(
//                        kTitleFont: UIFont(name: "Farah", size: 20)!,
//                        kTextFont: UIFont(name: "Farah", size: 14)!,
//                        kButtonFont: UIFont(name: "Farah", size: 14)!,
//                        showCloseButton: true,
//                        showCircularIcon: false,
//                        contentViewColor: #colorLiteral(red: 0.5667160749, green: 0.6758385897, blue: 0.56330055, alpha: 1),
//                        contentViewBorderColor: #colorLiteral(red: 0.247261852, green: 0.2675772011, blue: 0.2539684772, alpha: 1)
//                    )
//                    let alertView = SCLAlertView(appearance: appearance)
//                    alertView.showCustom("YAY", subTitle: "Your custom list has successfully been saved", color: #colorLiteral(red: 0.5667160749, green: 0.6758385897, blue: 0.56330055, alpha: 1), icon: UIImage(systemName: "plus.square.fill"), closeButtonTitle: "Done.", timeout: <#T##SCLAlertView.SCLTimeoutConfiguration?#>, colorStyle: UInt, colorTextButton: <#T##UInt#>, circleIconImage: <#T##UIImage?#>, animationStyle: <#T##SCLAnimationStyle#>)
//                    alertView.showSuccess("YAY!", subTitle: "Your custom list has successfully been saved")
                } else {
                    print("Failed to send")
                    
                }
            })
        }
        alertView.showEdit("Save  List", subTitle: "What   would   you  like  to  call  this  list?")
    }
    
//    func showAlert() {
//        let alert = UIAlertController(title: "Title", message: "Hello World", preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { action in
//            print("Tapped dismiss.")
//        }))
//
//        present(alert, animated: true)
//    }
//
//    func showActionSheet() {
//        let actionsheet = UIAlertController(title: "Title", message: "Hello World", preferredStyle: .actionSheet)
//
//        actionsheet.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { action in
//            print("Tapped dismiss.")
//        }))
//
//        present(actionsheet, animated: true)
//    }
    
    
    //For dropdown: https://www.youtube.com/watch?v=dIKK-SCkh_c
    //    @IBAction func selectLength(_ sender: UIButton) {
    //        lengthButtons.forEach { (button) in
    //            UIView.animate(withDuration: 0.3, animations: {
    //                button.isHidden = !button.isHidden
    //                self.view.layoutIfNeeded()
    //            })
    //        }
    //    }
    private let refreshControl = UIRefreshControl()
    //    private var bookData = [BookItem]()
    //    private let realm = try! Realm()
    //    public var completionHandler: (() -> Void)?
    
    private var conversations = [Book]()
    
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
    
    @IBAction func didSwitchtoUnreadOnly() {
        print("ADD!")
        
        if unreadOnly == false {
            unreadOnly = true
            
            startListeningForBooks()
            table.reloadData()
            
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.readOrUnreadButton.titleLabel?.text = "All Titles"
            }
        } else {
            unreadOnly = false
            startListeningForBooks()
            table.reloadData()
            
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.readOrUnreadButton.titleLabel?.text = "Unread Titles Only"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Unread: \(unreadOnly)")
        print("Length: \(picklength)")
        print("Title: \(title)")
//        if selectedList != nil {
//            self.unreadOnly = ((selectedList?.unreadOnly) != nil)
//            self.picklength = selectedList?.pickLength as! String
//            self.title = selectedList?.title
//            print("Unread: \(unreadOnly)")
//            print("Length: \(pickLength)")
//            print("Title: \(title)")
//            table.reloadData()
//
//            DispatchQueue.main.async {
//                self.refreshControl.endRefreshing()
//            }
//        }
        
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
    
    private func startListeningForBooks() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        print("Starting to fetch books")
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        DatabaseManager.shared.getAllBooks(with: safeEmail, unreadOnly: unreadOnly, length: picklength, completion: { [weak self] result in
            switch result {
            case .success(let conversations):
                print("successfully got book models")
                print("\(conversations)")
                guard !conversations.isEmpty else {
                    print("nothing to see here")
                    return
                }
                print("LIBRARY COUNT: \(conversations.count)")
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
        //        vc.bookTitle.text = model.title as! String
        //        vc.bookAuthor.text = model.author as! String
        //        vc.bookDescription.text = model.description as! String
        
        navigationController?.pushViewController(vc, animated: true)
        print("You hit me")
        //Open to screen where we can see additional info
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
