
import UIKit

enum WalletSegment {
    case payment
    case history
}

class PaymentDetailCell: ConstrainedTableViewCell{
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTotalAmount: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet var viewShadowBottom: NSLayoutConstraint!
    
    @IBOutlet var imgCard: UIImageView!
    @IBOutlet var lblCardName: UILabel!
    @IBOutlet var lblCardNo: UILabel!
    
    // Bank Details
    @IBOutlet var lblAccName: UILabel!
    @IBOutlet var lblAccNo: UILabel!
    
    // Charity
    @IBOutlet var imgCharity: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class HistroyCell: ConstrainedTableViewCell{
    
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    weak var parent: WalletDetailVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareUI(){
        let histroy = parent.histroy[self.tag]
        lblUsername.text = histroy.userHistroy.userName
        lblDate.text = histroy.dateateStr
        imgUser.kf.setImage(with: histroy.userHistroy.imageUrl)
        lblAmount.textColor = histroy.paymentFlow == .deduct ? .swdThemeRedColor() : .swdBlueColor()
        lblAmount.text = histroy.paymentFlow == .deduct ? "- £\(histroy.amoumt)" : "+ £\(histroy.amoumt)"
    }
}

class WalletDetailVC: ParentViewController{

    var selectedSegment = WalletSegment.payment
    var histroy: [WalletHistroy]!
    var banks: [Bank] = []
    var cards: [Card] = []
    var loadMore = LoadMore()

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getBankList()
        getCardList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addBankSegue"{
            let vc = segue.destination as! AddBankVC
            vc.delegate = self
        }else if segue.identifier == "addCardSegue"{
            let vc = segue.destination as! AddCardVC
            vc.delegate = self
        }else if segue.identifier == "cashOutSegue"{
            let vc = segue.destination as! CashoutSetAmount
            vc.banks = self.banks
        }
    }
}

// MARK: - AddBankDelegate, CardProtocol
extension WalletDetailVC: AddBankDelegate, CardProtocol{
    
    func addBank(bank: Bank) {
        banks.insert(bank, at: 0)
        tableView.reloadData()
    }
    
    func cardAdded(card: Card) {
        cards.insert(card, at: 0)
        tableView.reloadData()
    }
}

// MARK: - UI & Utility Methods
extension WalletDetailVC{
    
    func prepareUI()  {
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
        tableView.contentInset  = UIEdgeInsets(top: 5 * _widthRatio, left: 0, bottom: 10 * _widthRatio, right: 0)
        referesh.addTarget(self, action: #selector(self.refreshData(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(referesh)
        
        // Headerview
        let headerVw = UINib(nibName: "ProfileHeaderView", bundle: nil)
        tableView.register(headerVw, forHeaderFooterViewReuseIdentifier: "profileHeader")
    }
    
    @objc func refreshData(sender: UIRefreshControl)  {
        loadMore = LoadMore()
        if selectedSegment == .payment{
            getBankList()
        }else{
            getWalletHistroy()
        }
    }
}

// MARK: - Button Action
extension WalletDetailVC{
    
    @IBAction func btnPaymentHistoryaction(_ sender: UIButton){
        if sender.tag == 0{
            selectedSegment = .payment
            if banks.isEmpty{
                getBankList()
            }
        }else{
            selectedSegment = .history
            if histroy == nil{
                getWalletHistroy()
            }
        }
        tableView.reloadData()
    }
    
    @IBAction func addBankaccountAction(_ sendr: UIButton){
        if sendr.tag == 3{
            performSegue(withIdentifier: "addBankSegue", sender: nil)
        }else{
            performSegue(withIdentifier: "addCardSegue", sender: nil)
        }
    }
    
