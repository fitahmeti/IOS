//
//  ConfirmBankPopup.swift

import Foundation

class ConfirmBankPopup: ConstrainedView{
    //MARK:- IBOutlets
    @IBOutlet var lblSortCode: UILabel!
    @IBOutlet var lblAccNo: UILabel!
    @IBOutlet var vwBackground: UIView!
    
    //MARK:- IBActions
    
    @IBAction func confirmTap(sender: UIButton){
        selectionBlock!()
        removeViewWithAnimation()
    }
    
    @IBAction func cancelTap(sender: UIButton){
        removeViewWithAnimation()
    }
    
    //MARK:- Variables
    var selectionBlock:(()->())?
    
    //MARK:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK:- Other
    class func instantiateConfirmBankPopupViewFromNib(withView view: UIView, bank: BankUserData) -> ConfirmBankPopup {
        let obj = Bundle.main.loadNibNamed("ConfirmBankPopup", owner: nil, options: nil)![0] as! ConfirmBankPopup
        _appDelegator.window?.addSubview(obj)
        obj.addConstraintToSuperView(lead: 0, trail: 0, top: 0, bottom: 0)
        obj.prepareUI(bank: bank)
        //Animation
        obj.layoutIfNeeded()
        obj.vwBackground.alpha = 0
        UIView.animate(withDuration: _pickerAnimationTime, animations: {
            obj.layoutIfNeeded()
            obj.vwBackground.alpha = 1
        })
        return obj
    }
    
    func prepareUI(bank: BankUserData){
        lblAccNo.text = bank.arrField[1].value
        lblSortCode.text = bank.arrField[2].value
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
