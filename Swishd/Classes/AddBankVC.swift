

import UIKit

struct UserField {
    var placeholder = ""
    var title = ""
    var value = ""
    var keyName = ""
}

class BankUserData: NSObject{
    
    var arrField = [UserField]()
    
    override init() {
        var tf1 = UserField()
        tf1.title = "Accont Holders Name"
        tf1.keyName = "sAccountName"
        arrField.append(tf1)
        
        var tf2 = UserField()
        tf2.title = "Accont Number"
        tf2.keyName = "sAccountNumber"
        arrField.append(tf2)
        
        var tf3 = UserField()
        tf3.title = "Sort Code"
        tf3.keyName = "sSortCode"
        arrField.append(tf3)
    }
    
    func paramDictionaty() -> [String: String]{
        var dict = [String: Any]()
        for obj in arrField {
            dict[obj.keyName] = obj.value
        }
        return dict as! [String : String]
    }
    
    func isValidBankData() -> (valid: Bool, error: String) {
        
        var result = (valid: true, error: "")
        if String.validateStringValue(str: arrField[0].value){
            result.valid = false
            result.error = kenterAccountholderName
            return result
        }
        
        if  String.validateStringValue(str: arrField[1].value){
            result.valid = false
            result.error = kEnterAccountNo
            return result
        }else if !(arrField[1].value.validateBankAccNo()) {
            result.valid = false
            result.error = kValidAccountNo
            return result
        }
        
        if String.validateStringValue(str: arrField[2].value){
            result.valid = false
            result.error = kEnterSortcode
            return result
        }else if arrField[2].value.count < 6{
            result.valid = false
            result.error = kValidSortcode
            return result
        }
        return result
    }
}

class AddBankCell: ConstrainedTableViewCell, UITextFieldDelegate{
    
    @IBOutlet var tfData: UITextField!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var toolBar: UIToolbar!
    var bankAccountBlock: ((UserField) -> ())?
    weak var parent: AddBankVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        callBackBlocks()
    }
    
    func prepareUI(){
        tfData.keyboardType = .asciiCapable
        tfData.returnKeyType = .next
        tfData.autocorrectionType = .no
        tfData.autocapitalizationType = .none
        if self.tag == 0{
            tfData.autocapitalizationType = .words
            tfData.autocorrectionType = .yes
        }else if self.tag == 1 {
            tfData.inputAccessoryView = toolBar
            tfData.keyboardType = .decimalPad
        }else if self.tag == 2{
            tfData.returnKeyType = .done
        }
        lblTitle.text = parent.bankData.arrField[self.tag].title
        tfData.text = parent.bankData.arrField[self.tag].value
    }
    
    func callBackBlocks() {
        bankAccountBlock = { (bank) -> () in
            self.tfData.text = bank.value
        }
    }
    
    @IBAction func textChanged(_ sender: UITextField){
        parent.bankData.arrField[self.tag].value = sender.text!
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next{
            parent.scrollToIndex(index: self.tag + 1)
            let cell = parent.tableViewCell(index: self.tag + 1) as! AddBankCell
            cell.tfData.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if self.tag == 1{
            let str = textField.text! + string
            if str.count > 15{
                return false
            }
            
            let cs = NSCharacterSet(charactersIn: "0123456789").inverted
            let filStr = string.components(separatedBy: cs).joined(separator: "")
            return string == filStr
        }
        return true
    }
}

protocol AddBankDelegate {
    func addBank(bank: Bank)
}

class AddBankVC: ParentViewController {
    
    var bankData = BankUserData()
    var delegate: AddBankDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        prepareForkeyboardNotification()
        // Do any additional setup after loading the view.
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
    
    func prepareUI(){
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
        tableView.contentInset = UIEdgeInsets(top: 5 * _widthRatio, left: 0, bottom: 10 * _widthRatio, right: 0)
    }
    
}

// MARK: - Button Action
extension AddBankVC{
    
    @IBAction func btnSaveAction(_ sender: UIButton){
        if bankData.isValidBankData().valid{
//            confiremPopup()
            self.view.endEditing(true)
            showConfirmationPopup()
        }else{
            _ = ValidationToast.showStatusMessage(message: bankData.isValidBankData().error,yCord: _topMsgBarConstant, inView: self.view)
        }
    }
        
    @IBAction func toolBarDoneTap(_ sender: UIBarButtonItem){
        self.view.endEditing(true)
    }
}

// MARK: - Tableview  Method
extension AddBankVC{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bankData.arrField.count + 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 60 * _widthRatio : 90 * _widthRatio
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == bankData.arrField.count + 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "btnSaveCell") as! ConstrainedTableViewCell
            return cell
        }else if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell") as! AddBankCell
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "addBankDetailCell") as! AddBankCell
            cell.tag = indexPath.row - 1
            cell.parent = self
            cell.prepareUI()
            return cell
        }
    }
}

// MARK: - Webacall Method
extension AddBankVC{
    
    func addBankDetail(){
        self.showCentralSpinner()
        KPWebCall.call.addBankAccount(param: bankData.paramDictionaty()){ (json, status) in
            self.hideCentralSpinner()
            if status == 200{
                if let bank = (json as? NSDictionary)?["data"] as? NSDictionary{
                    self.delegate?.addBank(bank: Bank(dict: bank))
                    self.navigationController?.popViewController(animated: true)
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
}

// MARK: - Alertview method
extension AddBankVC{
    
    func showConfirmationPopup(){
        let popup = ConfirmBankPopup.instantiateConfirmBankPopupViewFromNib(withView: self.view, bank: bankData)
        popup.selectionBlock = {
            self.addBankDetail()
        }
    }

    func confiremPopup(){
        let alert = UIAlertController(title: "Verification", message: "Please Verify Your Account Number and sort code below.\n\n Account No.: \(bankData.arrField[1].value)\n Sort Code: \(bankData.arrField[2].value)", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (confirm) in
            self.addBankDetail()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(confirmAction)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Keyboard Extension
extension AddBankVC {
    func prepareForkeyboardNotification() {
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        if let kbSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 5 * _widthRatio, left: 0, bottom: kbSize.height, right: 0)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        tableView.contentInset = UIEdgeInsets(top: 5 * _widthRatio, left: 0, bottom: 10 * _widthRatio, right: 0)
    }
}

