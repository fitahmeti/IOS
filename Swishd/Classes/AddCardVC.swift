

import UIKit

protocol CardProtocol {
    func cardAdded(card: Card)
}

class AddCardVC: ParentViewController {
    
    /// IBOutlets
    @IBOutlet weak var cardTextField: STPPaymentCardTextField!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var btnAdd: UIButton!
    
    /// Variables
    var delegate: CardProtocol?
    var isFromPayment: Bool = false
    var job: Job!
    var amount: Double!
    var isPaidFromWallet: Bool = false
    weak var paymentDelegate: PaymentDelegate?
    
    /// View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - UI & Utility Methods
extension AddCardVC{
    
    func prepareUI() {
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
        cardTextField.inputAccessoryView = toolBar
        cardTextField.font = UIFont.arialRegular(size: 23 * _widthRatio)
        if isFromPayment{
            btnAdd.setTitle("Pay", for: .normal)
        }else{
            btnAdd.setTitle("Add card", for: .normal)
        }
    }
    
    func saveCard()  {
        self.showCentralSpinner()
        StripeUtil.shared.createCard(stripeId: _user.stripeCustomerId, card: cardTextField.cardParams) { (json, error) in
            self.hideCentralSpinner()
            if let dict = json as? NSDictionary{
                let card = Card(dict: dict)
                self.delegate?.cardAdded(card: card)
                _ = self.navigationController?.popViewController(animated: true)
            }else if let err = error{
                _ = ValidationToast.showStatusMessage(message: err.localizedDescription, yCord: _topMsgBarConstant, inView: self.view)
            }else{
                _ = ValidationToast.showStatusMessage(message: "Invalid card info", yCord: _topMsgBarConstant, inView: self.view)
            }
        }
    }
    
    func generateToken(){
        self.showCentralSpinner()
        STPAPIClient.shared().createToken(withCard: cardTextField.cardParams) { (token, error) in
            self.hideCentralSpinner()
            if token != nil{
                kprint(items: token!)
                self.makePayment(token: token!)
            }else if let err = error{
                _ = ValidationToast.showStatusMessage(message: err.localizedDescription,yCord: _topMsgBarConstant, inView: self.view)
            }else{
                _ = ValidationToast.showStatusMessage(message: "Invalid card info", yCord: _topMsgBarConstant, inView: self.view)
            }
        }
    }   
}

// MARK: - Button Actions
extension AddCardVC{
    
    @IBAction func addCardTap(_ sender: UIButton){
        if cardTextField.isValid{
            if isFromPayment{
                generateToken()
            }else{
                //check if the customerId exist
                if !_user.stripeCustomerId.isEmpty {
                    saveCard()
                }
                else {
                    //if not, create the user with our createUser method
                    self.showCentralSpinner()
                    StripeUtil.shared.createUser(completion: { (json, error) in
                        self.hideCentralSpinner()
                        if let dict = json as? NSDictionary{
                            _user.stripeCustomerId = dict.getStringValue(key: "id")
                            _appDelegator.saveContext()
                            self.addCustomerId()
                            self.saveCard()
                        }else if let err = error{
                            _ = ValidationToast.showStatusMessage(message: err.localizedDescription, yCord: _topMsgBarConstant, inView: self.view)
                        }
                    })
                }
                }
            }else{
            _ = ValidationToast.showStatusMessage(message: "Invalid card info", yCord: _topMsgBarConstant, inView: self.view)
        }
    }
    
    @IBAction func toolBarDoneTap(_ sender: UIButton) {
        self.cardTextField.resignFirstResponder()
    }
}

// MARK: - Webcall Method
extension AddCardVC{
    
    func addCustomerId(){
        KPWebCall.call.addCustomerId(param: ["stripe_customer_id":_user.stripeCustomerId]){ (json, status) in
            self.referesh.endRefreshing()
            self.hideCentralSpinner()
            if status == 200{
                if let _ = json as? NSDictionary {
                    kprint(items: "Stripe Customer id")
                }
            }else{
                self.showError(data: json,yPos: _topMsgBarConstant)
            }
        }
    }
    
    func makePayment(token: STPToken){
        var dict: [String: Any] = ["sJobId": job.jobId, "token": token,"stripeAmount": amount]
        if isPaidFromWallet{
            dict["walletAmount"] = job.recommandPrice - amount
        }
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
}
