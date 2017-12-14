
import UIKit

enum JobDetailCellType: String{
    case map         = "mapCell"
    case qrCode      = "qrCodeCell"
    case size        = "sizeCell"
    case timeCell    = "cellTime"
    case address     = "cellAddress"
    case addOffer    = "addOfferCell"
    case activity    = "activity"
    case userReqCell = "userRequestCell"
    case userActivity = "userActivityCell"
    case viewSwishr  = "viewSwishrs"
    case noSwishr    = "noSwishrs"
    case removeOffer = "removeOfferCell"
}

class JobDetailVC: ParentViewController {

    /// Variables
    var jobId: String!
    var job: Job!
    var proposeDate: Date?
    var cellTypes: [JobDetailCellType]!
    
    /// View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getJobDetail()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        _defaultCenter.removeObserver(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "swishdPointDetailSegue"{
            let dest = segue.destination as! SwishdPointDetailVC
            dest.pointId = sender as! String
        }else if segue.identifier == "swishrListSegue"{
            let dest = segue.destination as! SwisherListVC
            dest.job = self.job
        }else if segue.identifier == "jobActivitySegue"{
            let dest = segue.destination as! JobactivityVC
            dest.job = self.job
        }else if segue.identifier == "codeImgaePreview"{
            let vc = segue.destination as! QRCodeImageVC
            vc.code = job.displayCode
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

// MARK: - UI & Utility Related
extension JobDetailVC {

    func prepareUI() {
        _defaultCenter.addObserver(self, selector: #selector(self.scanCompleteObserver(noti:)), name: NSNotification.Name(rawValue: observerScanCompelte), object: nil)
        referesh.addTarget(self, action: #selector(refreshData(_:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(referesh)
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
        tableView.contentInset  = UIEdgeInsets(top: 5 * _widthRatio, left: 0, bottom: 10 * _widthRatio, right: 0)
    }
    
    @objc func refreshData(_ sender: UIRefreshControl) {
        getJobDetail()
    }
    
    func showEditJobPopup(){
        let editOptions = ["ITEM TITLE","ITEM SIZE","PICK UP LOCATION","DROP OFF LOCATION","PRICE"]
        let editView = HistroySortView.instantiateViewFromNib(withView: self.view, options: editOptions, title: "Edit item", selectdIdx: nil)
        editView.selectionBlock = {[unowned self](idx) -> () in
           kprint(items: "Edit \(editOptions[idx]) ")
        }
    }
    
    func showAcceptJobPopUp(){
        _ = AcceptJobPopup.instantiateAcceptJobPopupViewFromNib(withView: self.view, jobSender: job.sender!)
    }
    
    func prepareCellType()  {
        cellTypes = []
        if job.status == JobStatus.active{
            if let _ = job.displayCode{
                cellTypes.append(.qrCode)
            }
        }else if job.status == JobStatus.inProgress{
            if let _ = job.displayCode{
                cellTypes.append(.qrCode)
            }
        }else{
            cellTypes.append(.map)
        }
        cellTypes.append(.size)
        cellTypes.append(.timeCell)
        cellTypes.append(.address)
        if job.status != JobStatus.pending {
            if job.status != .completed{
                cellTypes.append(.userActivity)
                cellTypes.append(.activity)
            }
        }else{
            if job.isSentByMe{
                if job.jobRequestCount > 0{
                    cellTypes.append(.userReqCell)
                    cellTypes.append(.viewSwishr)
                }else{
                    cellTypes.append(.noSwishr)
                }
            }else{
                if job.isJobRequestSent{
                    cellTypes.append(.removeOffer)
                }else{
                    cellTypes.append(.addOffer)
                }
            }
        }
        tableView.reloadData()
    }
    
    @objc func scanCompleteObserver(noti: NSNotification) {
        if let dict = noti.userInfo as NSDictionary?{
            if dict.getStringValue(key: "jobId") == jobId{
                getJobDetail()
            }
        }
    }
}

// MARK: - Button Actions
extension JobDetailVC {

    @IBAction func btnViewSwishrsTap(_ sender: UIButton) {
        self.performSegue(withIdentifier: "swishrListSegue", sender: nil)
    }
    
    @IBAction func btnAcceptJobTap(_ sender: UIButton) {
        addJobOffer()
    }
    
    @IBAction func btnRemoveOfferTap(_ sender: UIButton) {
        removeJobOffer()
    }
    
    @IBAction func swishPointTap(_ sender: UIButton) {
        if sender.tag == 0{
            // From Point
            if let point = job.pickOffice{
                self.performSegue(withIdentifier: "swishdPointDetailSegue", sender: point.id)
            }
        }else{
            // To Point
            if let point = job.dropOffice{
                self.performSegue(withIdentifier: "swishdPointDetailSegue", sender: point.id)
            }
        }
    }
    
    @IBAction func btnProposeTimeTap(_ sender: UIButton) {
        let picker = KPDatePicker.instantiateViewFromNib(withView: self.view)
        if let date = job.pickDateTime{
            picker.datePicker.minimumDate = date
        }else{
            picker.datePicker.minimumDate = Date()
        }
        picker.datePicker.maximumDate = job.dropDateTime
        if let date = proposeDate{
            picker.datePicker.date = date
        }
        picker.selectionBlock = { [unowned self] (date) -> () in
            self.proposeDate = date
            self.tableView.reloadData()
            self.addJobOffer()
        }
    }
    
    @IBAction func btnActivityTap(_ sender: UIButton) {
        self.performSegue(withIdentifier: "jobActivitySegue", sender: nil)
    }
    
    @IBAction func btnQRCodeTap(_ sender: UIButton) {
        performSegue(withIdentifier: "codeImgaePreview", sender: nil)
//        let cell = tableView.cellForRow(at: IndexPath(item: 0, section: 0))!
//        let srcRect = cell.convert(sender.frame, to: self.view)
//        let prev = KPImagePreview(frame:_screenFrame, objs: [job.displayCode!.codeUrl] as [AnyObject],sourceRace: srcRect,selectedIndex: 0)
//        prev.scrollDirection = .vertical
//        prev.modalPresentationStyle = .overCurrentContext
//        prev.modalPresentationCapturesStatusBarAppearance = true
//        self.present(prev, animated: false, completion: nil)
    }
    
    @IBAction func btnEditJobTap(_ sender: UIButton){
        let popup = EditJobPopup.instantiateEditJobPopupViewFromNib(withView: self.view)
        popup.selectionBlock = {
            self.showEditJobPopup()
        }
    }
}

// MARK: - TableView Methods
extension JobDetailVC {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cellTypes != nil{
            return cellTypes.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch cellTypes[indexPath.row] {
        case .qrCode:
            return 290 * _widthRatio
        case .map:
            return 270 * _widthRatio
        case .size:
            return 125 * _widthRatio
        case .timeCell:
            return 115 * _widthRatio
        case .address:
//            let heightDrop = job.dropAddress.heightWithConstrainedWidth(width: _screenSize.width - 30, font: UIFont.avenirMedium(size: 15))
//            let heightPick = job.pickAddress.heightWithConstrainedWidth(width: _screenSize.width - 30, font: UIFont.avenirMedium(size: 15))
//            return heightDrop + heightPick + 155
            return 268 * _widthRatio
        case .userActivity, .userReqCell, .noSwishr:
            return 100 * _widthRatio
        case .addOffer, .removeOffer, .viewSwishr, .activity:
            return 65 * _widthRatio
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let tblCell = cell as! JobDetailCell
        
        switch cellTypes[indexPath.row] {
        case .map:
            tblCell.prepareMapUI(job: job)
            break
        case .size:
            tblCell.prepareSizeUI(job: job)
            break
        case .timeCell:
            tblCell.prepareTimeUI(job: job)
            break
        case .address:
            tblCell.prepareAddrUI(job: job)
            break
        case .addOffer:
            //tblCell.lblProposeTime.text = Date.getLocalString(from: proposeDate, format: "dd,MMM hh:mm a")
            break
        case .qrCode:
            tblCell.prepareQrCodeUI(job: job)
            break
        case .userActivity:
            tblCell.prepareActivityUI(job: job)
        case .userReqCell:
            tblCell.prepareOfferUI(job: job)
            break
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: JobDetailCell!
        cell = tableView.dequeueReusableCell(withIdentifier: cellTypes[indexPath.row].rawValue, for: indexPath) as! JobDetailCell
        return cell
    }
}

// MARK: - WebCall Methods
extension JobDetailVC {

    func getJobDetail() {
        if !referesh.isRefreshing{
            self.showCentralSpinner()
        }
        KPWebCall.call.getJobDetail(jobId: jobId) { (json, status) in
            self.hideCentralSpinner()
            self.referesh.endRefreshing()
            if status == 200{
                if let dict = (json as? NSDictionary)?["data"] as? NSDictionary{
                    self.job = Job(dict: dict)
                    self.prepareCellType()
                }
            }else{
                self.showError(data: json,yPos: _topMsgBarConstant)
            }
        }
    }
    
    func addJobOffer() {
        self.showCentralSpinner()
        let param: [String: Any]!
        if let date = proposeDate{
            param = ["sJobId": job.jobId, "dProposeDateTime": Date.getServerString(from: date)]
        }else{
            param = ["sJobId": job.jobId]
        }
        KPWebCall.call.addJobOffer(param: param) { (json, status) in
            self.hideCentralSpinner()
            if status == 200 {
                self.job.isJobRequestSent = true
                self.prepareCellType()
                self.showAcceptJobPopUp()
            }else{
                self.showError(data: json,yPos: _topMsgBarConstant)
            }
        }
    }
    
    func removeJobOffer() {
        self.showCentralSpinner()
        KPWebCall.call.cancelOffer(jId: job.jobId) { (json, status) in
            self.hideCentralSpinner()
            if status == 200{
                self.job.isJobRequestSent = false
                self.proposeDate = nil
                self.prepareCellType()
            }else{
                self.showError(data: json,yPos: _topMsgBarConstant)
            }
        }
    }
}
