//
//  EmailVerificationPopup.swift
//

import Foundation

class EmailVerificationPopup: ConstrainedView{
    
    //MARK:- IBOutlets
    @IBOutlet var vwBackground: UIView!
    @IBOutlet var lblMessage: UILabel!
    
    //MARK:- IBActions
    
    @IBAction func doneTap(sender: UIButton){
        selectionBlock!()
        removeViewWithAnimation()
    }
    
    //MARK:- Variables
    var selectionBlock:(()->())?
    
    //MARK:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK:- Other
    class func instantiateEmailVerificationViewFromNib(withView view: UIView, msg : String) -> EmailVerificationPopup {
        let obj = Bundle.main.loadNibNamed("EmailVerificationPopup", owner: nil, options: nil)![0] as! EmailVerificationPopup
        _appDelegator.window?.addSubview(obj)
        obj.lblMessage.text = msg
        obj.addConstraintToSuperView(lead: 0, trail: 0, top: 0, bottom: 0)
        //Animation
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
