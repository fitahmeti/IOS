

import UIKit

class VerificationCodeVC: ParentViewController {
    
    /// IBOutlets
    @IBOutlet weak var tfVerify : UITextField!
    @IBOutlet weak var lblMobile : UILabel!
    @IBOutlet weak var btnEnter : UIButton!
    @IBOutlet var toolBar: UIToolbar!
    
    /// Variables
    var mobile: String!
    var strCode: String = ""
    var verificationID: String!
    var countryCode  : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tfVerify.inputAccessoryView = toolBar
        lblMobile.text = countryCode + mobile
        prepareCodeArray()
        validateCode()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK:- Button Action
extension VerificationCodeVC{
    
    @IBAction func toolBarDoneTap(_ sender: UIButton){
        tfVerify.resignFirstResponder()
    }
    
    @IBAction func btnEnterAction(_ sender : UIButton){
        signInwithFirebase()
    }
    
    @IBAction func btnResendCodeAction(_ sender : UIButton){
        self.view.endEditing(true)
        prepareCodeArray()
        validateCode()
        resendCode()
    }
    
    func signInwithFirebase(){
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID!,
            verificationCode: strCode)
        self.showCentralSpinner()
        Auth.auth().signIn(with: credential) { (user, error) in
            self.hideCentralSpinner()
            if let _ = user {
                self.verifyMobileNumber()
            }else if let err = error{
                _ = ValidationToast.showStatusMessage(message: err.localizedDescription, yCord: _topMsgBarConstant, inView: self.view)
            }
        }
    }
}

// MARK: - Textfield delegate
extension VerificationCodeVC: UITextFieldDelegate{
    
    @IBAction func tfCharacterChange(_ sender: UITextField){
        strCode = sender.text!.trimWhiteSpace()
        if !strCode.isEmpty{
            let last = String(strCode.last!)
            let width = last.WidthWithNoConstrainedHeight(font: UIFont.systemFont(ofSize: 25 * _widthRatio))
            let dif = (16 * _widthRatio) - width
            let range = NSMakeRange(strCode.count - 1, 1)
            sender.addCharactersSpacingWithFont(spacing: ((46 * _widthRatio) + dif), text: strCode,range: range)
        }
        validateCode()
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let str = textField.text! + string
        if str.count > 6{
            return false
        }
        let cs = NSCharacterSet(charactersIn: "0123456789").inverted
        let filStr = string.components(separatedBy: cs).joined(separator: "")
        return string == filStr
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func prepareCodeArray() {
        btnEnter.isEnabled = false
        strCode = ""
        tfVerify.text = ""
        tfVerify.becomeFirstResponder()
    }
    
    func validateCode(){
        let codeStr = strCode.trimmedString()
        btnEnter.isEnabled = codeStr.count == 6
        kprint(items: codeStr)
    }
}

//MARK:- AlerView Method
extension VerificationCodeVC{
    
    func showAlertView(){
        tfVerify.resignFirstResponder()
        let str = countryCode+mobile
        _ = ResentOTPPopUp.instantiateEmailVerificationViewFromNib(withView: self.view, msg: "We have sent a new code to\n\(str.description)")
    }
    
    func resendCode(){
        showCentralSpinner()
        PhoneAuthProvider.provider().verifyPhoneNumber(countryCode+mobile) { (verificationId: String?, error: Error?) in
            if let verificationID = verificationId {
                self.verificationID = verificationID
                self.showAlertView()
                kprint(items: "verificationID : \(verificationID)")
            }else if let error = error {
                kprint(items: "error : \(error)")
                _ = ValidationToast.showStatusMessage(message: error.localizedDescription, yCord: _topMsgBarConstant, inView: self.view)
            }
            self.hideCentralSpinner()
        }
    }
}

//MARK:- ApiCall
extension VerificationCodeVC{
    
    func verifyMobileNumber(){
        let dict : [String : Any] = ["mobile" :mobile ,"countryCode" : countryCode ]
        showCentralSpinner()
        KPWebCall.call.verifyMobile(param: dict) { (json, flag) in
            self.hideCentralSpinner()
            if flag == 200 {
                if let _ = json as? NSDictionary{
                    _user.isMobileVerify = true
                    _appDelegator.saveContext()
                    _ = self.navigationController?.popToRootViewController(animated: true)
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
}

