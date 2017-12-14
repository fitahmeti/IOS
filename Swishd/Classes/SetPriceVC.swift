

import UIKit

class SetPriceVC: ParentViewController {

    /// IBOutlets
    @IBOutlet var tfInput: UITextField!
    @IBOutlet var tvTerms: LinkTextView!
    @IBOutlet var lblInsuranceFee: UILabel!
    @IBOutlet var toolBar: UIToolbar!
    
    /// Variables
    var selectionBlock: ((Double) -> ())?
    var price: Double?
    
    /// View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
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
}


// MARK: - UI & Utility Related
extension SetPriceVC {
    
    func prepareUI() {
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
        tfInput.inputAccessoryView = toolBar
        tvTerms.attributedText = getAttributeTextforTvTerms()
        if let _ = price{
            tfInput.text = "£\(price!.getFormattedValue(str: "0")!)"
        }
    }
    
    func getAttributeTextforTvTerms() -> NSAttributedString {
        let str: NSString = "By pressing accept, you agree\nto Swishd Terms & Conditions"
        let fullRange = str.range(of: str as String)
        let rangeOfTerm = str.range(of: "Terms & Conditions")
        let attributedString = NSMutableAttributedString(string: str as String)
        
        let para = NSMutableParagraphStyle()
        para.alignment = .center
        
        attributedString.addAttribute(NSAttributedStringKey.link, value: _termsUrl, range: rangeOfTerm)
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black.withAlphaComponent(0.8), range: fullRange)
        attributedString.addAttribute(NSAttributedStringKey.font, value: UIFont.arialRegular(size: 15 * _widthRatio), range: fullRange)
        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: para, range: fullRange)
        return attributedString
    }
}

// MARK: - Button Actions
extension SetPriceVC {

    @IBAction func doneBtnTap(_ sender: UIButton) {
        tfInput.resignFirstResponder()
    }
    
    @IBAction func btnDeclineTap(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAcceptTap(_ sender: UIButton) {
        if tfInput.text!.isEmpty{
            _ = ValidationToast.showStatusMessage(message: kEnterPrice, yCord: _topMsgBarConstant, inView: self.view)
        }else{
            guard let amount = _numberFormatter.number(from: tfInput.text!) else{
                return
            }
            if amount.doubleValue <= 50{
                _ = ValidationToast.showStatusMessage(message: kPriceValueMustGrater, yCord: _topMsgBarConstant, inView: self.view)
            }else{
                selectionBlock!(amount.doubleValue)
                _ = navigationController?.popViewController(animated: true)
            }
        }
    }
}

// MARK: - TextField Methods
extension SetPriceVC: UITextFieldDelegate{

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func textChange(_ sender: UITextField){
        if !sender.text!.isEmpty{
            let str = sender.text!.replacingOccurrences(of: "£", with: "")
            if str.isEmpty{
                sender.text = ""
            }else{
                sender.text = "£\(str)"
            }
        }
    }
}

