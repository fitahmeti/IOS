
import UIKit
import CoreData

/// Current loggedIn User
class User: NSManagedObject, ParentManagedObject {
    
    @NSManaged var id: String
    @NSManaged var walletAmount: Int32
    @NSManaged var email: String
    @NSManaged var fName: String
    @NSManaged var lName: String
    @NSManaged var userName: String
    @NSManaged var mobile: String
    @NSManaged var countryCode: String
    @NSManaged var isSocialLogin: Bool
    @NSManaged var profileImageStr: String
    @NSManaged var isEmailVerify: Bool
    @NSManaged var isFbVerify: Bool
    @NSManaged var fbId: String
    @NSManaged var isGoogleVerify: Bool
    @NSManaged var isLinkdinVerify: Bool
    @NSManaged var isMobileVerify: Bool
    @NSManaged var isProofVerify: Bool
    @NSManaged var completePost: Double
    @NSManaged var completeSwishd: Double
    @NSManaged var completePostPer: Double
    @NSManaged var completeSwishdPer: Double
    @NSManaged var isCollectionPoint: Bool
    @NSManaged var stripeCustomerId: String
    @NSManaged var joinDate: Date
    
    //User Proof Verify
    @NSManaged var proofQrCode: String
    @NSManaged var proofCode: String
    @NSManaged var proofAddress: String
    @NSManaged var proofId: String
    
    override var hashValue: Int{
        return id.hashValue
    }
        
    var imageUrl: URL?{
        return URL(string: "\(_baseUrlFile)\(profileImageStr)")
    }
    
    var verifiedIdProofUrl: URL?{
        return URL(string: "\(_baseUrlFile)\(proofId)")
    }
    
    var verifyAddressProofUrl: URL?{
        return URL(string: "\(_baseUrlFile)\(proofAddress)")
    }
    
    var codeImageUrl: URL?{
        return URL(string: "\(_baseUrlFile)\(proofQrCode)")
    }
    
    func initWith(dict: NSDictionary) {
        id = dict.getStringValue(key: "_id")
        walletAmount = dict.getInt32Value(key: "total_wallet_amount")
        email = dict.getStringValue(key: "email")
        fName = dict.getStringValue(key: "first_name")
        lName = dict.getStringValue(key: "last_name")
        userName = dict.getStringValue(key: "username")
        mobile = dict.getStringValue(key: "")
        countryCode = dict.getStringValue(key: "")
        isEmailVerify = dict.getBooleanValue(key: "email_verify")
        isFbVerify = dict.getBooleanValue(key: "facebook_verify")
        isGoogleVerify = dict.getBooleanValue(key: "google_verify")
        isLinkdinVerify = dict.getBooleanValue(key: "linkedin_verify")
        isMobileVerify = dict.getBooleanValue(key: "mobile_verify")
        isProofVerify = dict.getBooleanValue(key: "proof_verify")
        isSocialLogin = dict.getBooleanValue(key: "isLoginWithSocial")
        profileImageStr = dict.getStringValue(key: "profile_image")
        completePost = dict.getDoubleValue(key: "complete_post_count")
        completeSwishd = dict.getDoubleValue(key: "complete_swishd_count")
        completePostPer = dict.getDoubleValue(key: "post_percentage")
        completeSwishdPer = dict.getDoubleValue(key: "complete_swishd_percentage")
        stripeCustomerId = dict.getStringValue(key: "stripe_customer_id")
        joinDate = Date.getDateFromServerFormat(from: dict.getStringValue(key: "join_date"))!
        
        if let data = dict["proofData"] as? NSDictionary{
            proofId = data.getStringValue(key: "verify_id_proof")
            proofCode = data.getStringValue(key: "scan_code")
            proofQrCode = data.getStringValue(key: "qr_code_image")
            proofAddress = data.getStringValue(key: "verify_address_proof")
        }
    }
    
    func initWithProff(dict: NSDictionary) {
        proofId = dict.getStringValue(key: "verify_id_proof")
        proofCode = dict.getStringValue(key: "scan_code")
        proofQrCode = dict.getStringValue(key: "qr_code_image")
        proofAddress = dict.getStringValue(key: "verify_address_proof")
    }
    
    func initWithProfile(dict: NSDictionary) {
        id = dict.getStringValue(key: "_id")
        email = dict.getStringValue(key: "email")
        fName = dict.getStringValue(key: "first_name")
        lName = dict.getStringValue(key: "last_name")
        userName = dict.getStringValue(key: "username")
        profileImageStr = dict.getStringValue(key: "profile_image")
    }
}

class OtherUser {
    var id: String
    var email: String = ""
    var fName: String
    var lName: String
    var userName: String
    var image: String
    
    var isEmailVerify: Bool = false
    var isMobileVerify: Bool = false
    var isLinkdInVerify: Bool = false
    var isProofVerify: Bool = false
    var isFbVerify: Bool = false
    var isGoogleVerify: Bool = false
    var fbId: String = ""
    var fbFriends: Int = 0
    var linkdinFrnd: Int = 0
    var completeSwished: Int
    var lateJob: Int
    var cancelJob: Int
    
    var imageUrl: URL?{
        return URL(string: "\(_baseUrlFile)\(image)")
    }
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "_id")
        email = dict.getStringValue(key: "email")
        fName = dict.getStringValue(key: "first_name")
        lName = dict.getStringValue(key: "last_name")
        userName = dict.getStringValue(key: "username")
        image = dict.getStringValue(key: "profile_image")
        completeSwished = 0
        lateJob = 0
        cancelJob = 0
    }
    
    init(actUser: NSDictionary) {
        id = actUser.getStringValue(key: "sUserId")
        userName = actUser.getStringValue(key: "username")
        image = actUser.getStringValue(key: "profile_image")
        fName = ""
        lName = ""
        completeSwished = 0
        lateJob = 0
        cancelJob = 0
    }
    
    init(swishrDict: NSDictionary) {
        id = swishrDict.getStringValue(key: "_id")
        fName = swishrDict.getStringValue(key: "first_name")
        lName = swishrDict.getStringValue(key: "last_name")
        userName = swishrDict.getStringValue(key: "username")
        image = swishrDict.getStringValue(key: "profile_image")
        isEmailVerify = swishrDict.getBooleanValue(key: "email_verify")
        isMobileVerify = swishrDict.getBooleanValue(key: "mobile_verify")
        isLinkdInVerify = swishrDict.getBooleanValue(key: "linkedin_verify")
        isProofVerify = swishrDict.getBooleanValue(key: "proof_verify")
        isFbVerify = swishrDict.getBooleanValue(key: "facebook_verify")
        isGoogleVerify = swishrDict.getBooleanValue(key: "google_verify")
        fbId = swishrDict.getStringValue(key: "facebook_id")
        fbFriends = swishrDict.getIntValue(key: "fb_friends")
        linkdinFrnd = swishrDict.getIntValue(key: "ln_friends")
        completeSwished = swishrDict.getIntValue(key: "complete_swishd_percentage")
        lateJob = swishrDict.getIntValue(key: "late_job_percentage")
        cancelJob = swishrDict.getIntValue(key: "cancel_job_percentage")
    }
}
