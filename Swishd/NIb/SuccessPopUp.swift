//
//  SuccessPopUp.swift

import Foundation

class SuccessPopUp: ConstrainedView{
   
    //MARK:- IBOutlets
    @IBOutlet var vwBackground: UIView!
    
    //MARK:- IBActions
    
    @IBAction func confirmTap(sender: UIButton){
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
    class func instantiateSuccessPopupViewFromNib(withView view: UIView) -> SuccessPopUp {
        let obj = Bundle.main.loadNibNamed("SuccessPopUp", owner: nil, options: nil)![0] as! SuccessPopUp
        _appDelegator.window?.addSubview(obj)
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
