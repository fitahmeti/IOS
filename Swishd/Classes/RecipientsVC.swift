

import UIKit

class RecipientsVC: ParentViewController {
    
    /// Variables
    var job: Job!
    var swishrId: String!
    var swisher: OtherUser!
    var receiver = RecipientData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        setKeyboardNotifications()
        KPContactManager.shared.contactMustContain = [.phone]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "swishrnameSegue"{
            let vc = segue.destination as! SwishrNameVC
            vc.reciver = receiver
            if let tag = sender as? Int{
                vc.isfromPick = tag == 10 ? true : false
            }
        }
    }
}

// MARK: - UI & Utility Methods
extension RecipientsVC{
    
    func prepareUI()  {
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
        tableView.contentInset  = UIEdgeInsets(top: 5 * _widthRatio, left: 0, bottom: 10 * _widthRatio, right: 0)
    }
}

// MARK: - Button action
extension RecipientsVC{
    @IBAction func btnMeElseAction(_ sender: UIButton){
        if sender.tag == 1{
            receiver.isPickByMe = !receiver.isPickByMe
        }else{
            receiver.isReceivedByMe = !receiver.isReceivedByMe
        }
        tableView.reloadData()
    }
    
    @IBAction func btnDoneAction(_ sender: UIButton){
        if receiver.isValidData().valid{
            if let _ = self.swisher{
                self.confirmOffer()
            }else{
                self.getSwisherProfile()
            }
        }else{
            _ = ValidationToast.showStatusMessage(message: receiver.isValidData().error,yCord: _topMsgBarConstant, inView: self.view)
        }
    }
    
    @IBAction func btnGetContactAction(_ sender: UIButton){
        getContact(tag: sender.tag)
    }
    
    @IBAction func btnSwishrusernameAction(_ sender: UIButton){
        performSegue(withIdentifier: "swishrnameSegue", sender: sender.tag)
    }
}

// MARK: - TableView Method
extension RecipientsVC{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !receiver.isPickByMe{
            return !receiver.isReceivedByMe ? 6 : 5
        }else{
            return !receiver.isReceivedByMe ? 5 : 4
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0{
            return 95 * _widthRatio
        }else if indexPath.row == 1{
            return 190 * _widthRatio
        }else if !receiver.isPickByMe{
            if indexPath.row == 3{
                return 210 * _widthRatio
            }else if indexPath.row == 2{
                return 385 * _widthRatio
            }else{
                return !receiver.isReceivedByMe && indexPath.row == 4 ? 385 * _widthRatio : 80 * _widthRatio
            }
        }else{
            if indexPath.row == 2{
                 return 210 * _widthRatio
            }else{
                return !receiver.isReceivedByMe && indexPath.row == 3 ? 385 * _widthRatio : 80 * _widthRatio
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell") as! RecipientCell
            return cell
        }else if indexPath.row == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "fromToDataCell") as! RecipientCell
            cell.tag = indexPath.row
            cell.btnElse.tag = indexPath.row
            cell.btnMe.tag = indexPath.row
            cell.viewShadowTop.constant = -10 * _widthRatio
            cell.prepareReciverUI(job: job,reciver: receiver)
            return cell
        }else if !receiver.isPickByMe{
            if indexPath.row == 3{
                let cell = tableView.dequeueReusableCell(withIdentifier: "fromToDataCell") as! RecipientCell
                cell.tag = 2
                cell.btnElse.tag = indexPath.row
                cell.btnMe.tag = indexPath.row
                cell.viewShadowTop.constant = 10 * _widthRatio
                cell.prepareReciverUI(job: job,reciver: receiver)
                return cell
            }else if indexPath.row == 2{
                let cell = tableView.dequeueReusableCell(withIdentifier: "swishrDataCell") as! RecipientCell
                cell.tag = 10
                cell.parent = self
                cell.prepareElseData()
                return cell
            }else if !receiver.isReceivedByMe && indexPath.row == 4 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "swishrDataCell") as! RecipientCell
                cell.tag = 11
                cell.parent = self
                cell.prepareElseData()
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "doneCell") as! ConstrainedTableViewCell
                return cell
            }
        }else{
            if indexPath.row == 2{
                let cell = tableView.dequeueReusableCell(withIdentifier: "fromToDataCell") as! RecipientCell
                cell.tag = 2
                cell.btnElse.tag = indexPath.row
                cell.btnMe.tag = indexPath.row
                cell.viewShadowTop.constant = 10 * _widthRatio
                cell.prepareReciverUI(job: job,reciver: receiver)
                return cell
            }else if !receiver.isReceivedByMe && indexPath.row == 3{
                let cell = tableView.dequeueReusableCell(withIdentifier: "swishrDataCell") as! RecipientCell
                cell.tag = 11
                cell.parent = self
                cell.prepareElseData()
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "doneCell") as! ConstrainedTableViewCell
                return cell
            }
        }
    }
}

