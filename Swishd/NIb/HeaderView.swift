//
//  HeaderView.swift
//
//

import Foundation

enum HeaderType{

    case profile
    case history
    case walletHistory
}

class HeaderView: ConstrainedHeaderTableView{

    @IBOutlet weak var lblText: UILabel!
    
    // Profile Header
    @IBOutlet weak var lblSwishr: UILabel!
    @IBOutlet weak var lblSwishrCount: UILabel!
    @IBOutlet weak var lblSender: UILabel!
    @IBOutlet weak var lblSendrCount: UILabel!
    @IBOutlet weak var lblSwishrBottom: UILabel!
    @IBOutlet weak var lblSendrBottom: UILabel!
    @IBOutlet weak var btnSender: UIButton!
    @IBOutlet weak var btnSwishr: UIButton!
    @IBOutlet weak var vwSwishr: UIView!
    @IBOutlet weak var vwSender: UIView!
    
    @IBOutlet weak var lblJobStatus: UILabel!
    @IBOutlet weak var viewJobStatusBg: UIView!
    
    weak var parent: ProfileVC!
    weak var historyParent: JobHistoryVC!
    weak var walletParent: WalletDetailVC!
    
    func prepareUI(type: HeaderType){
        lblSwishrBottom.isHidden = true
        lblSendrBottom.isHidden = true
        lblSender.textColor = UIColor.hexStringToUIColor(hexStr: "CBCBCB")
        lblSendrCount.backgroundColor = UIColor.hexStringToUIColor(hexStr: "CBCBCB")
        lblSwishr.textColor = UIColor.hexStringToUIColor(hexStr: "CBCBCB")
        lblSwishrCount.backgroundColor = UIColor.hexStringToUIColor(hexStr: "CBCBCB")
        vwSwishr.backgroundColor = UIColor.hexStringToUIColor(hexStr: "F3F3F3")
        vwSender.backgroundColor = UIColor.hexStringToUIColor(hexStr: "F3F3F3")
        
        if type == .profile{
            btnSwishr.addTarget(parent, action: #selector(parent.btnSenderSwishrAction), for: .touchUpInside)
            btnSender.addTarget(parent, action: #selector(parent.btnSenderSwishrAction), for: .touchUpInside)
            lblSwishrCount.isHidden = parent.swishrCount == 0 ? true : false
            lblSendrCount.isHidden = parent.senderCount == 0 ? true : false
            lblSwishrCount.text = "\(parent.swishrCount)"
            lblSendrCount.text = "\(parent.senderCount)"
            changeSegment(type: parent.jobType)
        }else if type == .history{
            btnSwishr.addTarget(parent, action: #selector(historyParent.btnSenderSwishrAction), for: .touchUpInside)
            btnSender.addTarget(parent, action: #selector(historyParent.btnSenderSwishrAction), for: .touchUpInside)
            lblSwishrCount.isHidden = true
            lblSendrCount.isHidden = true
            changeSegment(type: historyParent.jobType)
        }else{
            lblSwishrCount.isHidden = true
            lblSendrCount.isHidden = true
            lblSwishr.font = UIFont.arialRegular(size: 13 * _widthRatio)
            lblSwishr.text = "PAYMENT DETAILS"
            lblSender.text = "TRANSECTION HISTORY"
            lblSender.font = UIFont.arialRegular(size: 13 * _widthRatio)
            btnSwishr.addTarget(parent, action: #selector(walletParent.btnPaymentHistoryaction), for: .touchUpInside)
            btnSender.addTarget(parent, action: #selector(walletParent.btnPaymentHistoryaction), for: .touchUpInside)
            changeWalletSegment(type: walletParent.selectedSegment)
        }
    }
    
    func changeSegment(type: JobType){
        if type == .swishr{
            lblSwishr.textColor = UIColor.swdBlueColor()
            lblSwishrCount.backgroundColor = UIColor.swdBlueColor()
            lblSwishrBottom.isHidden = false
            vwSwishr.backgroundColor = .white
        }else{
            lblSender.textColor = UIColor.swdBlueColor()
            lblSendrCount.backgroundColor = UIColor.swdBlueColor()
            lblSendrBottom.isHidden = false
            vwSender.backgroundColor = .white
        }
    }
    
    func changeWalletSegment(type: WalletSegment){
        if type == .payment{
            lblSwishr.textColor = UIColor.swdBlueColor()
            lblSwishrBottom.isHidden = false
            lblSwishr.font = UIFont.arialBold(size: 13 * _widthRatio)
            vwSwishr.backgroundColor = .white
        }else{
            lblSender.textColor = UIColor.swdBlueColor()
            lblSender.font = UIFont.arialBold(size: 13 * _widthRatio)
            lblSendrBottom.isHidden = false
            vwSender.backgroundColor = .white
        }
    }
    
    func prepareUIForJobStatusHeader(seq: Int) {
        if seq == 1{
            lblJobStatus.text = "Active"
            viewJobStatusBg.backgroundColor = UIColor.colorWithRGB(r: 44, g: 152, b: 57)
        }else if seq == 2{
            lblJobStatus.text = "Select SWISHR"
            viewJobStatusBg.backgroundColor = UIColor.colorWithRGB(r: 230, g: 153, b: 65)
        }else{
            lblJobStatus.text = "Awaiting SWISHR"
            viewJobStatusBg.backgroundColor = UIColor.swdThemeRedColor()
        }
    }
}
