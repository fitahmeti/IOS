

import UIKit

class CharityCell: ConstrainedTableViewCell{
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet var headerShadowvwBottom: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class CashoutChooseMethod: ParentViewController {
    
    var wallet: Wallet!
    var charity: [Charity] = []
    var banks: [Bank]!

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getCharityList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bankListSegue"{
            let vc = segue.destination as! BankListVC
            vc.wallet = wallet
        }
    }
}

// MARK: - UI & Utility Methods
extension CashoutChooseMethod{
    
    func prepareUI()  {
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
        tableView.contentInset  = UIEdgeInsets(top: 5 * _widthRatio, left: 0, bottom: 10 * _widthRatio, right: 0)
    }
}

// MARK: - Button Action
extension CashoutChooseMethod{
    
    @IBAction func btnBankListSegue(_ sender: UIButton){
        performSegue(withIdentifier: "bankListSegue", sender: nil)
    }
}

// MARK: - Tableview Method
extension CashoutChooseMethod{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? banks.count + 1 : charity.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            if indexPath.row == 0{
                return 80 * _widthRatio
            }else if indexPath.row == banks.count{
                return 90 * _widthRatio
            }
            return 70 * _widthRatio
        }else{
            if indexPath.row == 0{
                return 92 * _widthRatio
            }else if indexPath.row == charity.count{
                return 90 * _widthRatio
            }
            return 70 * _widthRatio
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! CharityCell
                cell.lblTitle.text = "PLEASE CHOOSE YOUR CASHOUT METHOD"
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "bankCell") as! PaymentDetailCell
                cell.lblAccNo.text = banks[indexPath.row-1].makeString()
                cell.lblAccName.text = banks[indexPath.row-1].accountName
                cell.viewShadowBottom.constant = -10 * _widthRatio
                if indexPath.row == banks.count{
                    cell.viewShadowBottom.constant = 10 * _widthRatio
                }
                return cell
            }
        }else{
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! CharityCell
                cell.lblTitle.text = "Or you may wish to choose from one of the following charities to donate towards"
                return cell

            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "charityCell") as! PaymentDetailCell
                cell.lblTitle.text = charity[indexPath.row-1].name
                cell.imgCharity.kf.setImage(with: charity[indexPath.row-1].imgUrl)
                cell.viewShadowBottom.constant = -10 * _widthRatio
                if indexPath.row == charity.count{
                    cell.viewShadowBottom.constant = 10 * _widthRatio
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row != 0{
            showBankPopup(bank: banks[indexPath.row - 1])
        }else if indexPath.section == 1 && indexPath.row != 0{
            cashOutbyCharity(charity: charity[indexPath.row - 1])
        }
    }
}

// MARK: - Web call method
extension  CashoutChooseMethod{

    func getCharityList(){
            if !referesh.isRefreshing{
                self.showCentralSpinner()
            }
            KPWebCall.call.getCharityList(){ (json, status) in
                self.referesh.endRefreshing()
                self.hideCentralSpinner()
                if status == 200{
                    if let charityList = (json as? NSDictionary)?["data"] as? [NSDictionary]{
                        self.charity = []
                        for charityObj in charityList{
                            self.charity.append(Charity(dict: charityObj))
                        }
                        self.tableView.reloadData()
                    }
                }else{
                    self.showError(data: json,yPos: _topMsgBarConstant)
                }
        }
    }
    
    func cashOutbyBank(bank: Bank){
        let amount = wallet.isOwnAmount ? wallet.cashOutamount : _user.walletAmount
        let dict: [String: Any] = ["sAccountId":bank.id,"sPaymentMethod":"bank", "sAmount": amount]
        
        self.showCentralSpinner()
        KPWebCall.call.cashOut(param: dict){ (json, status) in
            self.hideCentralSpinner()
            if status == 200{
                if let _ = json as? NSDictionary {
                    self.showSccessPopup()
                    _user.walletAmount -= amount
                    _appDelegator.saveContext()
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
    
    func cashOutbyCharity(charity: Charity){
        
        let amount = wallet.isOwnAmount ? wallet.cashOutamount : _user.walletAmount
        let dict: [String: Any] = ["sAccountId":charity.id,"sPaymentMethod":"charity", "sAmount": amount]

        self.showCentralSpinner()
        KPWebCall.call.cashOut(param: dict){ (json, status) in
            self.hideCentralSpinner()
            if status == 200{
                if let _ = json as? NSDictionary {
                    self.showCharityPopup(charity: charity, amount: amount)
                    _user.walletAmount -= amount
                    _appDelegator.saveContext()
                }
            }else{
                self.showError(data: json,yPos: _topMsgBarConstant)
            }
        }
    }
}

// MARK: - Alert view Method
extension CashoutChooseMethod{
    
    func showCharityPopup(charity: Charity, amount : Int32){
        let popup = CharityPopup.instantiateCharityPopupViewFromNib(withView: self.view, charity: charity, amount: amount)
        popup.selectionBlock = {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func showBankPopup(bank: Bank){
        let popup = BankPopup.instantiateBankPopupViewFromNib(withView: self.view, bank: bank)
        popup.selectionBlock = { (isConfirm) -> () in
            if isConfirm{
                self.cashOutbyBank(bank: bank)
            }
        }
    }
    
    func showSccessPopup(){
        let popup = SuccessPopUp.instantiateSuccessPopupViewFromNib(withView: self.view)
        popup.selectionBlock = {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}