// MARK: - WebCall Method
extension RecipientsVC{
    
    func getSwisherProfile(){
        self.showCentralSpinner()
        KPWebCall.call.getSwishrProfile(userId: swishrId){ (json, status) in
            self.hideCentralSpinner()
            self.referesh.endRefreshing()
            if status == 200{
                if let data = (json as? NSDictionary)?["data"] as? NSDictionary{
                    self.swisher = OtherUser(swishrDict: data)
                    self.confirmOffer()
                    self.tableView.reloadData()
                }
            }else{
                self.showError(data: json,yPos: _topMsgBarConstant)
            }
        }
    }
    
    func confirmOffer(){
        var dict: [String: Any] = [:]
        dict = receiver.getParamDict()
        dict["sJobId"] = job.jobId
        if receiver.isPickByMe{
            dict["sPickUserId"] = _user.id
        }
        if receiver.isReceivedByMe{
            dict["sRecievedUserId"] = _user.id
        }
        if let swishr = swisher{
            dict["sUserId"] = swishr.id
        }
        kprint(items: dict)
        self.showCentralSpinner()
        KPWebCall.call.acceptOfferWithReceiver(param: dict){ (json, status) in
            self.hideCentralSpinner()
            if status == 200{
                if let _ = json as? NSDictionary{
                    self.showCongratulatioPopup()
                    self.tableView.reloadData()
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
}

// MARK: - Contact Picker Methods
extension RecipientsVC{
    
    func getContact(tag: Int){
        let pickerVC = UIStoryboard(name: "KPContact", bundle: nil).instantiateViewController(withIdentifier: "KPContactPickerVC") as! KPContactPickerVC
        pickerVC.selectionBlock = { [unowned self] contact in
            
            if !self.receiver.isPickByMe && tag == 10{
                self.receiver.isAppPickUser = false
                self.receiver.pickSwishrName = nil
                self.receiver.pickSwishrEmail = nil
                self.receiver.pickUserFname = contact.firstName
                self.receiver.pickUserLname = contact.lastName
                if let ph = contact.phoneNo.first{
                    self.receiver.pickUserMobile = ph.phoneNumber
                }
                if let email = contact.emails.first{
                    self.receiver.pickUserEmail = email.email
                }
            }else if !self.receiver.isReceivedByMe && tag == 11{
                self.receiver.isAppDropUser = false
                self.receiver.dropSwishrName = nil
                self.receiver.dropSwishrEmail = nil
                self.receiver.dropUserFname = contact.firstName
                self.receiver.dropUserLname = contact.lastName
                if let ph = contact.phoneNo.first{
                    self.receiver.dropUserMobile = ph.phoneNumber
                }
                if let email = contact.emails.first{
                    self.receiver.dropUserEmail = email.email
                }
            }
            self.tableView.reloadData()
        }
        self.navigationController?.pushViewController(pickerVC, animated: true)
    }
}

// AlrtView Method
extension RecipientsVC{
    
    func showCongratulatioPopup(){
        let popUp = CongratulationPopup.instantiateCongratulationViewFromNib(withView: self.view,swishr: swisher)
        popUp.selectionBlock = {
            self.redirectToViewActivity()
        }
    }
    
    func redirectToViewActivity(){
        let controllers = navigationController?.viewControllers
        for vc in controllers!{
            if let jobVc = vc as? JobDetailVC{
                jobVc.getJobDetail()
                navigationController?.popToViewController(jobVc, animated: true)
                break
            }
        }
    }
}

// MARK: - Keyboard Functions
extension RecipientsVC {
    func setKeyboardNotifications() {
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let kbSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 5 * _widthRatio, left: 0, bottom: kbSize.height, right: 0)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        tableView.contentInset  = UIEdgeInsets(top: 5 * _widthRatio, left: 0, bottom: 10 * _widthRatio, right: 0)
    }
}
