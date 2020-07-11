//
//  SavedBookDetailsViewController.swift
//  Sunday Morning 2
//
//  Created by Corinna Fabre on 7/11/20.
//  Copyright © 2020 Corinna Fabre. All rights reserved.
//

import UIKit

class SavedBookDetailsViewController: UIViewController {

    @IBOutlet weak var bookCover: UIImageView!
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookAuthor: UILabel!
    @IBOutlet weak var bookDescription: UILabel!
    @IBOutlet weak var readStatus: UILabel!
    
    var book:Book?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bookTitle.text = book?.title
        bookAuthor.text = book?.author
        
        bookDescription.text = book?.description
        bookDescription.layer.borderColor = #colorLiteral(red: 0.7993473411, green: 0.9317976832, blue: 0.7041511536, alpha: 1)
        bookDescription.layer.borderWidth = 5
        // Do any additional setup after loading the view.
        
        if book?.read == false {
            readStatus.text = "Not read"
        } else {
            readStatus.text = "Read!"
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
