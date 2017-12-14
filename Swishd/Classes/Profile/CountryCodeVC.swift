

import UIKit


class Country: NSObject{
    var name : String
    var dialCode : String
    var code : String
    
    init(dict : NSDictionary) {
        name = dict.getStringValue(key: "name")
        dialCode = dict.getStringValue(key: "dial_code")
        code = dict.getStringValue(key: "code")
    }
}

class CountryCodeCell: ConstrainedTableViewCell {
    
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblCode: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class CountryCodeVC: ParentViewController {

    /// IBOutlets
    @IBOutlet var searchBar: UISearchBar!
    
    /// Variables
    var countries: [Country] = []
    var searchCountries: [Country] = []
    var selectonBlock: ((Country) -> ())?
    
    /// View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareForkeyboardNotification()
        getCountryList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        _defaultCenter.removeObserver(self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

// MARK: - Search bar delegate
extension CountryCodeVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty{
            searchCountries = countries.filter({ (country) -> Bool in
                return country.dialCode.contains(find: searchText) || country.code.contains(find: searchText) || country.name.contains(find: searchText)
            })
        }else{
            searchCountries = countries
        }
        self.tableView.reloadData()
    }
}

// MARK: - TableView Methods
extension CountryCodeVC{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchCountries.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50 * _widthRatio
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CountryCodeCell
        cell.lblCode.text = searchCountries[indexPath.row].dialCode
        cell.lblName.text = searchCountries[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectonBlock?(searchCountries[indexPath.row])
        _ = self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UI & Utility Methods
extension CountryCodeVC{

    func getCountryList()  {
        let contryPath = Bundle.main.path(forResource: "countries", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: contryPath))
        do {
            if let dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any], let list = dict["list"] as? [[String:Any]] {
                for countryInfo in list {
                    let cont = Country(dict: countryInfo as NSDictionary)
                    countries.append(cont)
                }
                searchCountries = countries
            }else{
                countries = []
                searchCountries = []
            }
            self.tableView.reloadData()
        } catch let error as NSError {
            kprint(items: "Error: \(error.localizedDescription)")
        }
    }
}

// MARK: - Keyboard Extension
extension CountryCodeVC {
    func prepareForkeyboardNotification() {
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        if let kbSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
