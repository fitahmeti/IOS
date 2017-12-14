

import UIKit

class SearchDataCell : ConstrainedTableViewCell{
    @IBOutlet weak var lblSourceAdd : UILabel!
    @IBOutlet weak var lblDestAdd : UILabel!
    @IBOutlet weak var lblDeliviries : UILabel!
    @IBOutlet weak var imgSavedStatus : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class SearchResultVC: ParentViewController {
    
    @IBOutlet var btnSave: UIButton!
    
    /// Variables
    var arrOfSearchedJob : [Job]!
    var loadMore = LoadMore()
    var totalCount = 0
    var noResult : Bool = false
    var arrOfSorting = ["distance","pickdate","price" ,"itemsize","swishdpickupoffice"]
    var advanceSearch: Search!
    var sortStr = "distance"
    var searchId: String!
    var searchStatus: SearchStatus = .unknown
    var isFromSaved: Bool = false
    var isFromRecent: Bool = false
    weak var delegate: SavedSearchDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        if isFromSaved || isFromRecent{
            searchJobByID()
            self.btnSave.isSelected = advanceSearch.searchStatus == .saved
        }else{
            searchJobResult()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "jobDetailSegue"{
            let dest = segue.destination as! JobDetailVC
            dest.jobId = sender as! String
        }else{
            let vc = segue.destination as! SerchVC
            vc.isFromEdit = true
            vc.advanceSearchData = advanceSearch
        }
    }
}

// MARK: - UI & Utility Methods
extension SearchResultVC{
    
    func prepareUI()  {
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
        tableView.contentInset  = UIEdgeInsets(top: 5 * _widthRatio, left: 0, bottom: 10 * _widthRatio, right: 0)
        referesh.addTarget(self, action: #selector(self.refreshData(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(referesh)
        btnSave.isSelected = advanceSearch.searchStatus == .saved
        tableView.register(UINib.init(nibName: "Job_newCell", bundle: nil), forCellReuseIdentifier: "jobCellNew")
    }
    
    @objc func refreshData(sender: UIRefreshControl)  {
        loadMore = LoadMore()
        if isFromSaved || isFromRecent{
            searchJobByID()
        }else{
            searchJobResult()
        }
    }
    
    func updateBtnSaveStatus(status:String) {
        let saveStatus = SearchStatus(str: status)
        self.advanceSearch.searchStatus = saveStatus
        self.btnSave.isSelected = saveStatus == .saved
    }
}

//MARK: - Button Action
extension SearchResultVC{
    
    @IBAction func btnEditAction(_ sender : UIButton){
        if !isFromSaved{
            self.delegate?.updateSaveSearch(searchObj: advanceSearch)
        }
        performSegue(withIdentifier: "editSearchSegue", sender: nil)
    }

    
    @IBAction func saveSearchAction(_ sender: UIButton){
        if isFromSaved || isFromRecent{
            self.updateSaveStatus(id: advanceSearch.searchID!)
        } else {
            if let id = searchId{
             self.updateSaveStatus(id: id)
            }
        }
    }
    
