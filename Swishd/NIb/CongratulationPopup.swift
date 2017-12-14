
import Foundation

class CongratulationPopup: ConstrainedView {
    
    //MARK:- IBOutlets
    @IBOutlet var imgOfferUser: UIImageView!
    @IBOutlet var lblAcceptedMessage: UILabel!
    @IBOutlet var lblContactMessage: UILabel!
    @IBOutlet var lblUsername: UILabel!
    @IBOutlet var vwBackground: UIView!
    
    //MARK:- IBActions
    
    @IBAction func cancelTap(sender: UIButton){
        selectionBlock!()
        removeViewWithAnimation()
    }
    
    @IBAction func viewActivityTap(sender: UIButton){
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
    class func instantiateCongratulationViewFromNib(withView view: UIView, swishr: OtherUser) -> CongratulationPopup {
        let obj = Bundle.main.loadNibNamed("CongratulationPopup", owner: nil, options: nil)![0] as! CongratulationPopup
        _appDelegator.window?.addSubview(obj)
        obj.addConstraintToSuperView(lead: 0, trail: 0, top: 0, bottom: 0)
        obj.prepareUI(swishr: swishr)
        //Animation
        obj.layoutIfNeeded()
        obj.vwBackground.alpha = 0
        UIView.animate(withDuration: _pickerAnimationTime, animations: {
            obj.layoutIfNeeded()
            obj.vwBackground.alpha = 1
        })
        return obj
    }
    
    func prepareUI(swishr: OtherUser){
        lblUsername.text = swishr.userName
        imgOfferUser.kf.setImage(with: swishr.imageUrl)
        let str1 = NSAttributedString(string: "You have accepted ")
        let str2 = NSAttributedString(string: swishr.userName, attributes: [NSAttributedStringKey.font: UIFont.arialBold(size: 15 * _widthRatio)])
        let str3 = NSAttributedString(string: " as your swishr for this item.")
        let attributed = NSMutableAttributedString()
        attributed.append(str1)
        attributed.append(str2)
        attributed.append(str3)
        let string1 = NSAttributedString(string: "You can view your item activity and contact ")
        let string2 = NSAttributedString(string: swishr.userName, attributes: [NSAttributedStringKey.font: UIFont.arialBold(size: 15 * _widthRatio)])
        let string3 = NSAttributedString(string: " on your item page.")
        let attribuedStr = NSMutableAttributedString()
        attribuedStr.append(string1)
        attribuedStr.append(string2)
        attribuedStr.append(string3)
        lblAcceptedMessage.attributedText = attributed
        lblContactMessage.attributedText = attribuedStr
        
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
