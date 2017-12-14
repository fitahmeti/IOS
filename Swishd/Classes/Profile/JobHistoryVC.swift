
import UIKit

enum SortBy: String{
    case date = "date"
    case price = "price"
}

class JobHistoryVC: ParentViewController, UITextFieldDelegate {
    
    // Outlets
    @IBOutlet weak var tfSearch: UITextField!
    
    /// Variables
    var sortBy = SortBy.date
    var jobType = JobType.swishr
    var swishrSearch = ""
    var sendrSearch = ""
    var loadMoreSender = LoadMore()
    var loadMoreSwishr = LoadMore()
    var senderJobs:[Job]!
    var swishrJobs:[Job]!
    
    /// View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        prepareSegmentData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "jobDetailSegue"{
            let dest = segue.destination as! JobDetailVC
            dest.jobId = sender as! String
        }
    }
}

// MARK: - UI & Utility Related
extension JobHistoryVC  {
    
    func prepareUI() {
        tfSearch.returnKeyType = .search
        tfSearch.tintColor = UIColor.swdBlueColor()
        tfSearch.clearButtonMode = .always
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
        tableView.contentInset  = UIEdgeInsets(top: 5 * _widthRatio, left: 0, bottom: 10 * _widthRatio, right: 0)
        referesh.addTarget(self, action: #selector(self.refreshData(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(referesh)
        tableView.register(UINib.init(nibName: "Job_status_Cell", bundle: nil), forCellReuseIdentifier: "jobStatusCell")
        
        // Headerview
        let headerVw = UINib(nibName: "ProfileHeaderView", bundle: nil)
        tableView.register(headerVw, forHeaderFooterViewReuseIdentifier: "histroyHeader")
    }
    
    func prepareSegmentData() {
        if jobType == .sender{
            if senderJobs == nil{
                getSenderJobs(str: sendrSearch)
            }
        }else{
            if swishrJobs == nil{
                getSwishrJobs(str: swishrSearch)
            }
        }
        tableView.reloadData()
    }
    
    @objc func refreshData(sender: UIRefreshControl) {
        getJobs()
    }
    
    func sortByAPI() {
        self.loadMoreSender = LoadMore()
        senderJobs = nil
        self.loadMoreSwishr = LoadMore()
        swishrJobs = nil
        prepareSegmentData()
    }
    
    func getJobs(){
        if jobType == .sender{
            loadMoreSender = LoadMore()
            getSenderJobs(str: sendrSearch)
        }else{
            loadMoreSwishr = LoadMore()
            getSwishrJobs(str: swishrSearch)
        }
    }
}

// MARK: - Button Actions
extension JobHistoryVC{
    
    @IBAction func btnSortByTap(_ sender: UIButton) {
        self.view.endEditing(true)
        let sortView = HistroySortView.instantiateViewFromNib(withView: self.view, options: ["DELIVERED BY", "PRICE"], title: "Sort by", selectdIdx: sortBy == .date ? 0 : 1)
        sortView.selectionBlock = {[unowned self](idx) -> () in
//            self.sortBy = idx == 0 ? .date : .price
            if idx == 0 && self.sortBy != .date{
                self.sortBy = .date
                self.sortByAPI()
            }else if idx == 1 && self.sortBy != .price{
                self.sortBy = .price
                self.sortByAPI()
            }
        }
    }
    
    @IBAction func btnSenderSwishrAction(_ sender: UIButton) {
        if sender.tag == 0{
            jobType = .swishr
            tfSearch.text = swishrSearch
        }else{
            jobType = .sender
            tfSearch.text = sendrSearch
        }
        prepareSegmentData()
    }
}

// MARK: - Textfield Delegate
extension JobHistoryVC{
    
