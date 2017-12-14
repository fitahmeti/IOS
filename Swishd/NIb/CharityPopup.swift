//
//  CharityPopup.swift

import Foundation

class CharityPopup: ConstrainedView{
    
    //MARK:- IBOutlets
    @IBOutlet var imgCharity: UIImageView!
    @IBOutlet var lblDonatedAmount: UILabel!
    @IBOutlet var vwBackground: UIView!
    
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
    class func instantiateCharityPopupViewFromNib(withView view: UIView, charity: Charity, amount: Int32) -> CharityPopup {
        let obj = Bundle.main.loadNibNamed("CharityPopup", owner: nil, options: nil)![0] as! CharityPopup
        _appDelegator.window?.addSubview(obj)
        obj.addConstraintToSuperView(lead: 0, trail: 0, top: 0, bottom: 0)
        //Animation
        obj.lblDonatedAmount.text = "£\(amount)"
        obj.imgCharity.kf.setImage(with: charity.imgUrl)
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

