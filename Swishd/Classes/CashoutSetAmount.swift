//
//  CashOutVC.swift
//  Swishd
//

import UIKit

struct Wallet{
    var cashOutamount: Int32 = 0
    var isOwnAmount: Bool = false
}

class CashOutCell: ConstrainedTableViewCell, UITextFieldDelegate{
    
    @IBOutlet weak var tfAmount: UITextField!
    @IBOutlet weak var btnSetAmount: UIButton!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet var toolBar: UIToolbar!
    weak var parent: CashoutSetAmount!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareUI(){
        tfAmount.inputAccessoryView = toolBar
        tfAmount.isUserInteractionEnabled = true
        tfAmount.tintColor = UIColor.swdThemeRedColor()
        tfAmount.keyboardType = .decimalPad
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
                parent.walletData.cashOutamount = amount.int32Value
            }else{
                parent.walletData.cashOutamount = 0
            }
        }
    }
}

class CashoutSetAmount: ParentViewController {
    
    var walletData = Wallet()
    var banks: [Bank]!

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        prepareForkeyboardNotification()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "charitySegue"{
            let vc = segue.destination as! CashoutChooseMethod
            vc.wallet = walletData
            vc.banks = self.banks
        }
    }
}

// MARK: - UI & Utility Methods
extension CashoutSetAmount{
    
    func prepareUI()  {
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
        tableView.contentInset  = UIEdgeInsets(top: 5 * _widthRatio, left: 0, bottom: 10 * _widthRatio, right: 0)
    }
}

// MARK: - Button Action
extension CashoutSetAmount{

    @IBAction func btnSetAmountAction(_ sender: UIButton){
        walletData.isOwnAmount = !walletData.isOwnAmount
        tableView.reloadData()
    }
    
    @IBAction func btnCashOutAction(_ sender: UIButton){
        if walletData.isOwnAmount {
            if walletData.cashOutamount == 0{
                _ = ValidationToast.showStatusMessage(message: kChooseCashOutamount,yCord: _topMsgBarConstant, inView: self.view)
            }else if walletData.cashOutamount > _user.walletAmount{
                _ = ValidationToast.showStatusMessage(message: kLessCashOutamount,yCord: _topMsgBarConstant, inView: self.view)
            }else{
                performSegue(withIdentifier: "charitySegue", sender: nil)
            }
        }else{
            performSegue(withIdentifier: "charitySegue", sender: nil)
        }
    }
    
    @IBAction func toolBarDoneTap(_ sender: UIBarButtonItem){
        self.view.endEditing(true)
    }
}

// MARK: - Tableview Method
extension CashoutSetAmount{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 163 * _widthRatio : 150 * _widthRatio
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            if !walletData.isOwnAmount{
                let cell = tableView.dequeueReusableCell(withIdentifier: "defaultAmountCell") as! CashOutCell
                cell.lblAmount.text = "£\(_user.walletAmount)"
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ownAmountCell") as! CashOutCell
                cell.parent = self
                cell.prepareUI()
                return cell
            }
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "doneCashoutCell") as! CashOutCell
            if walletData.isOwnAmount{
                cell.btnSetAmount.setTitle("REVERT TO TOTAL AMOUNT", for: .normal)
            }else{
                cell.btnSetAmount.setTitle("SET OWN AMOUNT", for: .normal)
            }
            return cell
        }
    }
}

// MARK: - Keyboard Extension
extension CashoutSetAmount {
    func prepareForkeyboardNotification() {
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        if let kbSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset  = UIEdgeInsets(top: 5 * _widthRatio, left: 0, bottom: kbSize.height, right: 0)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        tableView.contentInset  = UIEdgeInsets(top: 5 * _widthRatio, left: 0, bottom: 10 * _widthRatio, right: 0)
    }
}
