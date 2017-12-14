

import UIKit
import MapKit

class SwishdPointCell: ConstrainedTableViewCell {
    
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblStatus: UILabel!
    @IBOutlet var lblDistance: UILabel!
    @IBOutlet var btnArrow: UIButton!
    @IBOutlet var lblSeparator: UILabel!
    
    @IBOutlet var lblDay: UILabel!
    @IBOutlet var lblTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class SwishdPointVC: ParentViewController {

    /// Variables
    var swishdPoints: [SwishdPoint]!
    var loadMore = LoadMore()
    var location: CLLocation?
    var isShortByDistance = true
    var openIndex: Set<Int> = []
    var selectionBlock: ((SwishdPoint) -> ())?
    
    /// View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getSwishdPoints()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

// MARK: - UI & Utility Methods
extension SwishdPointVC{

    func prepareUI()  {
        referesh.addTarget(self, action: #selector(self.refreshData(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(referesh)
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 10, right: 0)
    }
    
    @objc func refreshData(sender: UIRefreshControl)  {
        loadMore = LoadMore()
        openIndex = []
        location = nil
        getSwishdPoints()
    }
}

// MARK: - Button Actions
extension SwishdPointVC {

    @IBAction func btnSortByTap(_ sender: UIButton) {
        let action = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let distance = UIAlertAction(title: "Distance", style: UIAlertActionStyle.default) { (action) in
            self.isShortByDistance = true
            self.openIndex = []
            self.loadMore = LoadMore()
            self.getSwishdPoints()
        }
        let openNow = UIAlertAction(title: "Open Now", style: UIAlertActionStyle.default) { (action) in
            self.isShortByDistance = false
            self.openIndex = []
            self.loadMore = LoadMore()
            self.getSwishdPoints()
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        action.addAction(distance)
        action.addAction(openNow)
        action.addAction(cancel)
        self.present(action, animated: true, completion: nil)
    }
    
    @IBAction func btnHideShowTap(_ sender: UIButton) {
        if let idx = IndexPath.indexPathForCellContainingView(view: sender, inTableView: tableView){
            if openIndex.contains(idx.section){
                openIndex.remove(idx.section)
            }else{
                openIndex.insert(idx.section)
            }
            tableView.reloadData()
        }
    }
}

// MARK: - TableView Methods
extension SwishdPointVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if swishdPoints != nil{
            return swishdPoints.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if openIndex.contains(section){
            return swishdPoints[section].schedules.count + 1
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 65
        }else{
            return 25
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SwishdPointCell!
        let point = swishdPoints[indexPath.section]
        if indexPath.row == 0{
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SwishdPointCell
            cell.lblName.text = point.name
            cell.lblStatus.text = "Status: \(point.status.rawValue)"
            cell.lblDistance.text = "\(point.distance.getFormattedValue(str: "1")!) KM"
            cell.btnArrow.isSelected = openIndex.contains(indexPath.section)
            cell.lblSeparator.isHidden = openIndex.contains(indexPath.section)
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "cellOpenTime", for: indexPath) as! SwishdPointCell
            cell.lblDay.text = "\(point.schedules[indexPath.row - 1].dayString):"
            cell.lblTime.text = point.schedules[indexPath.row - 1].timeString
            cell.lblSeparator.isHidden = indexPath.row != point.schedules.count
        }
        if indexPath.section == swishdPoints.count - 1 && !loadMore.isLoading && !loadMore.isAllLoaded{
            getSwishdPoints()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.selectionBlock?(self.swishdPoints[indexPath.section])
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - WebCall methods
extension SwishdPointVC {

    func getSwishdPoints()  {
        if let _ = location{
            apiCall()
        }else{
            if !referesh.isRefreshing && loadMore.index == 0{
                self.showCentralSpinner()
            }
            weak var controller: UIViewController! = self
            UserLocation.sharedInstance.fetchUserLocationForOnce(controller: controller) { (location, error) in
                if let loc = location {
                    self.location = loc
                    self.apiCall()
                }else{
                    self.hideCentralSpinner()
                    self.referesh.endRefreshing()
                }
            }
        }
    }
    
    func apiCall()  {
        let param: [String: Any] = ["sortBy": isShortByDistance ? "distance" : "open","sLatitude": self.location!.coordinate.latitude, "sLongitude": self.location!.coordinate.longitude, "iStart": self.loadMore.offset, "iLimit": self.loadMore.limit]
        if !referesh.isRefreshing && loadMore.index == 0{
            self.showCentralSpinner()
        }
        loadMore.isLoading = true
        KPWebCall.call.getSwishedPoint(param: param) { (json, status) in
            self.loadMore.isLoading = false
            self.hideCentralSpinner()
            self.referesh.endRefreshing()
            if status == 200{
                if let dataArr = (json as? NSDictionary)?["detail"] as? [NSDictionary] {
                    if self.loadMore.index == 0{
                        self.swishdPoints = []
                    }
                    for dict in dataArr{
                        let point = SwishdPoint(dict: dict)
                        self.swishdPoints.append(point)
                    }
                    if dataArr.isEmpty{
                        self.loadMore.isAllLoaded = true
                    }else{
                        self.loadMore.index += 1
                    }
                    self.tableView.reloadData()
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
}