    @IBAction func textChanged(_ sender: UITextField) {
        if (sender.text?.count)! > 0{
            if jobType == .swishr{
                swishrSearch = sender.text!
            }else{
                sendrSearch = sender.text!
            }
        }else{
            swishrSearch = ""
            sendrSearch = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tfSearch.resignFirstResponder()
        getJobs()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = ""
        swishrSearch = ""
        sendrSearch = ""
        getJobs()
        return false
    }
}

//MARK:- UITableviewDelegate
extension JobHistoryVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if jobType == .swishr{
            if swishrJobs != nil{
                return swishrJobs.isEmpty ? 1 : swishrJobs.count
            }
        }else{
            if senderJobs != nil{
                return senderJobs.isEmpty ? 1 : senderJobs.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if jobType == .swishr{
            if swishrJobs != nil{
                return swishrJobs.isEmpty ? 150 * _widthRatio : 187 * _widthRatio
            }
        }else{
            if senderJobs != nil{
                return senderJobs.isEmpty ? 150 * _widthRatio : 187 * _widthRatio
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60 * _widthRatio
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "histroyHeader") as! HeaderView
        header.historyParent = self
        header.prepareUI(type: .history)
        return header
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if jobType == .sender{
            if senderJobs.isEmpty{
                let cell = tableView.dequeueReusableCell(withIdentifier: "noItemCell", for: indexPath) as! NOItemCell
                cell.lblMessage.text = "You have no sent item in history"
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "jobStatusCell", for: indexPath) as! JobCell
                cell.prepareUIforJob(job: senderJobs[indexPath.row], type: .senderHistory)
                if indexPath.row == senderJobs.count - 1 && !loadMoreSender.isLoading && !loadMoreSender.isAllLoaded{
                    getSenderJobs(str: sendrSearch)
                }
                return cell
            }
        }else{
            if swishrJobs.isEmpty{
                let cell = tableView.dequeueReusableCell(withIdentifier: "noItemCell", for: indexPath) as! NOItemCell
                cell.lblMessage.text = "You have no swishd item in history"
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "jobStatusCell", for: indexPath) as! JobCell
                cell.prepareUIforJob(job: swishrJobs[indexPath.row], type: .swishrHistory)
                if indexPath.row == swishrJobs.count - 1 && !loadMoreSwishr.isLoading && !loadMoreSwishr.isAllLoaded{
                    getSwishrJobs(str: swishrSearch)
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.reuseIdentifier == "jobStatusCell"{
            if jobType == .sender{
                self.performSegue(withIdentifier: "jobDetailSegue", sender: senderJobs[indexPath.row].jobId)
            }else{
                self.performSegue(withIdentifier: "jobDetailSegue", sender: swishrJobs[indexPath.row].jobId)
            }
        }
    }
}

// MARK: - WebCall Methods
extension JobHistoryVC {
    
    func getSenderJobs(str: String) {
        if loadMoreSender.index == 0 && !referesh.isRefreshing{
            self.showCentralSpinner()
        }
        self.loadMoreSender.isLoading = true
        KPWebCall.call.getSenderJob(offSet: loadMoreSender.offset, limit: loadMoreSender.limit, status: "complete", searchStr: str, sortBy: sortBy.rawValue) { (json, status) in
            self.loadMoreSender.isLoading = false
            self.hideCentralSpinner()
            self.referesh.endRefreshing()
            if status == 200{
                if let dataArr = (json as? NSDictionary)?["data"] as? [NSDictionary]{
                    if self.loadMoreSender.index == 0{
                        self.senderJobs = []
                    }
                    for dict in dataArr{
                        let job = Job(dict: dict)
                        self.senderJobs.append(job)
                    }
                    if dataArr.isEmpty{
                        self.loadMoreSender.isAllLoaded = true
                    }else{
                        self.loadMoreSender.index += 1
                    }
                    self.tableView.reloadData()
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
    
    func getSwishrJobs(str: String) {
        if loadMoreSwishr.index == 0 && !referesh.isRefreshing{
            self.showCentralSpinner()
        }
        self.loadMoreSwishr.isLoading = true
        KPWebCall.call.getSwishrJob(offSet: loadMoreSwishr.offset, limit: loadMoreSwishr.limit, status: "complete", sortBy: sortBy.rawValue, searchStr: str) { (json, status) in
            self.loadMoreSwishr.isLoading = false
            self.hideCentralSpinner()
            self.referesh.endRefreshing()
            if status == 200{
                if let dataArr = (json as? NSDictionary)?["data"] as? [NSDictionary]{
                    if self.loadMoreSwishr.index == 0{
                        self.swishrJobs = []
                    }
                    for dict in dataArr{
                        let job = Job(dict: dict)
                        self.swishrJobs.append(job)
                    }
                    if dataArr.isEmpty{
                        self.loadMoreSwishr.isAllLoaded = true
                    }else{
                        self.loadMoreSwishr.index += 1
                    }
                    self.tableView.reloadData()
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
}
