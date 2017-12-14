

import UIKit

class JobActivityCell: ConstrainedTableViewCell{
    
    @IBOutlet var lblActivity: UILabel!
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var btnContact: UIButton!
    @IBOutlet var vwShadow: UIView!
    
    weak var parent: JobactivityVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setShadow(height: CGFloat){
        let rect = CGRect(x: 0, y: 0, width: _screenSize.width - (20 * _widthRatio), height: height)
        vwShadow.layer.shadowPath = UIBezierPath(rect: rect).cgPath
    }
    
    func prepareUI(){
        let activity = parent.arrOfActivity[tag]
        lblActivity.text = activity.displayString
        lblDate.text = activity.activityDate!.agoStringFromTime()
        imgUser.kf.setImage(with: activity.sender?.imageUrl)
        let strHeight = activity.displayString.heightWithConstrainedWidth(width: 279 * _widthRatio, font: UIFont.arialRegular(size: 16 * _widthRatio))
        setShadow(height: strHeight + 70 * _widthRatio)
    }

}

class JobactivityVC: ParentViewController {
    
    /// Variables
    var job: Job!
    var arrOfActivity: [JobActivity]!

    override func viewDidLoad() {
        super.viewDidLoad()
        getActivityList()
        prepareUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "messageSegue" {
            let dest = segue.destination as! MessageFormatVc
            dest.job = self.job
        }
    }
}

// MARK: - UI & Utility Methods
extension JobactivityVC{
    
    func prepareUI()  {
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
        tableView.contentInset  = UIEdgeInsets(top: 10 * _widthRatio, left: 0, bottom: 10 * _widthRatio, right: 0)
        referesh.addTarget(self, action: #selector(self.refreshData(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(referesh)
    }
    
    @objc func refreshData(sender: UIRefreshControl)  {
        getActivityList()
    }
}

// MARK: - Button actions
extension JobactivityVC {

    @IBAction func contactBtnTap(_ sender: UIButton) {
        self.performSegue(withIdentifier: "messageSegue", sender: nil)
    }
}

// MARK: - Tableview Method
extension JobactivityVC{

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrOfActivity != nil{
            if arrOfActivity.isEmpty{
                return 2
            }
            return arrOfActivity.count + 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if arrOfActivity.isEmpty{
            return 150 * _widthRatio
        }else{
            if indexPath.row == arrOfActivity.count {
                return 70 * _widthRatio
            }else{
                let strHeight = arrOfActivity[indexPath.row].displayString.heightWithConstrainedWidth(width: 279 * _widthRatio, font: UIFont.arialRegular(size: 16 * _widthRatio))
                return  strHeight + 80 * _widthRatio
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if arrOfActivity.isEmpty{
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "noActivityCell") as! NOItemCell
                cell.lblMessage.text = "No Activity found!"
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell") as! JobActivityCell
                if job.isSentByMe{
                    cell.btnContact.setTitle("CONTACT SWISHR", for: .normal)
                }else{
                    cell.btnContact.setTitle("CONTACT SENDR", for: .normal)
                }
                return cell
            }
        }else if indexPath.row == arrOfActivity.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell") as! JobActivityCell
            if job.isSentByMe{
                cell.btnContact.setTitle("CONTACT SWISHR", for: .normal)
            }else{
                cell.btnContact.setTitle("CONTACT SENDR", for: .normal)
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell") as! JobActivityCell
            cell.tag = indexPath.row
            cell.parent = self
            cell.prepareUI()
            return cell
        }
    }
}

// MARK: - Webcall Method
extension JobactivityVC{

    func getActivityList(){
        if !referesh.isRefreshing {
            self.showCentralSpinner()
        }
        KPWebCall.call.getJobActivity(jobId: job.jobId){ (json, status) in
            self.hideCentralSpinner()
            self.referesh.endRefreshing()
            if status == 200{
                if let activityList = (json as? NSDictionary)?["data"] as? [NSDictionary]{
                    self.arrOfActivity = []
                    for activity in activityList{
                        self.arrOfActivity.append(JobActivity(dict: activity))
                    }
                    self.tableView.reloadData()
                }
            }else{
                self.showError(data: json,yPos: _topMsgBarConstant)
            }
        }
    }
}
