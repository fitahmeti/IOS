//
//  PaymentByCardVC.swift

import UIKit


class PaymentByCardVC: ParentViewController {
    
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet weak var cardTextField: STPPaymentCardTextField!
    @IBOutlet var btnPayFromCard: UIButton!
    @IBOutlet var btnPayFromWallet: UIButton!
    @IBOutlet var tfAmount: UITextField!
    @IBOutlet var lblAmount: UILabel!
    
    /// Variables
    var amount: Double!
    var job: Job!
    var paymentAmount: Double = 0
    var isPaidFromWallet: Bool = false
    weak var paymentDelegate: PaymentDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - UI Methods
extension PaymentByCardVC{
    
    func prepareUI(){
        lblAmount.text = "£\(_user.walletAmount)"
        tfAmount.inputAccessoryView = toolBar
        cardTextField.inputAccessoryView = toolBar
        tfAmount.tintColor = UIColor.swdThemeRedColor()
        cardTextField.tintColor = UIColor.swdThemeRedColor()
        btnPayFromCard.setTitle("Pay £\(amount!)", for: .normal)
    }
}

// MARK: -  actions
extension PaymentByCardVC{
    
    @IBAction func toolBarDoneBtnTap(_ sender: UIButton) {
        self.view.endEditing(true)
    }
    
    @IBAction func btnPayAction(_ sender: UIButton){
        if sender.tag == 0{
            if cardTextField.isValid{
                generateToken()
            }else{
                _ = ValidationToast.showStatusMessage(message: "Invalid card info", yCord: _topMsgBarConstant, inView: self.view)
            }
        }else{
            if paymentAmount == 0{
                _ = ValidationToast.showStatusMessage(message: kEnteramount,yCord: _topMsgBarConstant, inView: self.view)
            }else if paymentAmount < amount{
               _ = ValidationToast.showStatusMessage(message: kInvalidAmount,yCord: _topMsgBarConstant, inView: self.view)
            }else{
                var dict: [String: Any] = ["sJobId": job.jobId,"walletAmount": amount]
                if isPaidFromWallet{
                    dict["walletAmount"] = job.recommandPrice - amount
                }
                makePayment(dict: dict)
            }
        }
    }
    
    @IBAction func txtChanged(_ sender: UITextField){
        if !sender.text!.isEmpty{
            let str = sender.text!.replacingOccurrences(of: "£", with: "")
            if str.isEmpty{
                sender.text = ""
            }else{
                sender.text = "£\(str)"
            }
            if let value = _numberFormatter.number(from: sender.text!){
                paymentAmount = value.doubleValue
            }
        }
    }
}

// MARK: - Api Call
extension PaymentByCardVC{
    
    func makePayment(dict: [String: Any]){
        showCentralSpinner()
        KPWebCall.call.payMent(param: dict){ (json, status) in
            self.referesh.endRefreshing()
            self.hideCentralSpinner()
            if status == 200{
                if let _ = json as? NSDictionary {
                    self.paymentDelegate?.paymentSuccess()
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
    
    
    func generateToken(){
        self.showCentralSpinner()
        STPAPIClient.shared().createToken(withCard: cardTextField.cardParams) { (token, error) in
            self.hideCentralSpinner()
            if token != nil{
                var dict: [String: Any] = ["sJobId": self.job.jobId, "token": token!,"stripeAmount": self.amount]
                if self.isPaidFromWallet{
                    dict["walletAmount"] = self.job.recommandPrice - self.amount
                }
                self.makePayment(dict: dict)
            }else if let err = error{
                _ = ValidationToast.showStatusMessage(message: err.localizedDescription,yCord: _topMsgBarConstant, inView: self.view)
            }else{
                _ = ValidationToast.showStatusMessage(message: "Invalid card info", yCord: _topMsgBarConstant, inView: self.view)
            }
        }
    }
}

