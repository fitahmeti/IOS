
import UIKit

protocol PaymentDelegate: NSObjectProtocol {
    func paymentSuccess()
}

class SwisherListVC: ParentViewController {
    
    /// Variables
    var job: Job!
    var loadMore = LoadMore()
    var arrOfOffer: [JobOffer]!
    var sortBy: String = ""
    var offer: JobOffer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSwishrList()
        prepareUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "swisherProfileSegue"{
            let vc = segue.destination as! SwisherProfileVC
            let offer = sender as! JobOffer
            vc.delegate = self
            vc.swishrId = offer.userId
            vc.job = self.job
        }else if segue.identifier == "pickBySegue" {
            let vc = segue.destination as! RecipientsVC
            vc.swishrId = sender as! String
            vc.job = self.job
        }else if segue.identifier == "paymentSegue"{
            if let navVC = segue.destination as? KPNavigationViewController {
                if let paymentVC = navVC.viewControllers.first as? PaymentVC {
                    paymentVC.job = self.job
                    paymentVC.paymentDelegate = self
                }
            }
        }
    }
}

// MARK: - SwishrProfileDelegate, PaymentDelegate
extension SwisherListVC: SwishrProfileDelegate, PaymentDelegate{

    func rejectOffer(swishrId: String) {
        for swishr in arrOfOffer{
            if swishr.userId == swishrId{
                arrOfOffer.remove(object: swishr)
            }
            tableView.reloadData()
        }
    }
    
    func paymentSuccess() {
        self.performSegue(withIdentifier: "pickBySegue", sender: offer.userId)
    }
}

// MARK: - Button Action
extension SwisherListVC{
    
    @IBAction func acceptOffer(_ sender: UIButton){
        if let index = IndexPath.indexPathForCellContainingView(view: sender, inTableView: tableView) {
            offer = arrOfOffer[index.row - 1]
            let acceptPopup = AcceptOfferPopup.instantiateAcceptOfferViewFromNib(withView: self.view, offerImage: offer.imageUrl, offerName:offer.userName)
            acceptPopup.selectionBlock = {
                if _appDelegator.isPaymentAllow{
                    self.performSegue(withIdentifier: "paymentSegue", sender:self.offer.userId)
                }else{
                    self.performSegue(withIdentifier: "pickBySegue", sender: self.offer.userId)
                }
            }
        }
    }
    
    @IBAction func rejectOffer(_ sender: UIButton){
        showRejectPopup(index: sender.tag)
    }
    
    @IBAction func btnSortAction(_ sender: UIButton){
        let shortSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let dateAction = UIAlertAction(title: "Date/Time", style: .default, handler: { (action) in
            self.sortBy = "date"
            self.arrOfOffer.sort { $0.offerDate?.compare($1.offerDate!) == .orderedAscending }
            self.tableView.reloadData()
        })
        let offerAction = UIAlertAction(title: "Recent Offer", style: .default, handler: { (action) in
            self.sortBy = "recentoffer"
            self.arrOfOffer.sort { $0.proposedDate?.compare($1.proposedDate!) == .orderedDescending }
            self.tableView.reloadData()
        })
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        shortSheet.addAction(dateAction)
        shortSheet.addAction(offerAction)
        shortSheet.addAction(cancel)
        self.present(shortSheet, animated: true, completion: nil)
    }
}

// MARK: - UI And Utility Related
extension SwisherListVC{
    
    func prepareUI()  {
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
        tableView.contentInset  = UIEdgeInsets(top: 5 * _widthRatio, left: 0, bottom: 10 * _widthRatio, right: 0)
        referesh.addTarget(self, action: #selector(self.refreshData(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(referesh)
    }
    
    @objc func refreshData(sender: UIRefreshControl)  {
        loadMore = LoadMore()
        getSwishrList()
    }
}

//MARK: - TableView Method
extension SwisherListVC{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrOfOffer != nil{
            return arrOfOffer.count + 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 235 * _widthRatio
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "jobDetailCell") as! JobCell
            cell.prepareUIForSwishList(job: job)
            return cell
        }else{
            let jobOffer = arrOfOffer[indexPath.row - 1]
            let cell = tableView.dequeueReusableCell(withIdentifier: "offerListCell") as! OfferListCell
            cell.prepareVerifyUI(offer: jobOffer)
            if indexPath.row == arrOfOffer.count && !loadMore.isLoading && !loadMore.isAllLoaded {
                self.getSwishrList()
            }
            return cell
        }
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath)
//        if cell?.reuseIdentifier == "offerListCell"{
//            performSegue(withIdentifier: "swisherProfileSegue", sender: arrOfOffer[indexPath.row - 1])
//        }
//    }
}

// MARK: - Accept Reject Pop-up
extension SwisherListVC{
    
    func showRejectPopup(index: Int){
        let rejectPopup = UIAlertController(title: "Do you want to reject \(arrOfOffer[index].userName)'s offer?", message: nil, preferredStyle: .alert)
        
        let reject = UIAlertAction(title: "Reject", style: .destructive){ (action) in
            self.acceptRejectOffer(jobOffer: self.arrOfOffer[index], offerStatus: JobOfferStatus.reject)
            self.tableView.reloadData()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        rejectPopup.addAction(reject)
        rejectPopup.addAction(cancel)
        present(rejectPopup, animated: true, completion: nil)
    }
}

// MARK: - WebCall Methods
extension SwisherListVC {
    
    func getSwishrList() {
//        let dict = ["sJobId": job.jobId, "sortBy": sortBy]
        let dict:[String: Any] = ["sJobId": job.jobId, "iStart": loadMore.offset, "iLimit": loadMore.limit]
        if !referesh.isRefreshing && loadMore.index == 0{
            self.showCentralSpinner()
        }
        self.loadMore.isLoading = true
        KPWebCall.call.getOfferJobList(param: dict){ (json, status) in
            self.loadMore.isLoading = false
            self.hideCentralSpinner()
            self.referesh.endRefreshing()
            if status == 200{
                if let offerList = (json as? NSDictionary)?["data"] as? [NSDictionary]{
                    if self.loadMore.index == 0{
                        self.arrOfOffer = []
                    }
                    for offer in offerList{
                        self.arrOfOffer.append(JobOffer(dict: offer))
                    }
                    if !offerList.isEmpty {
                        self.loadMore.index += 1
                    }else{
                        self.loadMore.isAllLoaded = true
                    }
                    self.tableView.reloadData()
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
    
    func acceptRejectOffer(jobOffer: JobOffer, offerStatus: JobOfferStatus){
        var dict: [String: Any] = [:]
        dict["sJobId"] = job.jobId
        dict["sUserId"] = jobOffer.userId
        dict["eOfferStatus"] = offerStatus.rawValue
        
        self.showCentralSpinner()
        KPWebCall.call.respondToOffer(param: dict){ (json, status) in
            self.hideCentralSpinner()
            if status == 200{
                if let _ = json as? NSDictionary{
                    self.arrOfOffer.remove(object: jobOffer)
                    self.tableView.reloadData()
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
}
