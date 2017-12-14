

import UIKit

enum NotificationType: String{
    case newjob = "new_job"
    case swishrOffer = "swishr_offer"
    case offerAccept = "sendr_accept"
    case offerReject = "reject_sendr"
    case wallet = "wallet"
    case unknown = "unknown"
    
    init(str: String) {
        if let val = NotificationType(rawValue: str){
            self = val
        }else{
            self = .unknown
        }
    }
}

class NotificationList: NSObject {
    var id: String
    var message: String
    var jobId: String
    var status: String
    var type: NotificationType = NotificationType.unknown
    var date: Date?
    var user: OtherUser?
    
    init(dict: NSDictionary) {
        message = dict.getStringValue(key: "sDescription")
        date = Date.getDateFromServerFormat(from: dict.getStringValue(key: "dCreatedDate"))
        id = dict.getStringValue(key: "_id")
        jobId = dict.getStringValue(key: "sJobId")
        status = dict.getStringValue(key: "sStatus")
        type = NotificationType(str: dict.getStringValue(key: "sType"))
        if let otherUser = dict["user"] as? NSDictionary{
            user = OtherUser(swishrDict: otherUser)
        }
    }
}

class NotificationCell: ConstrainedTableViewCell{
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet var vwShadow: UIView!
    weak var parent: NotificationVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setShadow(height: CGFloat){
            let rect = CGRect(x: 0, y: 0, width: _screenSize.width - (20 * _widthRatio), height: height)
            vwShadow.layer.shadowPath = UIBezierPath(rect: rect).cgPath
    }
    
    func prepareUI(){
        lblMessage.text = parent.notificationList[tag].message
        lblTime.text = parent.notificationList[tag].date?.agoStringFromTime()
        if let user = parent.notificationList[tag].user{
            imgUserProfile.kf.setImage(with:user.imageUrl)
        }else{
            imgUserProfile.image = #imageLiteral(resourceName: "ic_round_swish_logo")
        }
        let strHeight = parent.notificationList[tag].message.heightWithConstrainedWidth(width: 279 * _widthRatio, font: UIFont.arialRegular(size: 16 * _widthRatio))
        setShadow(height: strHeight + 70 * _widthRatio)
    }

}

class NotificationVC: ParentViewController {
    
    /// variables
    var notificationList: [NotificationList]!
    var loadMore = LoadMore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getNotificationList()
        prepareUI()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - UI And Utility Related
extension NotificationVC{
    
    func prepareUI()  {
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
        tableView.contentInset  = UIEdgeInsets(top: 5 * _widthRatio, left: 0, bottom: 10 * _widthRatio, right: 0)
        referesh.addTarget(self, action: #selector(self.refreshData(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(referesh)
    }
    
    @objc func refreshData(sender: UIRefreshControl){
        loadMore = LoadMore()
        getNotificationList()
    }
    
    func redirectToDetails(notiObj: NotificationList){
        switch notiObj.type {
        case .newjob, .offerAccept, .offerReject, .swishrOffer:
            if let tab = self.tabBarController as? KPTabBarVC{
                tab.setSelectedTab(idx: 1)
            }
            let nav = self.tabBarController?.viewControllers?[1] as! UINavigationController
            let jobVc = UIStoryboard(name: "Job", bundle: nil).instantiateViewController(withIdentifier: "JobDetailVC") as! JobDetailVC
            jobVc.jobId = notiObj.jobId
            nav.pushViewController(jobVc, animated: true)
            break
        case .wallet:
            break
        default:
            break
        }
    }
}

// MARK: - Tableview method
extension NotificationVC{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if notificationList != nil{
            return notificationList.isEmpty ? 1 : notificationList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if notificationList.isEmpty{
            return 100 * _widthRatio
        }else{
            let strHeight = notificationList[indexPath.row].message.heightWithConstrainedWidth(width: 279 * _widthRatio, font: UIFont.arialRegular(size: 16 * _widthRatio))
            return  strHeight + 80 * _widthRatio
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if notificationList.isEmpty{
            let cell = tableView.dequeueReusableCell(withIdentifier: "noDataCell") as! NOItemCell
            cell.lblMessage.text  = "No notifications are available."
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCellNew") as! NotificationCell
            cell.parent = self
            cell.tag = indexPath.row
            cell.prepareUI()
            if indexPath.row == notificationList.count - 1 && !loadMore.isLoading && !loadMore.isAllLoaded{
                getNotificationList()
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        redirectToDetails(notiObj: notificationList[indexPath.row])
    }
}

// MARK: - Webcall method
extension NotificationVC{
    
    func getNotificationList(){
        let dict: [String : Any] = ["limit":self.loadMore.limit,"start": self.loadMore.offset]
        if !referesh.isRefreshing && loadMore.index == 0{
            self.showCentralSpinner()
        }
        
        loadMore.isLoading = true
        KPWebCall.call.getNotification(param: dict) { (json, flag) in
            self.hideCentralSpinner()
            self.loadMore.isLoading = false
            self.referesh.endRefreshing()
            if flag == 200 {
                if let list = (json as? NSDictionary)?["data"] as? [NSDictionary]{
                    if self.loadMore.index == 0{
                        self.notificationList = []
                    }
                    for notification in list{
                        self.notificationList.append(NotificationList(dict: notification))
                    }
                    if list.isEmpty{
                        self.loadMore.isAllLoaded = true
                    }else{
                        self.loadMore.index += 1
                    }
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
