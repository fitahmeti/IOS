
import UIKit

protocol SwishrProfileDelegate {
    func rejectOffer(swishrId: String)
}

class SwishrProfileCell: ConstrainedTableViewCell{
    
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var lblSwishrName: UILabel!
    @IBOutlet var lblFbFrnd: UILabel!
    @IBOutlet var lblLinkFrnd: UILabel!
    @IBOutlet var lbl1: UILabel!
    @IBOutlet var lbl2: UILabel!
    @IBOutlet var lbl3: UILabel!
    
    /// Verification
    @IBOutlet var lblVerified: UILabel!
    @IBOutlet var imgVerified: UIImageView!
    var parent: SwisherProfileVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareUI(){
        imgVerified.isHidden = true
        switch self.tag {
        case 0:
            imgVerified.isHidden = !parent.swisherUser.isEmailVerify
        case 1:
            imgVerified.isHidden = !parent.swisherUser.isMobileVerify
        case 2:
            imgVerified.isHidden = !parent.swisherUser.isFbVerify
        case 3:
            imgVerified.isHidden = !parent.swisherUser.isGoogleVerify
        case 4:
            imgVerified.isHidden = !parent.swisherUser.isLinkdInVerify
        case 5:
            imgVerified.isHidden = !parent.swisherUser.isGoogleVerify
        default:
            break
        }
    }
}

class SwisherProfileVC: ParentViewController {

    /// Variables
    var swishrId: String!
    var arrOfVerified = ["Verified Email Address","Verified Mobile Number","Verified Facebook","Verified Google","Verified LinkedIn","Verified ID"]
    var swisherUser: OtherUser!
    var job: Job!
    var delegate: SwishrProfileDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSwisherProfile()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "receiveBySegue"{
            let vc = segue.destination as! RecipientsVC
            vc.swisher = swisherUser
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

// MARK: - Button Action
extension SwisherProfileVC{

    @IBAction func btnAcceptAction(_ sender: UIButton){
//        showAcceptPopup()
        let acceptPopup = AcceptOfferPopup.instantiateAcceptOfferViewFromNib(withView: self.view, offerImage: swisherUser.imageUrl, offerName:swisherUser.userName)
        acceptPopup.selectionBlock = {
            if _appDelegator.isPaymentAllow{
                self.performSegue(withIdentifier: "paymentSegue", sender: nil)
            }else{
                self.performSegue(withIdentifier: "receiveBySegue", sender: nil)
            }
        }
    }
    
    @IBAction func btnRejectAction(_ sender: UIButton){
        showRejectPopup()
    }
}

// MARK: -  PaymentDelegate
extension SwisherProfileVC: PaymentDelegate{

    func paymentSuccess() {
        self.performSegue(withIdentifier: "receiveBySegue", sender: nil)
    }
}

// MARK: - TableView Method
extension SwisherProfileVC{

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if swisherUser != nil{
            return arrOfVerified.count + 2
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 215
        }else if indexPath.row == arrOfVerified.count + 1{
            return 100
        }else{
            return 40
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "swisherProfileCell") as! SwishrProfileCell
            cell.imgProfile.kf.setImage(with: swisherUser.imageUrl , placeholder: _placeImage)
            cell.lblSwishrName.text = swisherUser.userName
            cell.lblFbFrnd.text = "\(swisherUser.fbFriends) Facebook Friends"
            cell.lblLinkFrnd.text = "\(swisherUser.linkdinFrnd) LinkedIn Connections"
            cell.lbl1.text = "Complete \n\(swisherUser.completeSwished)%"
            cell.lbl2.text = "Late \n\(swisherUser.lateJob)%"
            cell.lbl3.text = "Cancel \n\(swisherUser.cancelJob)%"
            return cell
        }else if indexPath.row == arrOfVerified.count + 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "acceptRejectCell") as! SwishrProfileCell
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "verifiedCell") as! SwishrProfileCell
            cell.lblVerified.text = arrOfVerified[indexPath.row - 1]
            cell.tag = indexPath.row - 1
            cell.parent = self
            cell.prepareUI()
            return cell
        }
    }
}

// MARK: - Accept Reject Pop-up
extension SwisherProfileVC{

    func showRejectPopup(){
        let rejectPopup = UIAlertController(title: "Do you want to reject \(swisherUser.userName)'s offer?", message: nil, preferredStyle: .alert)
        let reject = UIAlertAction(title: "Reject", style: .destructive) { (action) in
            self.rejectOffer(offerStatus: JobOfferStatus.reject)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        rejectPopup.addAction(reject)
        rejectPopup.addAction(cancel)
        present(rejectPopup, animated: true, completion: nil)
    }
}

// MARK: - WebCall Method
extension SwisherProfileVC{

    func getSwisherProfile(){
        if !referesh.isRefreshing {
            self.showCentralSpinner()
        }
        KPWebCall.call.getSwishrProfile(userId: swishrId){ (json, status) in
            self.hideCentralSpinner()
            self.referesh.endRefreshing()
            if status == 200{
                if let data = (json as? NSDictionary)?["data"] as? NSDictionary{
                    self.swisherUser = OtherUser(swishrDict: data)
                    self.tableView.reloadData()
                }
            }else{
                self.showError(data: json,yPos: _topMsgBarConstant)
            }
        }
    }
    
    func rejectOffer(offerStatus: JobOfferStatus) {
        var dict: [String: Any] = [:]
        dict["sJobId"] = job.jobId
        dict["sUserId"] = swishrId
        dict["eOfferStatus"] = offerStatus.rawValue
        
        self.showCentralSpinner()
        KPWebCall.call.respondToOffer(param: dict){ (json, status) in
            self.hideCentralSpinner()
            if status == 200{
                if let _ = json as? NSDictionary{
                    self.delegate?.rejectOffer(swishrId: self.swishrId)
                    self.tableView.reloadData()
                    self.navigationController?.popViewController(animated: true)
                }
            }else{
                self.showError(data: json,yPos: _topMsgBarConstant)
            }
        }
    }

}
