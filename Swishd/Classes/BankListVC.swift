//
//  BankListVC.swift
//  Swishd
//
//

import UIKit

class BankListVC: ParentViewController {
    
    var banks: [Bank]!
    var wallet: Wallet!

    override func viewDidLoad() {
        super.viewDidLoad()
        getBankList()
        prepareUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - UI & Utility Methods
extension BankListVC{
    
    func prepareUI()  {
        referesh.addTarget(self, action: #selector(self.refreshData(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(referesh)
    }
    
    @objc func refreshData(sender: UIRefreshControl)  {
        getBankList()
    }
}

// MARK: - Tableview Method
extension BankListVC{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if banks != nil{
            return banks.isEmpty ? 1 : banks.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if banks.isEmpty{
                let cell = tableView.dequeueReusableCell(withIdentifier: "noBankCell") as! NOItemCell
                cell.lblMessage.text = "No bank accounts are added. Please Add bank account."
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "bankDetailCell") as! PaymentDetailCell
                cell.lblAccNo.text = "\(banks[indexPath.row].accountNo)"
                cell.lblAccName.text = banks[indexPath.row].accountName
              //  cell.lblSortCode.text = banks[indexPath.row].sortCode
                return cell
            }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !banks.isEmpty{
            showComfirmAlert(bank: banks[indexPath.row])
        }
    }
}


// MARK: - Webcall Method
extension BankListVC{
    
    func getBankList(){
        if !referesh.isRefreshing{
            self.showCentralSpinner()
        }
        KPWebCall.call.getBanksList(){ (json, status) in
            self.referesh.endRefreshing()
            self.hideCentralSpinner()
            if status == 200{
                if let bankList = (json as? NSDictionary)?["data"] as? [NSDictionary]{
                    self.banks = []
                    for bank in bankList{
                        self.banks.append(Bank(dict: bank))
                    }
                    self.tableView.reloadData()
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
    
    func cashOutbyBank(bank: Bank){
        
        var dict: [String: Any] = ["sAccountId":bank.id,"sPaymentMethod":"bank"]
            dict["sAmount"] = wallet.isOwnAmount ? wallet.cashOutamount : _user.walletAmount
        
        KPWebCall.call.cashOut(param: dict){ (json, status) in
            self.referesh.endRefreshing()
            self.hideCentralSpinner()
            if status == 200{
                if let _ = json as? NSDictionary {
                    self.showSuccessAlert()
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
}

// MARK: - Alert view Method
extension BankListVC{

    func showComfirmAlert(bank: Bank){
        let alert = UIAlertController(title: "Are you sure?", message: "You are about to cashout your Swish Rewards into the following account.\n\(bank.accountName)\n \(bank.accountNo) ", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            self.cashOutbyBank(bank: bank)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(confirm)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func showSuccessAlert(){
        let alert = UIAlertController(title: "Success", message: "You have successfully cashout your swish rewards.\n this will be in your account in some days.", preferredStyle: .alert)
        let done = UIAlertAction(title: "Done", style: .default) { (action) in
            self.navigationController?.popToRootViewController(animated: true)
        }
        alert.addAction(done)
        present(alert, animated: true, completion: nil)
        
    }

}
