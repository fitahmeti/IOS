

import UIKit

class LoginVC: SocialViewController {

    var data = EntryData(typ: .login)
    
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

    override func connectToFacebook() {
        connectToFacebookForLoginReg()
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
extension LoginVC {

    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 200 * _widthRatio, left: 0, bottom: 10 * _widthRatio, right: 0)
    }
}

// MARK: - IBActions
extension LoginVC {
    
    @IBAction func btnEntryAction(_ sender: UIButton) {
        let tupple = data.isDataValid()
        if !tupple.0 {
            _ = ValidationToast.showStatusMessage(message: tupple.1,yCord: _topMsgBarConstant, inView: self.view)
        }else{
            self.view.endEditing(true)
            self.showCentralSpinner()
            loginUser(param: data.getParamDict(), comp: { (success) in
                if success{
                    self.getUserProfile(comp: { (done) in
                        self.hideCentralSpinner()
                        if done{
                            _appDelegator.prepareForLogin()
                            self.performSegue(withIdentifier: "homeSegue", sender: nil)
                        }
                    })
                }else{
                    self.hideCentralSpinner()
                }
            })
        }
    }
    
    @IBAction func btnForgotPassAction(_ sender: UIButton){
        performSegue(withIdentifier: "forgotPassSegue", sender: self)
    }
    
    @IBAction func btnFbLoginTap(_ sender: UIButton) {
        self.connectToFacebook()
    }
    
    @IBAction func btnGoogleLoginTap(_ sender: UIButton) {
        self.loginRegUserWithGoogle()
    }
}

// MARK: - TableView
extension LoginVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.fields.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == data.fields.count{
            return 235 * _widthRatio
        }else{
            return 90 * _widthRatio
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == data.fields.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "btnsCell") as! ConstrainedTableViewCell
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "tfCell", for: indexPath) as! EntryCell
            cell.tag = indexPath.row
            cell.type = data.type
            cell.parentLogin = self
            cell.prepareLoginUI()
            return cell
        }
    }
}

// MARK: - Keyboard Extension
extension LoginVC {
    func prepareForkeyboardNotification() {
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        if let kbSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 200 * _widthRatio, left: 0, bottom: kbSize.height, right: 0)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        tableView.contentInset = UIEdgeInsets(top: 200 * _widthRatio, left: 0, bottom: 10 * _widthRatio, right: 0)
    }
}

