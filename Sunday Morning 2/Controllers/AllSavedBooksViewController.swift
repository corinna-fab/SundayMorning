//
//  ViewController.swift
//  Sunday Morning 2
//
//  Created by Corinna Fabre on 7/4/20.
//  Copyright © 2020 Corinna Fabre. All rights reserved.
//

import UIKit
import FirebaseAuth

class AllSavedBooksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var allBooks: [Book] = []
    @IBOutlet weak var mainTableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allBooks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bookCell = tableView.dequeueReusableCell(withIdentifier: "bookListCell", for: indexPath) as! CustomBookListTableViewCell
        
        let idx: Int  = indexPath.row
        bookCell.bookTitle.text = allBooks[idx].title
//        bookCell.bookAuthor.text = allBooks[idx].author
        
        displayBookImage(idx, bookCell: bookCell)
        return bookCell
    }
    
    func displayBookImage(_ row: Int, bookCell: CustomBookListTableViewCell){
        let url: String = (URL(string: allBooks[row].imageUrl)?.absoluteString)!
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                let image = UIImage(data: data!)
                bookCell.bookImageView?.image = image
            })
            }).resume()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mainTableView.reloadData()
        if allBooks.count  == 0 {
            allBooks.append(Book(id: "123456",
                                 title: "Men Explain Things to Me",
//                                 author: "Rebecca Solnit",
//                                 year: "2007",
                                 imageUrl: "https://images-na.ssl-images-amazon.com/images/I/41yudIp+dmL._SX348_BO1,204,203,200_.jpg"))
        }
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        
        validateAuth()
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    

}

