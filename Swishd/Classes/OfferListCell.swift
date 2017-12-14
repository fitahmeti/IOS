//
//  OfferListCell.swift
//  Swishd
//
//  Created by Yudiz on 11/8/17.
//
//

import Foundation
import UIKit

class OfferListCell: ConstrainedTableViewCell{
    
    @IBOutlet weak var imgSwisher: UIImageView!
    @IBOutlet weak var lblSwisherName: UILabel!
    @IBOutlet weak var lblPercentComplete: UILabel!
    @IBOutlet weak var lblPercentCancel: UILabel!
    @IBOutlet weak var lblPercentLate: UILabel!
    
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var imgEmail: UIImageView!
    
    @IBOutlet weak var viewMobile: UIView!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var imgMobile: UIImageView!
    
    @IBOutlet weak var viewFb: UIView!
    @IBOutlet weak var lblFb: UILabel!
    @IBOutlet weak var imgFb: UIImageView!
    
    @IBOutlet weak var viewLinkD: UIView!
    @IBOutlet weak var lblLinkD: UILabel!
    @IBOutlet weak var imgLinkD: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareVerifyUI(offer: JobOffer) {
        
        lblPercentLate.text = "\(offer.latePercent.getFormattedValue(str: "0")!)%"
        lblPercentComplete.text = "\(offer.completePercent.getFormattedValue(str: "0")!)%"
        lblPercentCancel.text = "\(offer.cancelPercent.getFormattedValue(str: "0")!)%"
        
        imgSwisher.kf.setImage(with: offer.imageUrl, placeholder: _placeImage)
        lblSwisherName.text = offer.userName
        
        imgEmail.isHidden = !offer.isEmailVerify
        imgMobile.isHidden = !offer.isMobileVerify
        imgFb.isHidden = !offer.isFbVerify
        imgLinkD.isHidden = !offer.isLinkdInVerify
        
        viewFb.backgroundColor = .hexStringToUIColor(hexStr: "E5E5E5")
        viewEmail.backgroundColor = .hexStringToUIColor(hexStr: "E5E5E5")
        viewLinkD.backgroundColor = .hexStringToUIColor(hexStr: "E5E5E5")
        viewMobile.backgroundColor = .hexStringToUIColor(hexStr: "E5E5E5")
        
        lblEmail.textColor = .hexStringToUIColor(hexStr: "554B4B")
        lblFb.textColor = .hexStringToUIColor(hexStr: "554B4B")
        lblMobile.textColor = .hexStringToUIColor(hexStr: "554B4B")
        lblLinkD.textColor = .hexStringToUIColor(hexStr: "554B4B")
        lblEmail.alpha = 0.5
        lblMobile.alpha = 0.5
        lblFb.alpha = 0.5
        lblLinkD.alpha = 0.5
        
        
        if offer.isEmailVerify{
            viewEmail.backgroundColor = .swdBlueColor()
            lblEmail.alpha = 1
        }
        
        if offer.isMobileVerify{
            viewMobile.backgroundColor = .swdBlueColor()
            lblMobile.alpha = 1
        }
        
        if offer.isFbVerify{
            viewFb.backgroundColor = .swdBlueColor()
            lblFb.alpha = 1
        }
        
        if offer.isLinkdInVerify{
            viewLinkD.backgroundColor = .swdBlueColor()
            lblLinkD.alpha = 1
        }
    }
}
