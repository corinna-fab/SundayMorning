import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //This is weak to keep memory from leaking 
    weak var delegate: AllSavedBooksViewController!
    var searchResults: [Book] = []
    
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var totalResults: UILabel!
    
    @IBAction func search(sender: UIButton) {
        print("Searching for \(self.searchTextField.text!)")
        
        let searchTerm = searchTextField.text!
        if searchTerm.count > 2 {
            retrieveMoviesByTerm(searchTerm: searchTerm)
            searchTextField.text = ""
            searchTextField.resignFirstResponder()
        }
    }
    
    @IBAction func pressedScanBarcode(_ sender: Any) {
        print("barcode.")
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      if indexPath.row !=  nil {
          return 125
       }

       // Use the default size for all other rows.
       return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // grouped vertical sections of the tableview
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // at init/appear ... this runs for each visible cell that needs to render
        let bookcell = tableView.dequeueReusableCell(withIdentifier: "bookSearchCell", for: indexPath) as! CustomBookListTableViewCell
        
        let idx: Int = indexPath.row
//        moviecell.favButton.tag = idx
        bookcell.accessoryType = .disclosureIndicator
        //title
        bookcell.bookTitle?.text = searchResults[idx].title
        //year
        bookcell.bookAuthor?.text = searchResults[idx].author
        // image
        displayBookImage(idx, moviecell: bookcell)
        //TO DO check to see if different logins display their own list
        return bookcell
    }
    
    func displayBookImage(_ row: Int, moviecell: CustomBookListTableViewCell) {
        let url: String = (URL(string: searchResults[row].imageUrl)?.absoluteString)!
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                let image = UIImage(data: data!)
                moviecell.bookImageView?.image = image
            })
        }).resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.returnKeyType = .done
        searchTextField.autocapitalizationType = .words
        searchTextField.autocorrectionType = .default
        searchTextField.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Confirm that a book was selected
        guard tableView.indexPathForSelectedRow != nil else {
            return
        }
        //Get a reference to the video tapped on
        let selectedBook = searchResults[tableView.indexPathForSelectedRow!.row]
        //get a reference to the detail view controller
        let destinationVC = segue.destination as! BookDetailsPageViewController
        //Set the property of the detail view controller
        destinationVC.book = selectedBook
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func retrieveMoviesByTerm(searchTerm: String) {
        let bookURL = "https://www.googleapis.com/books/v1/volumes?&key=\(K.GOOGLE_API_KEY)"
        let url = "\(bookURL)&q=\(searchTerm)"
        HTTPHandler.getJSON(urlString: url, completionHandler: parseDataIntoMovies)
    }
    
    func parseDataIntoMovies(data: Data?) -> Void {
        if let data = data {
            let object = JSONParser.parse(data: data)
            
            if let object = object {
                print("This is an object")
//                print(object["items"])
                self.searchResults = BookDataProcessor.mapJSONToBook(object: object)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.totalResults.text = "\(object["totalItems"] ?? "Zero" as AnyObject) total results)"
                }
            }
        }
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("Searching for \(self.searchTextField.text!)")
        
        let searchTerm = searchTextField.text!
        if searchTerm.count > 2 {
            retrieveMoviesByTerm(searchTerm: searchTerm)
            searchTextField.text = ""
            searchTextField.resignFirstResponder()
            return true
        }
        return false
    }
}
