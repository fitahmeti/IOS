

import UIKit

class SwishdPaymentCell: ConstrainedTableViewCell, UITextFieldDelegate{

    @IBOutlet weak var tfAmount: UITextField!
    @IBOutlet var toolBar: UIToolbar!
    var parent: SwishdPaymentVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareUI(){
        tfAmount.inputAccessoryView = toolBar
        tfAmount.keyboardType = .decimalPad
        tfAmount.tintColor = UIColor.swdThemeRedColor()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func textChanged(sender: UITextField){
        if !sender.text!.isEmpty{
            let str = sender.text!.replacingOccurrences(of: "£", with: "")
            if str.isEmpty{
                sender.text = ""
            }else{
                sender.text = "£\(str)"
            }
            if let amount = _numberFormatter.number(from: sender.text!){
                parent.amount = amount.doubleValue
            }
        }
    }
}

protocol SwishRemainigPaymentDelegate {
    func payRemaining(paidAmount: Double)
}

class SwishdPaymentVC: ParentViewController {
    
    var job: Job!
    var amount: Double = 0
    var delegate: SwishRemainigPaymentDelegate?
    weak var paymentDelegate: PaymentDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Button Action
extension SwishdPaymentVC{

    @IBAction func btnConfirmAction(_ sender: UIButton){
        if amount == 0{
            _ = ValidationToast.showStatusMessage(message: kEnteramount,yCord: _topMsgBarConstant, inView: self.view)
        }else if amount < job.recommandPrice{
            delegate?.payRemaining(paidAmount: amount)
            navigationController?.popViewController(animated: true)
        }else{
            payment()
        }
    }
    
    @IBAction func toolBarDoneBtnTap(_ sender: UIButton) {
        self.view.endEditing(true)
    }
}

// MARK: - Tableview Method
extension SwishdPaymentVC{

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300 * _widthRatio
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "swishdpaymentCell") as! SwishdPaymentCell
        cell.parent = self
        cell.prepareUI()
        return cell
    }
}

// MARK: - Webcall Method
extension SwishdPaymentVC{

    func payment(){
        let dict: [String: Any] = ["sJobId": job.jobId,"walletAmount": amount]
        KPWebCall.call.payMent(param: dict){ (json, status) in
            self.referesh.endRefreshing()
            self.hideCentralSpinner()
            if status == 200{
                if let _ = json as? NSDictionary {
                    self.paymentDelegate?.paymentSuccess()
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
            }else{
                self.showError(data: json,yPos: _topMsgBarConstant)
            }
        }
    }
}
