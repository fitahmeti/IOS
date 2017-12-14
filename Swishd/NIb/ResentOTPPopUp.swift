//
//  ResentOTPPopUp.swift
//  Swishd
//
//  Created by Yudiz on 12/4/17.
//

import Foundation
import UIKit

class ResentOTPPopUp: ConstrainedView {
    
    //MARK:- IBOutlets
    @IBOutlet var vwBackground: UIView!
    @IBOutlet var lblMessage: UILabel!
    
    //MARK:- IBActions
    
    @IBAction func doneTap(sender: UIButton){
        selectionBlock?()
        removeViewWithAnimation()
    }
    
    //MARK:- Variables
    var selectionBlock:(()->())?
    
    //MARK:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK:- Other
    class func instantiateEmailVerificationViewFromNib(withView view: UIView, msg : String) -> ResentOTPPopUp {
        let obj = Bundle.main.loadNibNamed("ResentOTPPopUp", owner: nil, options: nil)![0] as! ResentOTPPopUp
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
