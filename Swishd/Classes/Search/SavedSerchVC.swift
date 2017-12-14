

import UIKit

protocol SavedSearchDelegate: NSObjectProtocol {
    func updateSaveSearch(searchObj: Search?)
}

class SavedSearchCell : ConstrainedTableViewCell{
    
    @IBOutlet weak var lblFromLocation: UILabel!
    @IBOutlet weak var lblToLocation: UILabel!
    @IBOutlet weak var btnSaveList: UIButton!
    @IBOutlet weak var lblFromTitle: UILabel!
    @IBOutlet weak var lblToTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareUI(){
        lblToTitle.isHidden = false
        lblFromTitle.isHidden = false
    }
}

class SavedSerchVC: ParentViewController {
    
    /// Variables
    var arrOfSearch : [Search]!
    var loadMore = LoadMore()
    weak var delegate: SavedSearchDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getSavedSearch()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! SearchResultVC
        vc.isFromSaved = true
        vc.delegate = self
        vc.advanceSearch = sender as! Search
    }
}

// MARK: - UI & Utility Methods
extension SavedSerchVC{
    
    func prepareUI()  {
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
        tableView.contentInset  = UIEdgeInsets(top: 10 * _widthRatio, left: 0, bottom: 10 * _widthRatio, right: 0)
        referesh.addTarget(self, action: #selector(self.refreshData(sender:)), for: UIControlEvents.valueChanged)
        tableView.register(UINib(nibName: "AdvanceSearchCell", bundle: nil), forCellReuseIdentifier: "advanceSearchCell")
        tableView.register(UINib(nibName: "SearchCell", bundle: nil), forCellReuseIdentifier: "searchCell")
        tableView.addSubview(referesh)
    }
    
    @objc func refreshData(sender: UIRefreshControl)  {
        loadMore = LoadMore()
        getSavedSearch()
    }
}

// MARK: - Delegate
extension SavedSerchVC: SavedSearchDelegate{
    
    func updateSaveSearch(searchObj: Search?) {
        self.loadMore = LoadMore()
        getSavedSearch()
    }
    
//    func unsaveSearch() {
//        self.loadMore = LoadMore()
//        getSavedSearch()
//    }
}

// MARK: - Button action
extension SavedSerchVC{

    @IBAction func btnRemoveAction(_ sender: UIButton){
        removeSavedSearch(index: sender.tag)
        tableView.reloadData()
    }
}

// MARK: - Tableview Method
extension SavedSerchVC{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrOfSearch != nil{
            if arrOfSearch.isEmpty{
                return 1
            }
            return arrOfSearch.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if arrOfSearch != nil{
            if !arrOfSearch.isEmpty{
                if !arrOfSearch[indexPath.row].isAnytime && arrOfSearch[indexPath.row].specificDate == nil && arrOfSearch[indexPath.row].everyDay.isEmpty{
                    return 80 * _widthRatio
                }
            }
        }
        return 130 * _widthRatio
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if arrOfSearch.isEmpty{
            let cell = tableView.dequeueReusableCell(withIdentifier: "noDataFoundCell") as! NOItemCell
            return cell
        }else{
            let search = arrOfSearch[indexPath.row]
            if !search.isAnytime && search.specificDate == nil && search.everyDay.isEmpty{
                let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as! SearchCell
                cell.savedSearchParent = self
                cell.tag = indexPath.row
                cell.prepareUI(search: search)
                if indexPath.row == arrOfSearch.count - 1 && !loadMore.isLoading && !loadMore.isAllLoaded{
                    getSavedSearch()
                }
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "advanceSearchCell") as! SearchCell
                cell.savedSearchParent = self
                cell.tag = indexPath.row
                cell.prepareUIForAdvanceSaecrh(search: search)
                if indexPath.row == arrOfSearch.count - 1 && !loadMore.isLoading && !loadMore.isAllLoaded{
                    getSavedSearch()
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "searchByIdSegue", sender: arrOfSearch[indexPath.row])
    }
}

//MARK: - API call
extension SavedSerchVC{
    
    func removeSavedSearch(index: Int){
        self.showCentralSpinner()
        KPWebCall.call.removeSavedSerach(searchId: arrOfSearch[index].searchID!) { (json, flag) in
            self.hideCentralSpinner()
            if flag == 200 {
                self.delegate?.updateSaveSearch(searchObj: nil)
                if let _ = json as? NSDictionary{
                    self.arrOfSearch.remove(at: index)
                    self.tableView.reloadData()
                }else{
                    self.showError(data: json, yPos: _topMsgBarConstant)
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
    
    func getSavedSearch(){
        let dict : [String : Any] = ["limit":self.loadMore.limit,"start": self.loadMore.offset]
        if !referesh.isRefreshing && loadMore.index == 0{
            self.showCentralSpinner()
        }
        loadMore.isLoading = true
        KPWebCall.call.getSavedSerachList(param: dict) { (json, flag) in
            self.loadMore.isLoading = false
            self.referesh.endRefreshing()
            self.hideCentralSpinner()
            if flag == 200 {
//                self.delegate?.updateSaveSearch(searchObj: nil)
                if let dict = json as? NSDictionary{
                    if let searchList = dict["data"] as? [NSDictionary]{
                        if self.loadMore.index == 0{
                            self.arrOfSearch = []
                        }
                        for search in searchList{
                            self.arrOfSearch.append(Search(dict: search))
                        }
                        if searchList.isEmpty{
                            self.loadMore.isAllLoaded = true
                        }else{
                            self.loadMore.index += 1
                        }
                        self.tableView.reloadData()
                    }
                }else{
                    self.showError(data: json, yPos: _topMsgBarConstant)
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
}