    @IBAction func backAction(_ sender: UIButton){
        if isFromSaved && advanceSearch.searchStatus == .unsaved{
            delegate?.updateSaveSearch(searchObj: nil)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSortAction(_ sender : UIButton){
        let shortSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for (idx,sort) in arrOfSorting.enumerated(){
            let action = UIAlertAction(title: sort, style: .default, handler: { (action) in
                print(self.arrOfSorting[idx])
                self.loadMore = LoadMore()
                self.sortStr = self.arrOfSorting[idx]
                if !self.isFromSaved{
                    self.searchJobResult()
                }else{
                    self.searchJobByID()
                }
            })
            shortSheet.addAction(action)
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        shortSheet.addAction(cancel)
        self.present(shortSheet, animated: true, completion: nil)
    }
}

//MARK: - Tableview Method
extension SearchResultVC{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrOfSearchedJob != nil{
            if arrOfSearchedJob.isEmpty{
                return 2
            }
            return arrOfSearchedJob.count + 1
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 218 * _widthRatio : 150 * _widthRatio
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchDetailCell") as! SearchJobCell
            cell.lblFromLocation.text = advanceSearch.sourceAddress!.formattedAddress
            cell.lblToLocation.text = advanceSearch.destAddress!.formattedAddress
            cell.lblAvilJobs.text = "\(totalCount) Available Jobs"
            return cell
        }else{
            if arrOfSearchedJob.isEmpty{
                let cell = tableView.dequeueReusableCell(withIdentifier: "noDataFoundCell") as! NOItemCell
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "jobCellNew") as! JobCell
                cell.prepareUIforJob(job: arrOfSearchedJob[indexPath.row - 1], type: .searchResult)
                if indexPath.row == arrOfSearchedJob.count - 1 && !loadMore.isLoading && !loadMore.isAllLoaded{
                    if !isFromSaved{
                        searchJobResult()
                    }else{
                        searchJobByID()
                    }
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.reuseIdentifier == "jobCellNew" {
            self.performSegue(withIdentifier: "jobDetailSegue", sender: arrOfSearchedJob[indexPath.row - 1].jobId)
        }
    }
}

//MARK: - API call
extension SearchResultVC{
    
    func searchJobResult(){
        var dict: [String: Any] = [:]
        dict = advanceSearch.getParamDict()
        dict["sortby"] = sortStr
        dict["limit"] = self.loadMore.limit
        dict["start"] = self.loadMore.offset
        
        if !referesh.isRefreshing && loadMore.index == 0{
            self.showCentralSpinner()
        }
        loadMore.isLoading = true
        KPWebCall.call.searchJob(param: dict) { (json, flag) in
            self.loadMore.isLoading = false
            self.hideCentralSpinner()
            self.referesh.endRefreshing()
            if flag == 200 {
                if let dict = json as? NSDictionary{
                    if let count = dict["total"] as? Int{
                        self.totalCount = count
                    }
                    self.searchId = dict.getStringValue(key: "search_id")
                    self.searchStatus = SearchStatus(str: dict.getStringValue(key: "filter_status"))
                    self.btnSave.isSelected = self.searchStatus == .saved
                    if let data = dict["data"] as? [NSDictionary]{
                        if self.loadMore.index == 0{
                            self.arrOfSearchedJob = []
                        }
                        for search in data{
                            self.arrOfSearchedJob.append(Job(dict: search))
                        }
                        if data.isEmpty{
                            self.loadMore.isAllLoaded = true
                        }else{
                            self.loadMore.index += 1
                        }
                    }
                    self.tableView.reloadData()
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
    
    func searchJobByID(){
        var dict : [String : Any] = [:]
        dict["search_id"] = advanceSearch.searchID
        dict["sortby"] = sortStr
        dict["limit"] = self.loadMore.limit
        dict["start"] = self.loadMore.offset
        
        if !referesh.isRefreshing && loadMore.index == 0{
            self.showCentralSpinner()
        }
        loadMore.isLoading = true
        KPWebCall.call.searchJobBysearchId(param: dict) { (json, flag) in
            self.loadMore.isLoading = false
            self.hideCentralSpinner()
            self.referesh.endRefreshing()
            if flag == 200 {
                if let dict = json as? NSDictionary{
                    if let count = dict["total"] as? Int{
                        self.totalCount = count
                    }
                    if let data = dict["data"] as? [NSDictionary]{
                        if self.loadMore.index == 0{
                            self.arrOfSearchedJob = []
                        }
                        for search in data{
                            self.arrOfSearchedJob.append(Job(dict: search))
                        }
                        if data.isEmpty{
                            self.loadMore.isAllLoaded = true
                        }else{
                            self.loadMore.index += 1
                        }
                        self.tableView.reloadData()
                    }
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
    
    func saveSearch(){        
        self.showCentralSpinner()
        KPWebCall.call.saveSearch(param: advanceSearch.getParamDict()) { (json, flag) in
            self.hideCentralSpinner()
            if flag == 200 {
                if let dict = json as? NSDictionary{
                    self.delegate?.updateSaveSearch(searchObj: nil)
                    if let dictData = dict["data"] as? NSDictionary {
                        self.advanceSearch.setSearchId(dict:dictData)
                        self.advanceSearch.searchStatus = .saved
                    }
                    self.btnSave.isSelected = self.advanceSearch.searchStatus == .saved
                    _ = ValidationToast.showStatusMessage(message: dict.getStringValue(key: "message"), yCord: _topMsgBarConstant, inView: self.view, withColor: UIColor.swdSuccessPopUp())
                    self.tableView.reloadData()
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
    
    func updateSaveStatus(id: String){
        
        let status = self.advanceSearch.searchStatus == .saved ? SearchStatus.unsaved : SearchStatus.saved

        var dictParam = [String:String]()
        dictParam["search_id"] = id
        dictParam["status"] = status.rawValue
        self.showCentralSpinner()
        KPWebCall.call.updateSaveSerach(param: dictParam) { (json, flag) in
            self.hideCentralSpinner()
            if flag == 200 {
//                self.delegate?.updateSaveSearch(searchObj: nil)
                self.updateBtnSaveStatus(status:status.rawValue)
                if let data = json as? NSDictionary{
                    _ = ValidationToast.showStatusMessage(message: data.getStringValue(key: "message"),yCord: _topMsgBarConstant,inView: self.view,withColor: UIColor.swdSuccessPopUp())
                    self.tableView.reloadData()
                }else{
                    self.showError(data: json, yPos: _topMsgBarConstant)
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
}

//if isFromSaved {
//    self.updateSaveStatus(id: advanceSearch.searchID!)
//} else {
//    if advanceSearch.searchID == nil || (advanceSearch.searchID?.isEmpty)! {
//        saveSearch()
//    } else {
//        self.updateSaveStatus(id: searchId)
//    }
//}
