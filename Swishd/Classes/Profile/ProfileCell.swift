

import Foundation
import UIKit


class ProfileCell: ConstrainedTableViewCell{
    
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblJoinDate: UILabel!
    @IBOutlet var lblWalletAmount: UILabel!
    @IBOutlet var imgUserProfile: UIImageView!
    @IBOutlet var vwShadow: UIView!
    
    // Statastic
    @IBOutlet var lblState1: UILabel!
    @IBOutlet var lblState2: UILabel!
    @IBOutlet var lblState3: UILabel!
    @IBOutlet var lblState4: UILabel!
    
    // Verification
    
    @IBOutlet var imgArrow: UIImageView!
    @IBOutlet var vwEmail: UIView!
    @IBOutlet var vwMobile: UIView!
    @IBOutlet var vwFb: UIView!
    @IBOutlet var vwLnkdin: UIView!
    @IBOutlet var vwId: UIView!
    
    @IBOutlet var imgVEmail: UIImageView!
    @IBOutlet var imgVMobile: UIImageView!
    @IBOutlet var imgVFb: UIImageView!
    @IBOutlet var imgVLnkdin: UIImageView!
    @IBOutlet var imgVId: UIImageView!
    
    @IBOutlet var lblEmail: UILabel!
    @IBOutlet var lblMobile: UILabel!
    @IBOutlet var lblFb: UILabel!
    @IBOutlet var lblLnkdIn: UILabel!
    @IBOutlet var lblId: UILabel!
    
    weak var parent: ProfileVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
        
    func resetShadow(){
        if parent.isShowVerification{
            let rect = CGRect(x: 0, y: 0, width: vwShadow.frame.size.width, height: 345 * _widthRatio)
            vwShadow.layer.shadowPath = UIBezierPath(rect: rect).cgPath
        }else{
            let rect = CGRect(x: 0, y: 0, width: vwShadow.frame.size.width, height: 252 * _widthRatio)
            vwShadow.layer.shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
    
    func prepareUI(){
        lblUserName.text = _user.userName
        lblJoinDate.text = "joined \(Date.getLocalString(from: _user.joinDate, format: "yyyy"))"
        lblWalletAmount.text = "£\(_user.walletAmount)"
        imgUserProfile.kf.setImage(with: _user.imageUrl)
        
        lblState1.text = "\(_user.completeSwishd.getFormattedValue(str: "0")!)"
        lblState2.text = "\(_user.completeSwishdPer.getFormattedValue(str: "0")!)%"
        lblState3.text = "\(_user.completePost.getFormattedValue(str: "0")!)"
        lblState4.text = "\(_user.completePostPer.getFormattedValue(str: "0")!)%"
        
        if parent.jobType == .sender{
            lblState1.textColor = UIColor.hexStringToUIColor(hexStr: "B3B3B3")
            lblState2.textColor = UIColor.hexStringToUIColor(hexStr: "B3B3B3")
            lblState3.textColor = UIColor.hexStringToUIColor(hexStr: "0585CA")
            lblState4.textColor = UIColor.hexStringToUIColor(hexStr: "0585CA")
        }else{
            lblState3.textColor = UIColor.hexStringToUIColor(hexStr: "B3B3B3")
            lblState4.textColor = UIColor.hexStringToUIColor(hexStr: "B3B3B3")
            lblState1.textColor = UIColor.hexStringToUIColor(hexStr: "0585CA")
            lblState2.textColor = UIColor.hexStringToUIColor(hexStr: "0585CA")
        }
    }
    
    func prepareVerifyUI() {
        
        imgVEmail.isHidden = !_user.isEmailVerify
        imgVMobile.isHidden = !_user.isMobileVerify
        imgVFb.isHidden = !_user.isFbVerify
        imgVLnkdin.isHidden = !_user.isLinkdinVerify
        imgVId.isHidden = !_user.isProofVerify
        
        vwEmail.backgroundColor = .hexStringToUIColor(hexStr: "E5E5E5")
        vwMobile.backgroundColor = .hexStringToUIColor(hexStr: "E5E5E5")
        vwFb.backgroundColor = .hexStringToUIColor(hexStr: "E5E5E5")
        vwLnkdin.backgroundColor = .hexStringToUIColor(hexStr: "E5E5E5")
        vwId.backgroundColor = .hexStringToUIColor(hexStr: "E5E5E5")
        
        lblEmail.textColor = .hexStringToUIColor(hexStr: "323232")
        lblMobile.textColor = .hexStringToUIColor(hexStr: "323232")
        lblFb.textColor = .hexStringToUIColor(hexStr: "323232")
        lblLnkdIn.textColor = .hexStringToUIColor(hexStr: "323232")
        lblId.textColor = .hexStringToUIColor(hexStr: "323232")
        lblEmail.alpha = 0.4
        lblMobile.alpha = 0.4
        lblFb.alpha = 0.4
        lblLnkdIn.alpha = 0.4
        lblId.alpha = 0.4
        
        imgArrow.image = parent.isShowVerification ? UIImage(named: "ic_up_arrow") : UIImage(named: "ic_down_arrow")

        if _user.isEmailVerify{
            vwEmail.backgroundColor = .swdBlueColor()
            lblEmail.textColor = .hexStringToUIColor(hexStr: "373737")
            lblEmail.alpha = 1
        }
        if _user.isMobileVerify{
            vwMobile.backgroundColor = .swdBlueColor()
            lblMobile.textColor = .hexStringToUIColor(hexStr: "373737")
            lblMobile.alpha = 1
        }
        if _user.isFbVerify{
            vwFb.backgroundColor = .swdBlueColor()
            lblFb.textColor = .hexStringToUIColor(hexStr: "373737")
            lblFb.alpha = 1
        }
        if _user.isLinkdinVerify{
            vwLnkdin.backgroundColor = .swdBlueColor()
            lblLnkdIn.textColor = .hexStringToUIColor(hexStr: "373737")
            lblLnkdIn.alpha = 1
        }
        if _user.isProofVerify{
            vwId.backgroundColor = .swdBlueColor()
            lblLnkdIn.textColor = .hexStringToUIColor(hexStr: "373737")
            lblId.alpha = 1
        }
    }
}

class SegmentCell : ConstrainedTableViewCell{
    @IBOutlet weak var segmentControl : UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class NOItemCell : ConstrainedTableViewCell{
    @IBOutlet var lblMessage: UILabel!
    @IBOutlet var btnMessage: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
