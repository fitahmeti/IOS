

import UIKit
class MobileVerificationVC: ParentViewController , UITextFieldDelegate {
    
    /// IBOutlets
    @IBOutlet weak var tfMobile : UITextField!
    @IBOutlet weak var tfCountryCode : UITextField!
    @IBOutlet var toolBar: UIToolbar!
    
    /// Variables
    var phoneNumber : String = ""
    var code: Country?
    var arrCountries = [Country]()
    var arrOfCode = [String]()
    var countryCodeBlock: ((Country) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getCountryList()
        callBackBlocks()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "verificationCodeSegue"{
            let vc = segue.destination as! VerificationCodeVC
            if let dict = sender as? [String: String]{
                vc.mobile = self.phoneNumber
                vc.verificationID = dict.values.first!
                vc.countryCode = code!.dialCode
            }
        }else if segue.identifier == "countryCodeSegue" {
            let dest = segue.destination as! CountryCodeVC
            dest.selectonBlock = countryCodeBlock
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

// MARK: - UI & Utility Methods
extension MobileVerificationVC{

    func prepareUI(){
        tfMobile.inputAccessoryView = toolBar
        tfMobile.delegate = self
    }
    
    func callBackBlocks() {
        countryCodeBlock = { (county) -> () in
            self.code = county
            self.tfCountryCode.text = county.dialCode
        }
    }
}

//MARK:- Button Action
extension MobileVerificationVC{
    
    @IBAction func toolBarDoneTap(_ sender: UIButton){
        tfMobile.resignFirstResponder()
    }
    
    @IBAction func btnSelectCountryClicked(){
        self.performSegue(withIdentifier: "countryCodeSegue", sender: nil)
    }
    
    @IBAction func btnNextAction(_ sender : UIButton){
        phoneNumber = tfMobile.text!
        if phoneNumber.isEmpty{
            _ = ValidationToast.showStatusMessage(message: kEnterMobile,yCord: _topMsgBarConstant, inView: self.view)
        }else if code == nil{
            _ = ValidationToast.showStatusMessage(message: kEnterCountryCode,yCord: _topMsgBarConstant, inView: self.view)
        }else{
            tfMobile.resignFirstResponder()
            self.showCentralSpinner()
            checkMobileNumberAvailable(cCode: code!.dialCode, mobile: phoneNumber, comp: { (isAvailable) in
                self.hideCentralSpinner()
                if isAvailable{
                    self.sendVerifiCode()
                }
            })
        }
    }
}

//MARK:- Other Methods
extension MobileVerificationVC{
    
    func sendVerifiCode(){
        if let phoneNumberUtil = NBPhoneNumberUtil.sharedInstance() {
            do {
                let regionCode = phoneNumberUtil.getRegionCode(forCountryCode: code!.dialCode.removeSpecial("+").integerValue! as NSNumber)
                let nbPhoneNumber = try phoneNumberUtil.parse(phoneNumber, defaultRegion: regionCode)
                if phoneNumberUtil.isValidNumber(nbPhoneNumber) {
                    showCentralSpinner()
                    let strPhoneNumber = String(format: "+%@%@", nbPhoneNumber.countryCode, nbPhoneNumber.nationalNumber)
                    PhoneAuthProvider.provider().verifyPhoneNumber(strPhoneNumber) { (verificationId: String?, error: Error?) in
                        if let verificationID = verificationId {
                            let dict: [String: String] = [strPhoneNumber : verificationID]
                            self.performSegue(withIdentifier: "verificationCodeSegue", sender: dict)
                            kprint(items: "verificationID : \(verificationID)")
                        }else if let error = error {
                            kprint(items: "error : \(error)")
                            _ = ValidationToast.showStatusMessage(message: error.localizedDescription,yCord: _topMsgBarConstant, inView: self.view)
                        }
                        self.hideCentralSpinner()
                    }
                }else{
                    _ = ValidationToast.showStatusMessage(message: kMobileInvalid,yCord: _topMsgBarConstant, inView: self.view)
                }
            } catch let err {
                kprint(items: "Error : \(err)")
                _ = ValidationToast.showStatusMessage(message: kMobileInvalid,yCord: _topMsgBarConstant, inView: self.view)
            }
        }
    }
}


// MARK: - Get country List
extension MobileVerificationVC{
    
    func checkMobileNumberAvailable(cCode: String, mobile: String, comp: @escaping (Bool) -> ()) {
        KPWebCall.call.isMobileNumberExist(code: cCode, mobile: mobile) { (json, status) in
            if status == 200{
                comp(true)
            }else{
                comp(false)
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
    
    func getCountryList()  {
        let contryPath = Bundle.main.path(forResource: "countries", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: contryPath))
        do {
            if let dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any], let list = dict["list"] as? [[String:Any]] {
                for countryInfo in list {
                    let cont = Country(dict: countryInfo as NSDictionary)
                    if cont.dialCode == "+44"{
                        self.code = cont
                        self.tfCountryCode.text = code?.dialCode
                    }
                }
            }
        } catch let error as NSError {
            kprint(items: "Error: \(error.localizedDescription)")
        }
    }
}
