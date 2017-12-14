

import UIKit
import MapKit

class SearchJobCell : ConstrainedTableViewCell{
    @IBOutlet weak var tfFrom : UITextField!
    @IBOutlet weak var tfTo : UITextField!
    
    @IBOutlet weak var viewSave: UIView!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet var lblSavedCount: UILabel!
    
    // Saved search
    @IBOutlet weak var lblFromLocation: UILabel!
    @IBOutlet weak var lblToLocation: UILabel!
    @IBOutlet weak var btnSaveList: UIButton!
    @IBOutlet var btnMonday: UIButton!
    @IBOutlet var btnTuesday: UIButton!
    @IBOutlet var btnWenday: UIButton!
    @IBOutlet var btnThursday: UIButton!
    @IBOutlet var btnFriday: UIButton!
    @IBOutlet var btnSaturday: UIButton!
    @IBOutlet var btnSunday: UIButton!
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var vwEveryday: UIView!
    
    // Serach Result
    @IBOutlet weak var lblAvilJobs: UILabel!

    weak var parent : HomeVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareSerachUI(){
        let search = parent.arrOfSearch.first!
        lblSavedCount.text = "\(parent.arrOfSearch.count)"
        lblFromLocation.text = search.sourceAddress?.formattedAddress
        lblToLocation.text = search.destAddress?.formattedAddress
    }
    
    func prepareAdvanceSearchUI(){
        prepareSerachUI()
        let search = parent.arrOfSearch.first!
        vwEveryday.isHidden = true
        if let date = search.specificDate{
            lblDate.text = Date.getLocalString(from: date, format: "dd.MMM yyyy")
        }else if search.isAnytime{
            lblDate.text = "Anytime"
        }else{
            lblDate.isHidden = true
            if !search.everyDay.isEmpty{
                vwEveryday.isHidden = false
                for day in search.everyDay{
                    switch day {
                    case .monday:
                        btnMonday.isSelected = true
                    case .tuesday:
                        btnTuesday.isSelected = true
                    case .wednesDay:
                        btnWenday.isSelected = true
                    case .thursday:
                        btnThursday.isSelected = true
                    case .friday:
                        btnFriday.isSelected = true
                    case .saturday:
                        btnSaturday.isSelected = true
                    case .sunday:
                        btnSunday.isSelected = true
                    case .all:
                        btnMonday.isSelected = true
                        btnTuesday.isSelected = true
                        btnWenday.isSelected = true
                        btnThursday.isSelected = true
                        btnFriday.isSelected = true
                        btnSaturday.isSelected = true
                        btnSunday.isSelected = true
                    default:
                        kprint(items: "Unknown")
                    }
                }
            }
        }
    }
}

class HomeVC: ParentViewController {
    
    /// Variables
    var arrOfSuggestedJob : [Job]!
    var arrOfSearch = [Search]()
    var loadMore = LoadMore()
    var userLocation : CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserLocation()
        getSavedSearch()
        prepareUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchSegue"{
            let vc = segue.destination as! SerchVC
            vc.delegate = self
            if let btn = sender as? Button{
                vc.index = btn.tag
            }
        }else if segue.identifier == "savedSerchSegue"{
            let vc = segue.destination as! SavedSerchVC
            vc.delegate = self
        }else if segue.identifier == "jobDetailSegue"{
            let dest = segue.destination as! JobDetailVC
            dest.jobId = sender as! String
        }
    }
}

// MARK: - UI And Utility Related
extension HomeVC{

    func prepareUI()  {
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
        tableView.register(UINib.init(nibName: "Job_newCell", bundle: nil), forCellReuseIdentifier: "jobCellNew")
        tableView.register(UINib(nibName: "SearchCell", bundle: nil), forCellReuseIdentifier: "searchCell")
        referesh.addTarget(self, action: #selector(self.refreshData(sender:)), for: .valueChanged)
        tableView.addSubview(referesh)
        tableView.contentInset  = UIEdgeInsets(top: 5 * _widthRatio, left: 0, bottom: 10 * _widthRatio, right: 0)
        
        // Headerview
        let header = UINib(nibName: "HeaderView", bundle: nil)
        tableView.register(header, forHeaderFooterViewReuseIdentifier: "HeaderView")
    }
    
    @objc func refreshData(sender: UIRefreshControl)  {
        loadMore = LoadMore()
        if userLocation != nil{
            getsuggestedJob(location: userLocation)
        }else{
            fetchUserLocation()
        }
    }
}

//MARK: - Button Action
extension HomeVC{
    
    @IBAction func btnFromToAction(_ sender : UIButton){
        self.performSegue(withIdentifier: "searchSegue", sender: sender)
    }
    
