import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var searchResults: [Book] = []
    
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var totalResults: UILabel!
    
    @IBAction func search(sender: UIButton) {
        print("Searching for \(self.searchTextField.text!)")
        
        let searchTerm = searchTextField.text!
        if searchTerm.count > 2 {
            retrieveBooksByTerm(searchTerm: searchTerm)
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
        bookcell.accessoryType = .disclosureIndicator
        bookcell.bookTitle?.text = searchResults[idx].title
        bookcell.bookAuthor?.text = searchResults[idx].author
        displayBookImage(idx, bookCell: bookcell)
        return bookcell
    }
    
    func displayBookImage(_ row: Int, bookCell: CustomBookListTableViewCell) {
        let url: String = (URL(string: searchResults[row].imageUrl)?.absoluteString)!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.returnKeyType = .done
        searchTextField.autocapitalizationType = .words
        searchTextField.autocorrectionType = .default
        searchTextField.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard tableView.indexPathForSelectedRow != nil else {
            return
        }
        let selectedBook = searchResults[tableView.indexPathForSelectedRow!.row]
        let destinationVC = segue.destination as! BookDetailsPageViewController
        destinationVC.book = selectedBook
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func retrieveBooksByTerm(searchTerm: String) {
        let bookURL = "https://www.googleapis.com/books/v1/volumes?&key=\(K.GOOGLE_API_KEY)&maxResults=40"
        let url = "\(bookURL)&q=\(searchTerm)"
        HTTPHandler.getJSON(urlString: url, completionHandler: parseDataIntoMovies)
    }
    
    func parseDataIntoMovies(data: Data?) -> Void {
        if let data = data {
            let object = JSONParser.parse(data: data)
            
            if let object = object {
                self.searchResults = BookDataProcessor.mapJSONToBook(object: object)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.totalResults.text = "\(object["totalItems"] ?? "Zero" as AnyObject) total results"
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
            retrieveBooksByTerm(searchTerm: searchTerm)
            searchTextField.text = ""
            searchTextField.resignFirstResponder()
            return true
        }
        return false
    }
}
