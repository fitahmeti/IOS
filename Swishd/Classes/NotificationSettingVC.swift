

import UIKit

enum NotiType: String{
    case push = "push"
    case message = "message"
    case email = "email"
}

class NotificationSettingCell: ConstrainedTableViewCell{
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var swNotification: UISwitch!
    weak var parent: NotificationSettingVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class NotificationSettingVC: ParentViewController {
    
    /// Variables
    var arrOfNoti = ["Alerts for new job","Complete wallet payment","Offers from swishers","Rejected offer from sender"]
    var notifiactions: [NotificationSection]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getNotificationSetting()
        prepareUI()
    }
}

//MARK: - Button Action
extension NotificationSettingVC{
    
    @IBAction func swichChanged(_ sender: UISwitch){
        if let index = IndexPath.indexPathForCellContainingView(view: sender, inTableView: tableView){
            kprint(items: index)
            notifiactions[index.section].arrNotificationSetting[index.row].status = !notifiactions[index.section].arrNotificationSetting[index.row].status
            tableView.reloadData()
            updateNotiSetting(objNotification: notifiactions[index.section].arrNotificationSetting[index.row])
        }
    }
}

// MARK: - UI And Utility Related
extension NotificationSettingVC{
    
    func prepareUI()  {
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
        tableView.contentInset  = UIEdgeInsets(top: 0, left: 0, bottom: 15 * _widthRatio, right: 0)
        referesh.addTarget(self, action: #selector(self.refreshData(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(referesh)
    }
    
    @objc func refreshData(sender: UIRefreshControl)  {
        getNotificationSetting()
    }
}

//MARK: - TableView method
extension NotificationSettingVC{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if notifiactions != nil{
            return notifiactions.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifiactions[section].arrNotificationSetting.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableCell(withIdentifier: "headerCell") as! NotificationSettingCell
        header.backgroundColor = UIColor.white
        if section == 0{
            header.lblTitle.text = "Push Notifications"
        }else if section == 1{
            header.lblTitle.text = "Text Message Notifications"
        }else{
            header.lblTitle.text = "Email Notifications"
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50 * _widthRatio
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60 //* _widthRatio
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationSettingCell") as! NotificationSettingCell
        cell.lblTitle.text = arrOfNoti[indexPath.row]
        cell.swNotification.isOn = notifiactions[indexPath.section].arrNotificationSetting[indexPath.row].status
        cell.parent = self
        cell.tag = indexPath.row
        return cell
    }
}

// MARK: - Webcall Methods
extension NotificationSettingVC{
    
    func getNotificationSetting(){
        if !referesh.isRefreshing {
            self.showCentralSpinner()
        }
        KPWebCall.call.getNotificationSetting() { (json, flag) in
            self.hideCentralSpinner()
            self.referesh.endRefreshing()
            if flag == 200 {
                if let notiList = (json as? NSDictionary)?["data"] as? [NSDictionary]{
                    self.notifiactions = []
                    var arrNotification: [NotificationSetting] = []
                    for noti in notiList{
                        arrNotification.append(NotificationSetting(dict: noti))
                    }
                    
                    let arrPush = arrNotification.filter({ (objNotifiSetting: NotificationSetting) -> Bool in
                        return objNotifiSetting.type == .push
                    })
                    let arrMessage = arrNotification.filter({ (objNotifiSetting: NotificationSetting) -> Bool in
                        return objNotifiSetting.type == .message
                    })
                    let arrEmail = arrNotification.filter({ (objNotifiSetting: NotificationSetting) -> Bool in
                        return objNotifiSetting.type == .email
                    })
                    
                    self.notifiactions.append(NotificationSection(title: "Push Notification", arrNotificationSetting: arrPush))
                    self.notifiactions.append(NotificationSection(title: "Message Notification", arrNotificationSetting: arrMessage))
                    self.notifiactions.append(NotificationSection(title: "Email Notification", arrNotificationSetting: arrEmail))
                    
                    self.tableView.reloadData()
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
    
    func updateNotiSetting(objNotification: NotificationSetting){
        let dict: [String: Any]  = ["eStatus": "\(objNotification.status)","sNotificationId": objNotification.id
        ]
        showCentralSpinner()
        KPWebCall.call.updateNotification(param: dict) { (json, flag) in
            self.hideCentralSpinner()
            if flag == 200 {
                if let data = (json as? NSDictionary){
                    kprint(items: data.getStringValue(key: "message"))
                    self.tableView.reloadData()
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
}
