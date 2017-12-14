//
//  AcceptOfferPopup.swift
//  Swishd

import Foundation

class AcceptOfferPopup: ConstrainedView{

    //MARK:- IBOutlets
    @IBOutlet var imgOfferUser: UIImageView!
    @IBOutlet var lblOfferName: UILabel!
    @IBOutlet var vwBackground: UIView!
    
    //MARK:- IBActions
    
    @IBAction func cancelTap(sender: UIButton){
        removeViewWithAnimation()
    }
    
    @IBAction func acceptTap(sender: UIButton){
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
    class func instantiateAcceptOfferViewFromNib(withView view: UIView, offerImage : URL?, offerName: String) -> AcceptOfferPopup {
        let obj = Bundle.main.loadNibNamed("AcceptOfferPopup", owner: nil, options: nil)![0] as! AcceptOfferPopup
        _appDelegator.window?.addSubview(obj)
        obj.lblOfferName.text = offerName
        obj.imgOfferUser.kf.setImage(with: offerImage)
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
