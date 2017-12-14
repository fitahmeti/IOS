
import UIKit

class ForgotPassVC: ParentViewController {

    var data = EntryData(typ: .forgotPass)
    
    /// View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        prepareForkeyboardNotification()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        _defaultCenter.removeObserver(self)
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

// MARK: - UI Related
extension ForgotPassVC {
    
    func prepareUI() {
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10 * _widthRatio, right: 0)
    }
}

// MARK: - IBActions
extension ForgotPassVC {
    
    @IBAction func btnEntryAction(_ sender: UIButton) {
        let tupple = data.isDataValid()
        if !tupple.0 {
            _ = ValidationToast.showStatusMessage(message: tupple.1,yCord: _topMsgBarConstant, inView: self.view)
        }else{
            self.view.endEditing(true)
            self.showCentralSpinner()
            forgotPassword(comp: { (success) in
                self.hideCentralSpinner()
                if success{
                    self.showEmailVerificationPopup(msg: "Please check you inbox to activate account")
                }
            })
        }
    }
}

// MARK: - TableView
extension ForgotPassVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.fields.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == data.fields.count{
            return 110 * _widthRatio
        }else{
            return 150 * _widthRatio
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: EntryCell
        if indexPath.row == data.fields.count{
            cell = tableView.dequeueReusableCell(withIdentifier: "btnCell", for: indexPath) as! EntryCell
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "forgotPassCell", for: indexPath) as! EntryCell
            cell.tag = indexPath.row
            cell.type = data.type
            cell.parentForgot = self
            cell.prepareForgotUI()
        }
        return cell
    }
}

// MARK: - Keyboard Extension
extension ForgotPassVC {
    func prepareForkeyboardNotification() {
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        if let kbSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10 * _widthRatio, right: 0)
    }
}

// MARK: - WebCall Methods
extension ForgotPassVC {
    
    func forgotPassword(comp: @escaping (Bool) -> ()) {
        KPWebCall.call.forgotPassword(param: data.getParamDict()) { (json, status) in
            if status == 200 {
                self.showSucMsg(data: json,yPos: _topMsgBarConstant)
                comp(true)
            }else{
                self.showError(data: json,yPos: _topMsgBarConstant)
                comp(false)
            }
        }
    }
}


