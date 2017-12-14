//
//  BankPopup.swift

import Foundation

class BankPopup: ConstrainedView {
    //MARK:- IBOutlets
    @IBOutlet var lblAccName: UILabel!
    @IBOutlet var lblAccNo: UILabel!
    @IBOutlet var vwBackground: UIView!
    
    //MARK:- IBActions
    
    @IBAction func confirmTap(sender: UIButton){
        selectionBlock!(true)
        removeViewWithAnimation()
    }
    
    @IBAction func cancelTap(sender: UIButton){
        removeViewWithAnimation()
    }
    
    //MARK:- Variables
    var selectionBlock:((_ isDone: Bool)->())?
    
    //MARK:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK:- Other
    class func instantiateBankPopupViewFromNib(withView view: UIView, bank: Bank) -> BankPopup {
        let obj = Bundle.main.loadNibNamed("BankPopup", owner: nil, options: nil)![0] as! BankPopup
        _appDelegator.window?.addSubview(obj)
        obj.addConstraintToSuperView(lead: 0, trail: 0, top: 0, bottom: 0)
        //Animation
        obj.lblAccName.text = bank.accountName
        obj.lblAccNo.text = "\(bank.accountNo)"
        obj.layoutIfNeeded()
        obj.vwBackground.alpha = 0
        UIView.animate(withDuration: _pickerAnimationTime, animations: {
            obj.layoutIfNeeded()
            obj.vwBackground.alpha = 1
        })
        return obj
    }
    
    func removeViewWithAnimation(){
        UIView.animate(withDuration: _pickerAnimationTime, animations: {
            self.layoutIfNeeded()
            self.vwBackground.alpha = 0
        }) { (done) in
            self.removeFromSuperview()
        }
    }    
}
