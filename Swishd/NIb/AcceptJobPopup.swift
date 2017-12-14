//
//  AcceptJobPopup.swift
//  Swishd
//

import Foundation

class AcceptJobPopup: ConstrainedView{

    
    //MARK:- IBOutlets
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var lblUsername: UILabel!
    @IBOutlet var llMessage: UILabel!
    @IBOutlet var vwBackground: UIView!
    
    //MARK:- IBActions
    
    @IBAction func okTap(sender: UIButton){
        removeViewWithAnimation()
    }
    
    //MARK:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK:- Other
    class func instantiateAcceptJobPopupViewFromNib(withView view: UIView, jobSender: OtherUser) -> AcceptJobPopup {
        let obj = Bundle.main.loadNibNamed("AcceptJobPopup", owner: nil, options: nil)![0] as! AcceptJobPopup
        _appDelegator.window?.addSubview(obj)
        obj.addConstraintToSuperView(lead: 0, trail: 0, top: 0, bottom: 0)
        obj.setUserDetail(user: jobSender)
        //Animation
        obj.layoutIfNeeded()
        obj.vwBackground.alpha = 0
        UIView.animate(withDuration: _pickerAnimationTime, animations: {
            obj.layoutIfNeeded()
            obj.vwBackground.alpha = 1
        })
        return obj
    }
    
    func setUserDetail(user: OtherUser){
        lblUsername.text = user.userName
        imgUser.kf.setImage(with: user.imageUrl)
        let str1 = NSAttributedString(string: "Swish will let you know ")
        let str2 = NSAttributedString(string: user.userName + "'s", attributes: [NSAttributedStringKey.font: UIFont.arialBold(size: 15 * _widthRatio)])
        let str3 = NSAttributedString(string: " response in your notification. you can keep an eye on this job in your profile.")
        let attributed = NSMutableAttributedString()
        attributed.append(str1)
        attributed.append(str2)
        attributed.append(str3)
        llMessage.attributedText = attributed
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
