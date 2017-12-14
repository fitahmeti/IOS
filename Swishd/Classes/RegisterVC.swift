

import UIKit

class RegisterVC: SocialViewController {

    var data = EntryData(typ: .register)
    
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
    
    override func connectToFacebook() {
        connectToFacebookForLoginReg()
    }
}

// MARK: - UI & Utility Related
extension RegisterVC {
    
    func prepareUI() {
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func getAttributeTextforTvTerms() -> NSAttributedString {
        let str: NSString = "By pressing signup, you agree\nto Swish's Terms & Conditions"
        let fullRange = str.range(of: str as String)
        let rangeOfTerm = str.range(of: "Terms & Conditions")
        let attributedString = NSMutableAttributedString(string: str as String)
        
        let para = NSMutableParagraphStyle()
        para.alignment = .center
        
        attributedString.addAttribute(NSAttributedStringKey.link, value: _termsUrl, range: rangeOfTerm)
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black.withAlphaComponent(0.5), range: fullRange)
        attributedString.addAttribute(NSAttributedStringKey.font, value: UIFont.arialRegular(size: 17 * _widthRatio), range: fullRange)
        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: para, range: fullRange)
        return attributedString
    }
}

// MARK: - IBActions
extension RegisterVC {
    
    @IBAction func btnEntryAction(_ sender: UIButton) {
        let tupple = data.isDataValid()
        if !tupple.0 {
            _ = ValidationToast.showStatusMessage(message: tupple.1,yCord: _topMsgBarConstant, inView: self.view)
        }else{
            self.view.endEditing(true)
            self.showCentralSpinner()
            self.registerUser(param: data.getParamDict(), comp: { (success) in
                self.hideCentralSpinner()
            })
        }
    }
    
    @IBAction func btnFbLoginTap(_ sender: UIButton) {
        self.connectToFacebook()
    }
    
    @IBAction func btnGoogleLoginTap(_ sender: UIButton) {
        self.loginRegUserWithGoogle()
    }
}

// MARK: - TableView
extension RegisterVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.fields.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == data.fields.count{
            return 145 * _widthRatio
        }else{
            return 90 * _widthRatio
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: EntryCell
        if indexPath.row == data.fields.count{
            cell = tableView.dequeueReusableCell(withIdentifier: "btnsCell", for: indexPath) as! EntryCell
            cell.tvTerms.attributedText = getAttributeTextforTvTerms()
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "tfCell", for: indexPath) as! EntryCell
            cell.tag = indexPath.row
            cell.type = data.type
            cell.parentReg = self
            cell.prepareRegUI()
        }
        return cell
    }
}

// MARK: - Keyboard Extension
extension RegisterVC {
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
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

// MARK: - WebCall Methods
extension RegisterVC {

    func registerUser(param: [String: Any], comp: @escaping (Bool) -> ()) {
        KPWebCall.call.registerUser(param: param) { (json, status) in
            if status == 200{
                if let dict = json as? NSDictionary{
                    self.showEmailVerificationPopup(msg: dict.getStringValue(key: "message"))
                    comp(true)
                }else{
                    comp(false)
                    self.showError(data: json,yPos: _topMsgBarConstant)
                }
            }else{
                comp(false)
                self.showError(data: json,yPos: _topMsgBarConstant)
            }
        }
    }
}
