
import UIKit

class PaymentVC: ParentViewController {
    
    var job: Job!
    var isRemaingPayment: Bool = false
    var remainingAmount: Double = 0
    weak var paymentDelegate: PaymentDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        remainingAmount = job.recommandPrice
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "swishdPaymentSegue"{
            let vc = segue.destination as! SwishdPaymentVC
            vc.delegate = self
            vc.paymentDelegate = self
            vc.job = job
        }else if segue.identifier == "savedCardSegue"{
            let vc = segue.destination as! SavedCardVC
            vc.amount = remainingAmount
            vc.job = job
            vc.paymentDelegate = self
            vc.isPaidFromWallet = isRemaingPayment
        }else if segue.identifier == "paymentbyCardSegue"{
            let vc = segue.destination as! PaymentByCardVC
            vc.amount = remainingAmount
            vc.isPaidFromWallet = isRemaingPayment
            vc.job = job
            vc.paymentDelegate = self
        }
    }
}

// MARK: - SwishRemainigPaymentDelegate, PaymentDelegate
extension PaymentVC: SwishRemainigPaymentDelegate, PaymentDelegate{
    
    func payRemaining(paidAmount: Double) {
        isRemaingPayment = true
        remainingAmount = job.recommandPrice - paidAmount
        tableView.reloadData()
    }
    
    func paymentSuccess() {
        paymentDelegate?.paymentSuccess()
    }
}

// MARK: - Button Action
extension PaymentVC{

    @IBAction func btnSwishdPaymentAction(_ sender: UIButton){
        if _user.walletAmount <= 0{
            _ = ValidationToast.showBarMessage(message: kInsuffientAmount, inView: self.view)
        }else{
            performSegue(withIdentifier: "swishdPaymentSegue", sender: nil)
        }
    }
    
    @IBAction func btnSavedCardAction(_ sender: UIButton){
        performSegue(withIdentifier: "savedCardSegue", sender: nil)
    }
    
    @IBAction  func btnaddCardAction(_ sender: UIButton){
        performSegue(withIdentifier: "paymentbyCardSegue", sender: nil)
//        let storyboard = UIStoryboard(name: "Wallet", bundle: nil)
//        let cardVc = storyboard.instantiateViewController(withIdentifier: "AddCardVC") as! AddCardVC
//        cardVc.isFromPayment = true
//        cardVc.amount = remainingAmount
//        cardVc.isPaidFromWallet = isRemaingPayment
//        cardVc.paymentDelegate = self
//        cardVc.job = job
//        navigationController?.pushViewController(cardVc, animated: true)
    }
}

// MARK: - TableView Method
extension PaymentVC{

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isRemaingPayment{
            return section == 0 ? 0 : 40 * _widthRatio
        }
        return 0        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "headercell") as! ConstrainedTableViewCell
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 291 * _widthRatio : 180 * _widthRatio
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "walletAmountCell") as! PaymentDetailCell
            cell.lblTotalAmount.text = "£\(_user.walletAmount)"
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "paymentOptionCell") as! ConstrainedTableViewCell
            return cell
        }
    }
}
