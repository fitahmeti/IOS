

import UIKit

class MessageFormatCell: ConstrainedTableViewCell {
    
    @IBOutlet var lblText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class MessageFormatVc: ParentViewController {

    /// Variables
    var job: Job!
    var msgList: [MessageFormat]!
    
    /// View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getMessageFormatList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendMsgSegue"{
            let dest = segue.destination as! SendMsgVC
            dest.job = self.job
        }
    }
}

// MARK: - UI & Utility related
extension MessageFormatVc {

    func prepareUI() {
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
        referesh.addTarget(self, action: #selector(self.refreshData(_:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(referesh)
    }
    
    @objc func refreshData(_ sender: UIRefreshControl) {
        getMessageFormatList()
    }
}

// MARK: - TableView methods
extension MessageFormatVc {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if msgList != nil{
            return msgList.count + 2
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 || indexPath.row == msgList.count + 1{
            return 75 * _widthRatio
        }else{
            let height = msgList[indexPath.row - 1].msg.heightWithConstrainedWidth(width: 301 * _widthRatio, font: UIFont.arialBold(size: 14 * _widthRatio))
            return height + 60 * _widthRatio
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellTitle", for: indexPath) as! MessageFormatCell
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MessageFormatCell
            if indexPath.row == msgList.count + 1{
                cell.lblText.text = "Other"
            }else{
                cell.lblText.text = msgList[indexPath.row - 1].msg
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != msgList.count + 1{
            sendMessage(mId: msgList[indexPath.row - 1].id)
        }else{
            self.performSegue(withIdentifier: "sendMsgSegue", sender: nil)
        }
    }
}

// MARK: - Web Call Methods
extension MessageFormatVc {

    func getMessageFormatList() {
        if !referesh.isRefreshing{
            self.showCentralSpinner()
        }
        KPWebCall.call.getMessageFormatList(msgFor: job.isSentByMe ? "sender" : "swishr") { (json, status) in
            self.hideCentralSpinner()
            self.referesh.endRefreshing()
            if status == 200 {
                if let arr = (json as? NSDictionary)?["items"] as? [NSDictionary] {
                    self.msgList = []
                    for dict in arr{
                        let msg = MessageFormat(dict: dict)
                        self.msgList.append(msg)
                    }
                    self.tableView.reloadData()
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
    
    func sendMessage(mId: String) {
        let param: [String: Any] = ["sMessageId": mId, "sJobId": job.jobId]
        self.showCentralSpinner()
        KPWebCall.call.sendMessage(param: param) { (json, status) in
            self.hideCentralSpinner()
            if status == 200{
                self.navigateToActivity()
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
    
    func navigateToActivity()  {
        for vc in self.navigationController!.viewControllers{
            if let actVc = vc as? JobactivityVC{
                actVc.getActivityList()
                navigationController?.popToViewController(actVc, animated: true)
                break
            }
        }
    }
}
