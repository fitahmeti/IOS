

import UIKit

enum JobType {
    case swishr
    case sender
}

class SenderJobSection {
    let order: Int
    let jobs: [Job]
    
    init(seq: Int, jobArr: [Job]) {
        order = seq
        jobs = jobArr
    }
}

class ProfileVC: SocialViewController, EditProfileDelegate{

    /// Variables
    var jobType = JobType.swishr
    var loadMoreSender = LoadMore()
    var loadMoreSwishr = LoadMore()
    var senderSectionJobs: [SenderJobSection] = []
    var senderJobs:[Job]!
    var swishrJobs:[Job]!
    var senderCount: Int = 0
    var swishrCount: Int = 0
    var isShowVerification: Bool = false
    
    /// View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        prepareSegmentData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    deinit {
        _defaultCenter.removeObserver(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "jobDetailSegue"{
            let dest = segue.destination as! JobDetailVC
            dest.jobId = sender as! String
        }else if segue.identifier == "editProfileSegue"{
            let vc = segue.destination as! EditProfileVC
            vc.delegate = self
        }
    }
}

// MARK: - UI & Utility Related
extension ProfileVC  {
    
    func prepareUI() {
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
        tableView.contentInset  = UIEdgeInsets(top: 5 * _widthRatio, left: 0, bottom: 10 * _widthRatio, right: 0)
        referesh.addTarget(self, action: #selector(self.refreshData(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(referesh)
        tableView.register(UINib.init(nibName: "Job_newCell", bundle: nil), forCellReuseIdentifier: "jobCellNew")
        tableView.register(UINib.init(nibName: "Job_status_Cell", bundle: nil), forCellReuseIdentifier: "jobStatusCell")

        // Headerview
        let headerVw = UINib(nibName: "ProfileHeaderView", bundle: nil)
        tableView.register(headerVw, forHeaderFooterViewReuseIdentifier: "profileHeader")
        tableView.register(UINib(nibName: "JobSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "jobHeaderView")
    }
    
    func editProfile() {
        tableView.reloadData()
    }
    
    func prepareSegmentData() {
        if jobType == .sender{
            if senderJobs == nil{
                getSenderJobs()
            }
        }else{
            if swishrJobs == nil{
                getSwishrJobs()
            }
        }
        tableView.reloadData()
    }
    
    @objc func refreshData(sender: UIRefreshControl) {
        if jobType == .sender{
            loadMoreSender = LoadMore()
            getSenderJobs()
        }else{
            loadMoreSwishr = LoadMore()
            getSwishrJobs()
        }
    }
    
    func connectToFb(){
        connectToFacebook()
    }
    
    func connectWithGoogle(){
        connectToGoogle()
    }
    
    func connectwithLinkdIn(){
        connectWithLinkdin()
    }
}

// MARK: - Add Job
extension ProfileVC{

    func addNewJob(job: Job) {
        jobType = .sender
        if senderJobs != nil{
            senderCount += 1
            senderJobs.append(job)
            prepareSectionArray()
        }else{
            prepareSegmentData()
        }
    }
}

// MARK: - Button Actions
extension ProfileVC {

    @IBAction func btnEditAction(_ sender : UIButton){
        performSegue(withIdentifier: "editProfileSegue", sender: nil)
    }
    
    @IBAction func btnSettingAction(_ sender: UIButton){
        let storyBoard = UIStoryboard.init(name: "Setting", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnVerifyAction(_ sender: UIButton){
        switch sender.tag {
        case 1:
            if !_user.isMobileVerify{
                performSegue(withIdentifier: "mobileVFSegue", sender: nil)
            }
        case 2:
            if !_user.isFbVerify{
                connectToFb()
            }
        case 3:
            if !_user.isLinkdinVerify{
                connectwithLinkdIn()
            }
        case 4:
            if !_user.isProofVerify{
                if !_user.proofId.isEmpty{
                    performSegue(withIdentifier: "verifyCodeSegue", sender: nil)
                }else{
                    performSegue(withIdentifier: "uploadIdSegue", sender: nil)
                }
            }
        default:
            break
        }
    }
    
    @IBAction func btnSenderSwishrAction(_ sender: UIButton) {
        if sender.tag == 0{
            jobType = .swishr
        }else{
            jobType = .sender
        }
        prepareSegmentData()
    }
    
    @IBAction func btnWalletAmountAction(_ sender: UIButton){
       let storyboard = UIStoryboard(name: "Wallet", bundle: nil)
       let vc = storyboard.instantiateViewController(withIdentifier: "WalletDetailVC") as! WalletDetailVC
        navigationController?.pushViewController(vc, animated: true)        
    }
    
    @IBAction func jobHistoryTap(_ sender: UIButton) {
        self.performSegue(withIdentifier: "jobHistotySegue", sender: nil)
    }
    
    @IBAction func btnShowVerificationAction(_ sender : UIButton){
        isShowVerification = !isShowVerification
        tableView.reloadData()
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ProfileCell
        cell.resetShadow()
    }
    
    @IBAction func btnShareJobAction(_ sender: UIButton){
        kprint(items: "Share Job")
    }
}

//MARK:- UITableviewDelegate
extension ProfileVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if jobType == .sender{
            return 2 + senderSectionJobs.count
        }else{
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else{
            if jobType == .sender{
                if senderJobs != nil{
                    if section == 1{
                        if senderJobs.isEmpty{
                            return 1
                        }
                        return 0
                    }
                    return senderSectionJobs[section - 2].jobs.count
                }
            }else{
                if swishrJobs != nil{
                    return swishrJobs.isEmpty ? 1 : swishrJobs.count
                }
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return isShowVerification ? 365 * _widthRatio : 272 * _widthRatio
        } else {
            if jobType == .sender{
               return 150 * _widthRatio
            }else{
               return 150 * _widthRatio
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return CGFloat.leastNonzeroMagnitude
        }else if section == 1 {
            return 60 * _widthRatio
        }else{
            return 40 * _widthRatio
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0{
            return CGFloat.leastNonzeroMagnitude
        }else {
            if jobType == .swishr{
                if section == 1 {
                    return 80 * _widthRatio
                }else{
                    return CGFloat.leastNonzeroMagnitude
                }
            }else{
                if section == senderSectionJobs.count + 1 {
                    return 80 * _widthRatio
                }else{
                    return CGFloat.leastNonzeroMagnitude
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            return nil
        }else if section == 1{
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "profileHeader") as! HeaderView
            header.parent = self
            header.prepareUI(type: .profile)
            return header
        }else{
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "jobHeaderView") as! HeaderView
            header.parent = self
            header.prepareUIForJobStatusHeader(seq: senderSectionJobs[section - 2].order)
            return header
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if jobType == .swishr{
            if section == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellHistoryBtn")
                return cell
            }
        }else{
            if section == senderSectionJobs.count + 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellHistoryBtn")
                return cell
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! ProfileCell
            cell.parent = self
            cell.prepareVerifyUI()
            cell.prepareUI()
            return cell
        }else {
            if jobType == .sender{
                if senderJobs.isEmpty{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "noItemCell", for: indexPath) as! NOItemCell
                    cell.lblMessage.text = "You have no items being sent currently."
                    return cell
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "jobCellNew", for: indexPath) as! JobCell
                    cell.parent = self
                    cell.prepareUIforJob(job: senderSectionJobs[indexPath.section - 2].jobs[indexPath.row], type: .sender)
                    if indexPath.section == senderSectionJobs.count + 1 && indexPath.row == senderSectionJobs[indexPath.section - 2].jobs.count  - 1 && !loadMoreSender.isLoading && !loadMoreSender.isAllLoaded{
                        getSenderJobs()
                    }
                    return cell
                }
            }else{
                if swishrJobs.isEmpty{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "noItemCell", for: indexPath) as! NOItemCell
                    cell.lblMessage.text = "You have no items being swishd currently."
                    return cell
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "jobCellNew", for: indexPath) as! JobCell
                    cell.prepareUIforJob(job: swishrJobs[indexPath.row], type: .swishr)
                    if indexPath.row == swishrJobs.count - 1 && !loadMoreSwishr.isLoading && !loadMoreSwishr.isAllLoaded{
                        getSwishrJobs()
                    }
                    return cell
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.reuseIdentifier == "jobCellNew" || cell?.reuseIdentifier == "jobStatusCell"{
            if jobType == .sender{
                self.performSegue(withIdentifier: "jobDetailSegue", sender: senderSectionJobs[indexPath.section - 2].jobs[indexPath.row].jobId)
            }else{
                self.performSegue(withIdentifier: "jobDetailSegue", sender: swishrJobs[indexPath.row].jobId)
            }
        }
    }
}

// MARK: - WebCall Methods
extension ProfileVC {

    func getSenderJobs() {
        if loadMoreSender.index == 0 && !referesh.isRefreshing{
            self.showCentralSpinner()
        }
        self.loadMoreSender.isLoading = true
        KPWebCall.call.getSenderJob(offSet: loadMoreSender.offset, limit: loadMoreSender.limit, status: nil, searchStr: "", sortBy: "date") { (json, status) in
            self.loadMoreSender.isLoading = false
            self.hideCentralSpinner()
            self.referesh.endRefreshing()
            if status == 200{
                if let dataArr = (json as? NSDictionary)?["data"] as? [NSDictionary]{
                    self.senderCount  = (json as! NSDictionary).getIntValue(key: "totalCount")
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
                    self.prepareSectionArray()
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
    
    func prepareSectionArray() {
        guard senderJobs != nil else {
            self.tableView.reloadData()
            return
        }
        
        senderSectionJobs = []
        let active = senderJobs.filter { (job) -> Bool in
            return job.order == 1
        }
        let choseSwishr = senderJobs.filter { (job) -> Bool in
            return job.order == 2
        }
        let waitingSwishr = senderJobs.filter { (job) -> Bool in
            return job.order == 3
        }
        
        if !active.isEmpty{
            senderSectionJobs.append(SenderJobSection(seq: 1, jobArr: active))
        }
        
        if !choseSwishr.isEmpty{
            senderSectionJobs.append(SenderJobSection(seq: 2, jobArr: choseSwishr))
        }
        
        if !waitingSwishr.isEmpty{
            senderSectionJobs.append(SenderJobSection(seq: 3, jobArr: waitingSwishr))
        }
        self.tableView.reloadData()
    }
    
    func getSwishrJobs() {
        if loadMoreSwishr.index == 0 && !referesh.isRefreshing{
            self.showCentralSpinner()
        }
        self.loadMoreSwishr.isLoading = true
        KPWebCall.call.getSwishrJob(offSet: loadMoreSwishr.offset, limit: loadMoreSwishr.limit, status: nil, sortBy: "date", searchStr: "") { (json, status) in
            self.loadMoreSwishr.isLoading = false
            self.hideCentralSpinner()
            self.referesh.endRefreshing()
            if status == 200{
                if let dataArr = (json as? NSDictionary)?["data"] as? [NSDictionary]{
                    self.swishrCount  = (json as! NSDictionary).getIntValue(key: "totalCount")
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
