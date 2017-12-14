
import UIKit

enum JobOfferStatus: String {
    case accept = "accept"
    case reject = "reject"
    case pending = "pending"
}

class JobOffer: NSObject {
    
    let id: String
    let offerDate: Date?
    let proposedDate: Date?
    let offerStatus: JobOfferStatus
    let userId: String
    let userName: String
    let userProfile: String
    
    let completePercent: Double
    let latePercent: Double
    let cancelPercent: Double
    
    let isEmailVerify: Bool
    let isMobileVerify: Bool
    let isFbVerify: Bool
    let isLinkdInVerify: Bool
    
    var imageUrl: URL?{
        return URL(string: "\(_baseUrlFile)\(userProfile)")
    }
    
    var offerDatestr: String{
        return Date.getLocalString(from: offerDate, format: "dd. MMM hh:mm a")
    }
    
    var proposedDateStr: String{
        return Date.getLocalString(from: proposedDate, format: "dd. MMM hh:mm a")
    }
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "_id")
        offerDate = Date.getDateFromServerFormat(from: dict.getStringValue(key: "dOfferDateTime"))
        proposedDate = Date.getDateFromServerFormat(from: dict.getStringValue(key: "dProposeDateTime"))
        offerStatus = JobOfferStatus(rawValue: dict.getStringValue(key: "eOfferStatus"))!
        userId = dict.getStringValue(key: "sUserId")
        userName = dict.getStringValue(key: "username")
        userProfile = dict.getStringValue(key: "profile_image")
        
        isEmailVerify = dict.getBooleanValue(key: "email_verify")
        isMobileVerify = dict.getBooleanValue(key: "mobile_verify")
        isFbVerify = dict.getBooleanValue(key: "facebook_verify")
        isLinkdInVerify = dict.getBooleanValue(key: "linkedin_verify")
        
        completePercent = dict.getDoubleValue(key: "complete_swishd_percentage")
        cancelPercent = dict.getDoubleValue(key: "cancel_job_percentage")
        latePercent = dict.getDoubleValue(key: "late_job_percentage")
    }

}
