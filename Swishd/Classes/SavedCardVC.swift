

import UIKit

class SavedCardVC: ParentViewController {
    
    /// Variables
    var cards: [Card]!
    var amount: Double!
    var job: Job!
    var isPaidFromWallet: Bool = false
    weak var paymentDelegate: PaymentDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        getCardList()
        prepareUI()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - UI & Utility Methods
extension SavedCardVC{
    
    func prepareUI()  {
        referesh.addTarget(self, action: #selector(self.refreshData(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(referesh)
    }
    
    @objc func refreshData(sender: UIRefreshControl)  {
        getCardList()
    }
}

// MARK: - Tableview Method
extension SavedCardVC{

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cards != nil{
            return cards.isEmpty ? 1 : cards.count + 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cards.isEmpty ? 150 * _widthRatio : 70 * _widthRatio
    }
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if cards.isEmpty || indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "nocardCell") as! NOItemCell
            cell.lblMessage.text = cards.isEmpty ? "Not any saved cards." : "Saved cards"
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "savedCardCell") as! PaymentDetailCell
            cell.imgCard.image = cards[indexPath.row - 1].cardImg
            cell.lblCardNo.text = cards[indexPath.row - 1].cardNoStr
            cell.lblCardName.text = cards[indexPath.row - 1].cardType
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !cards.isEmpty{
            makePayment(card: cards[indexPath.row - 1])
        }
    }
}

// MARK: - Webcall Method
extension SavedCardVC{
    
    func getCardList() {
        if !_user.stripeCustomerId.isEmpty{
            self.showCentralSpinner()
            StripeUtil.shared.getCardsList(completion: { (json, error) in
                self.referesh.endRefreshing()
                self.hideCentralSpinner()
                if let arr = (json as? NSDictionary)?["data"] as? [NSDictionary]{
                    kprint(items: arr)
                    self.cards = []
                    for dict in arr{
                        let card = Card(dict: dict)
                        self.cards.append(card)
                    }
                    self.tableView.reloadData()
                }else if let err = error{
                    _ = ValidationToast.showStatusMessage(message: err.localizedDescription, yCord: _topMsgBarConstant, inView: self.view)
                }
            })
        }else{
            self.cards = []
            self.referesh.endRefreshing()
            self.hideCentralSpinner()
        }
    }

    func makePayment(card: Card){
        var dict: [String: Any] = ["sJobId": job.jobId,"stripeAmount": amount,"customer": _user.stripeCustomerId,"card": card.id ]
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