    @IBAction func btnCashOutAction(_ sender: UIButton){
        if _user.walletAmount > 0{
            performSegue(withIdentifier: "cashOutSegue", sender: nil)
        }else{
            _ = ValidationToast.showStatusMessage(message: kInsuffientAmount, yCord: _topMsgBarConstant, inView: self.view)
        }
    }
}

// MARK: - Tableview method
extension WalletDetailVC{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return selectedSegment == .payment ? 4 : 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else if selectedSegment == .payment{
            if section == 1{
                return 1
            }else if section == 2{
                return cards.count + 1
            }else if section == 3{
                return banks.count + 1
            }
           return 0
        }else{
            if histroy != nil{
                return histroy.isEmpty ? 1 : histroy.count
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 180 * _widthRatio
        }else if selectedSegment == .payment{
            if indexPath.section == 1{
                return 80 * _widthRatio
            }else if indexPath.section == 3 && indexPath.row == banks.count{
                return 90 * _widthRatio
            }
            else{
                return 70 * _widthRatio
            }
        }else{
            return histroy.isEmpty ? 150 * _widthRatio : 98 * _widthRatio
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNonzeroMagnitude
        }else if section == 1{
            return 60 * _widthRatio
        }else if section == 2{
            return 90 * _widthRatio
        }else{
            return 70 * _widthRatio
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1{
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "profileHeader") as! HeaderView
            header.walletParent = self
            header.prepareUI(type: .walletHistory)
            return header
        }else if section == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! PaymentDetailCell
            cell.lblTitle.text = "PAYMENT DETAILS"
            cell.lblSubTitle.text = "Choose your payment method for completed swished items."
            return cell
        }else if section == 3{
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! PaymentDetailCell
            cell.lblTitle.text = "PAYMENT OUT"
            cell.lblSubTitle.text = "Cash out your rewards into your bank account."
            return cell
        }else{
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "paymentdetailCell") as! PaymentDetailCell
                cell.lblTotalAmount.text = "£\(_user.walletAmount)"
                return cell
        }else if selectedSegment == .payment{
            if indexPath.section == 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: "messgeCell") as! ConstrainedTableViewCell
                return cell
            }else if indexPath.section == 2{
                if indexPath.row == cards.count{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "btnCell") as! PaymentDetailCell
                    cell.btnAdd.setTitle("Add card details", for: .normal)
                    cell.btnAdd.tag = indexPath.section
                    cell.viewShadowBottom.constant = -10 * _widthRatio
                    return cell
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell") as! PaymentDetailCell
                    cell.imgCard.image = cards[indexPath.row].cardImg
                    cell.lblCardNo.text = cards[indexPath.row].cardNoStr
                    cell.lblCardName.text = cards[indexPath.row].cardType
                    return cell
                }
            }else{
                if indexPath.row == banks.count{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "btnCell") as! PaymentDetailCell
                    cell.btnAdd.tag = indexPath.section
                    cell.btnAdd.setTitle("Add bank account", for: .normal)
                    cell.viewShadowBottom.constant = 10 * _widthRatio
                    return cell
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "bankCell") as! PaymentDetailCell
                    cell.lblAccNo.text = banks[indexPath.row].makeString()
//                    cell.lblAccNo.text = banks[indexPath.row].accountNo
                    cell.lblAccName.text = banks[indexPath.row].accountName
                    cell.viewShadowBottom.constant = -10 * _widthRatio
                    return cell
                }
            }
        }else{
            if !histroy.isEmpty{
                let cell = tableView.dequeueReusableCell(withIdentifier: "histroyCell") as! HistroyCell
                cell.parent = self
                cell.tag = indexPath.row
                cell.prepareUI()
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "noHistroyCell") as! NOItemCell
                cell.lblMessage.text = "No history found"
                return cell
            }
        }
    }
}

// MARK: - Webcall Method
extension WalletDetailVC{
    
    func getWalletHistroy(){
        let dict : [String : Any] = ["limit":self.loadMore.limit,"start": self.loadMore.offset]
        if !referesh.isRefreshing && loadMore.index == 0{
            self.showCentralSpinner()
        }
        loadMore.isLoading = true
        KPWebCall.call.getHistroy(param: dict) { (json, flag) in
            self.loadMore.isLoading = false
            self.referesh.endRefreshing()
            self.hideCentralSpinner()
            if flag == 200 {
                if let dict = json as? NSDictionary{
                    if let histroyList = dict["wallet"] as? [NSDictionary]{
                        if self.loadMore.index == 0{
                            self.histroy = []
                        }
                        for histroy in histroyList{
                            self.histroy.append(WalletHistroy(dict: histroy))
                        }
                        if histroyList.isEmpty{
                            self.loadMore.isAllLoaded = true
                        }else{
                            self.loadMore.index += 1
                        }
                        self.tableView.reloadData()
                    }
                }else{
                    self.showError(data: json,yPos: _topMsgBarConstant)
                }
            }else{
                self.showError(data: json,yPos: _topMsgBarConstant)
            }
        }
    }
    
    func getBankList(){
        if !referesh.isRefreshing{
            self.showCentralSpinner()
        }
        KPWebCall.call.getBanksList(){ (json, status) in
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
                self.showError(data: json,yPos: _topMsgBarConstant)
            }
            self.tableView.reloadData()
        }
    }

    
    func getCardList() {
        if !_user.stripeCustomerId.isEmpty{
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
            self.referesh.endRefreshing()
            self.hideCentralSpinner()
        }
    }
}
