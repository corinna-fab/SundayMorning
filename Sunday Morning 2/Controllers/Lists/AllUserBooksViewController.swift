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

class AllUserBooksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    
    var unreadOnly: Bool = false
    var picklength: String = ""
    var listTitle: String? = ""
    var genreSelection: String? = ""
    var categoryArray: [String] = []
    var selectedCategories: String? = ""
    
    var selectedList: List?
    
    @IBAction func handleSelection(_ sender: UIButton) {
        choiceCollection.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
        
        resetButton.isHidden = !resetButton.isHidden
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
    
    @IBAction func handleGenreSelection(_ sender: Any) {
        genreCollection.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func handleCategoryFilter(_ sender: Any) {
        print("Works")
        
        UIView.animate(withDuration: 0.3, animations: {
            self.categoryPicker.isHidden = !self.categoryPicker.isHidden
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func resetList(_ sender: UIButton) {
        lengthCollection.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = true
                self.view.layoutIfNeeded()
            })
        }
        
        readStatusCollection.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = true
                self.view.layoutIfNeeded()
            })
        }
        
        genreCollection.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = true
                self.view.layoutIfNeeded()
            })
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.categoryPicker.isHidden = true
            self.view.layoutIfNeeded()
        })
    }
    
    @IBOutlet var lengthCollection: [UIButton]!
    @IBOutlet var readStatusCollection: [UIButton]!
    @IBOutlet var genreCollection: [UIButton]!
    @IBOutlet var choiceCollection: [UIButton]!
    @IBOutlet weak var saveListButton: UIButton!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var resetButton: UIButton!
    
    @IBAction func saveList(_ sender: UIButton) {
        
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
                } else {
                    print("Failed to send")
                    
                }
            })
        }
        alertView.showEdit("Save  List", subTitle: "What   would   you  like  to  call  this  list?")
    }
    
    private let refreshControl = UIRefreshControl()
    
    private var conversations = [Book]()
    
    enum Lengths: String {
        case short = "Short"
        case medium = "Medium"
        case long = "Long"
    }
    
    enum Genres: String {
        case nonfiction = "Nonfiction"
        case fiction = "Fiction"
    }
    
    @IBAction func lengthTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let length = Lengths(rawValue: title) else {
            return
        }
        
        switch length {
        case .short:
            picklength = "Short"
            
            startListeningForBooks()
            table.reloadData()
            
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        case .medium:
            picklength = "Medium"
            
            startListeningForBooks()
            table.reloadData()
            
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        case .long:
            picklength = "Long"
            
            startListeningForBooks()
            table.reloadData()
            
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    @IBAction func didSwitchtoUnreadOnly() {
        
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
    
    @IBAction func switchGenres(_ sender: Any) {
        guard let title = (sender as AnyObject).currentTitle, let genre = Genres(rawValue: title!) else {
            return
        }
        
        switch genre {
        case .nonfiction:
            genreSelection = "Nonfiction"
            
            startListeningForBooks()
            table.reloadData()
            
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        case .fiction:
            genreSelection = "Fiction"
            
            startListeningForBooks()
            table.reloadData()
            
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    @IBAction func resetBookList(_ sender: Any) {
        unreadOnly = false
        picklength = ""
        listTitle = ""
        genreSelection = ""
        selectedCategories = ""
        
        startListeningForBooks()
        table.reloadData()
        
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        
        refreshControl.addTarget(self, action: #selector(refreshBookData(_:)), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Book List ...")
        refreshControl.tintColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        
        let nib = UINib(nibName: "SavedBooksTableViewCell", bundle: nil)
        table.register(nib, forCellReuseIdentifier: "SavedBooksTableViewCell")
        table.refreshControl = refreshControl
        table.delegate = self
        table.dataSource = self
        
        startListeningForBooks()
    }
    
    //Tells the table to refresh upon pull down
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
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        DatabaseManager.shared.getAllBooks(with: safeEmail, unreadOnly: unreadOnly, length: picklength, genre: genreSelection!, category: selectedCategories!, completion: { [weak self] result in
            switch result {
            case .success(let conversations):
                print("successfully got book models")
                guard !conversations.isEmpty else {
                    print("nothing to see here")
                    return
                }
                self?.conversations = conversations
                DispatchQueue.main.async {
                    self?.table.reloadData()
                }
                
                DatabaseManager.shared.getCategories(with: safeEmail, completion: { [weak self] result in
                            switch result {
                            case .success(var categories):
                                //To get unique values: https://stackoverflow.com/questions/25738817/removing-duplicate-elements-from-an-array-in-swift
                                categories = Array(Set(categories))
                                
                                categories.removeAll { $0 == "Fiction" || $0 == "Nonficton" }
                                self?.categoryArray = categories
                                
                            case .failure(let error):
                                print("failed to get unread book count: \(error)")
                            }
                        })
                
            case .failure(let error):
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
        displayCoverImage(indexPath.row, cell: cell)
        return cell
    }
    
    func displayCoverImage(_ row: Int, cell: SavedBooksTableViewCell) {
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
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row !=  nil {
            return 80
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

extension AllUserBooksViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryArray.count
    }
}

extension AllUserBooksViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        categoryArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        UIView.animate(withDuration: 0.8, animations: {
            self.categoryPicker.isHidden = true
            print("Selected Category: \(self.categoryArray[row])")
            self.view.layoutIfNeeded()
            
            
            self.selectedCategories = self.categoryArray[row]
            
            self.startListeningForBooks()
            self.table.reloadData()
            
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        })
    }
    
}