    @IBAction func btnSavedSerchAction(_ sender : UIButton){
        if arrOfSearch.count == 0{
            performSegue(withIdentifier: "searchSegue", sender: sender)
        }else{
            performSegue(withIdentifier: "savedSerchSegue", sender: arrOfSearch)
        }
    }
    
}

//MARK:- Tableview Method
extension HomeVC{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else if arrOfSuggestedJob != nil{
            if arrOfSuggestedJob.isEmpty{
                return 1
            }
            return arrOfSuggestedJob.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            if !arrOfSearch.isEmpty && arrOfSearch.first!.specificDate == nil && !arrOfSearch.first!.isAnytime && arrOfSearch.first!.everyDay.isEmpty{
                return 250 * _widthRatio
            }else{
               return 272 * _widthRatio
            }
        }else{
            return 150 * _widthRatio
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 55 * _widthRatio
        }else{
            return CGFloat.leastNonzeroMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1{
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView") as! HeaderView
            header.lblText.text = "SUGGESTED JOBS FOR YOU"
            return header
        }else{
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            if arrOfSearch.isEmpty{
                let cell = tableView.dequeueReusableCell(withIdentifier: "searchJobCell") as! SearchJobCell
                return cell
            }else{
                let search = arrOfSearch.first!
                if search.specificDate == nil && !search.isAnytime && search.everyDay.isEmpty{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "noAdvanceSearchCell") as! SearchJobCell
                    cell.parent = self
                    cell.prepareSerachUI()
                    return cell
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "searchAdvanceCell") as! SearchJobCell
                    cell.parent = self
                    cell.prepareAdvanceSearchUI()
                    return cell
                }
            }
        }else {
            if arrOfSuggestedJob.isEmpty{
                let cell = tableView.dequeueReusableCell(withIdentifier: "noDataFoundCell") as! NOItemCell
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "jobCellNew") as! JobCell
                cell.prepareUIforJob(job: arrOfSuggestedJob[indexPath.row], type: .search)
                if indexPath.row == arrOfSuggestedJob.count - 1 && !loadMore.isLoading && !loadMore.isAllLoaded{
                    getsuggestedJob(location: userLocation)
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return indexPath.section == 1 && !arrOfSuggestedJob.isEmpty ? true : false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.hideSuggestionjob(job: arrOfSuggestedJob[indexPath.row], index: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.reuseIdentifier == "jobCellNew"{
            self.performSegue(withIdentifier: "jobDetailSegue", sender: arrOfSuggestedJob[indexPath.row].jobId)
        }
    }
}

//MARK: - API call
extension HomeVC{
    
    func fetchUserLocation(){
        weak var controller: UIViewController! = self
        UserLocation.sharedInstance.fetchUserLocationForOnce(controller: controller) { (location, error) in
            if let loc = location {
                self.userLocation = loc
                self.getsuggestedJob(location: loc)
            }else{
                self.hideCentralSpinner()
            }
        }
    }
    
    func getsuggestedJob(location : CLLocation){
        let dict : [String : Any] = ["source_latitude":location.coordinate.latitude,"source_longitude":location.coordinate.longitude ,"limit":self.loadMore.limit,"start": self.loadMore.offset]
        
        if !referesh.isRefreshing && loadMore.index == 0{
            self.showCentralSpinner()
        }
        loadMore.isLoading = true
        KPWebCall.call.searchJob(param: dict) { (json, flag) in
            self.loadMore.isLoading = false
            self.referesh.endRefreshing()
            self.hideCentralSpinner()
            if flag == 200 {
                if let data = (json as? NSDictionary)?["data"] as? [NSDictionary] {
                    if self.loadMore.index == 0 {
                        self.arrOfSuggestedJob = []
                    }
                    for search in data {
                        self.arrOfSuggestedJob.append(Job(dict: search))
                    }
                    if data.isEmpty {
                        self.loadMore.isAllLoaded = true
                    }else{
                        self.loadMore.index += 1
                    }
                    self.tableView.reloadData()
                }else {
                    self.showError(data: json, yPos: _topMsgBarConstant)
                }
            }else {
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
    
    func getSavedSearch() {
        KPWebCall.call.getSavedSerachList(param: [:]) { (json, flag) in
            if flag == 200 {
                if let dict = json as? NSDictionary{
                    if let searchList = dict["data"] as? [NSDictionary]{
                        self.arrOfSearch = []
                        for search in searchList{
                            self.arrOfSearch.append(Search(dict: search))
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
    
    func hideSuggestionjob(job: Job, index: Int){
        self.showCentralSpinner()
        KPWebCall.call.hideSuggestedJob(jobID: job.jobId) { (json, flag) in
            self.hideCentralSpinner()
            if flag == 200 {
                if let dict = json as? NSDictionary{
                    kprint(items: dict)
                   self.arrOfSuggestedJob.remove(at: index)
                   self.tableView.reloadData()
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
    
}

//MARK: - CallBack(s)
extension HomeVC: SavedSearchDelegate {
    
    func updateSaveSearch(searchObj: Search?){
        getSavedSearch()
    }
}
