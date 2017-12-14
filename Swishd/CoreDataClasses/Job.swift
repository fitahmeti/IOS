
import UIKit

enum JobStatus : String {
    case pending    = "pending"
    case active     = "active"
    case inProgress = "inProgress"
    case completed  = "completed"
    case unknown    = "unknown"
    
    init(str: String) {
        if let val = JobStatus(rawValue: str){
            self = val
        }else{
            self = .unknown
        }
    }
}

class Job {
    var jobId : String
    var jobTitle : String
    var itemPrice : Double
    
    var pickDateTime : Date?
    var pickLocation : Address?
    var pickOffice : SwishdPoint?
    
    var dropDateTime : Date?
    var dropLocation : Address?
    var dropOffice : SwishdPoint?
    
    var recommandPrice : Double
    var rewardPrice : Double
    var insuranceFee : Double
    var serviceTax : Double
    var vat : Double
    var updatedDate : Date?
    var status : JobStatus = JobStatus.unknown
    var pickImmidiate : String
    var distanceFrom : Double
    var itemSize : ItemSize!
    var order: Int
    
    // For Job Detail
    var sender: OtherUser?
    var swishr: OtherUser?
    var isJobRequestSent: Bool
    var jobRequestCount: Int
    var qrCodes: [QRCode] = []
    var sendBy: Receiver?
    var receiveBy: Receiver?
    
    var isSentByMe: Bool{
        if let user = sender{
            return user.id == _user.id
        }
        return false
    }
    
    var isSwishByMe: Bool{
        if let user = swishr{
            return user.id == _user.id
        }
        return false
    }
    
    var dropAddress: String{
        if let _ = dropOffice{
            return dropOffice!.address.formattedAddress
        }else{
            return dropLocation!.formattedAddress
        }
    }
    
    var pickAddress: String{
        if let _ = pickOffice{
            return pickOffice!.address.formattedAddress
        }else{
            return pickLocation!.formattedAddress
        }
    }
    
    var dropDateStr: String{
        if let date = dropDateTime{
            return Date.getLocalString(from: date, format: "EEE dd MMM")
        }else{
            return "Flexible"
        }
    }
    
    var pickDateStr: String{
        if let date = pickDateTime{
            return Date.getLocalString(from: date, format: "EEE dd MMM")
        }else{
            return "Flexible"
        }
    }
    
    var dropTimeStr: String{
        if let date = dropDateTime{
            return Date.getLocalString(from: date, format: "hh:mm a")
        }else{
            return "Flexible"
        }
    }
    
    var pickTimeStr: String{
        if let date = pickDateTime{
            return Date.getLocalString(from: date, format: "hh:mm a")
        }else{
            return "Flexible"
        }
    }
    
    var pickDateFullStr: String{
        if let date = pickDateTime{
            return Date.getLocalString(from: date, format: "dd. MMM hh:mm a")
        }else{
            return "Flexible"
        }
    }
    
    var dropDateFullStr: String{
        if let date = dropDateTime{
            return Date.getLocalString(from: date, format: "dd. MMM hh:mm a")
        }else{
            return "Flexible"
        }
    }
    
    var displayCode: QRCode?{
        if status == .active{
            if isSentByMe{
                if sendBy!.isMe{
                    if pickOffice == nil{
                        return qrCodes.filter({ (qrcd) -> Bool in
                            return qrcd.type == CodeType.directPickUp
                        }).first!
                    }else{
                        return qrCodes.filter({ (qrcd) -> Bool in
                            return qrcd.type == CodeType.dropToPickOffice
                        }).first!
                    }
                }else{
                    return nil
                }
            }else{
                if pickOffice == nil{
                    return nil
                }else{
                    return qrCodes.filter({ (qrcd) -> Bool in
                        return qrcd.type == CodeType.receiveFromPickOffice
                    }).first!
                }
            }
        }else if status == .inProgress{
            if isSentByMe{
                if receiveBy!.isMe{
                    if dropOffice == nil{
                        return qrCodes.filter({ (qrcd) -> Bool in
                            return qrcd.type == CodeType.directDeliver
                        }).first!
                    }else{
                        return qrCodes.filter({ (qrcd) -> Bool in
                            return qrcd.type == CodeType.receiveFromDelOffice
                        }).first!
                    }
                }else{
                    return nil
                }
            }else{
                if dropOffice == nil{
                    return nil
                }else{
                    return qrCodes.filter({ (qrcd) -> Bool in
                        return qrcd.type == CodeType.dropToDelOffice
                    }).first!
                }
            }
        }else{
            return nil
        }
    }
    
    init(dict : NSDictionary) {
        jobId = dict.getStringValue(key: "_id")
        jobTitle = dict.getStringValue(key: "sJobTitle")
        itemPrice = dict.getDoubleValue(key: "sPriceValue")
        pickDateTime = Date.getDateFromServerFormat(from: dict.getStringValue(key: "sPickDateTime"))
        dropDateTime = Date.getDateFromServerFormat(from: dict.getStringValue(key: "sDropDateTime"))
        recommandPrice = dict.getDoubleValue(key: "sRecommendedPrice")
        rewardPrice = dict.getDoubleValue(key: "sRewardPrice")
        insuranceFee = dict.getDoubleValue(key: "sInsuranceFee")
        serviceTax = dict.getDoubleValue(key: "sServiceTax")
        vat = dict.getDoubleValue(key: "sVat")
        updatedDate = Date.getDateFromServerFormat(from: dict.getStringValue(key: "dUpdatedDate"))
        status = JobStatus(str: dict.getStringValue(key: "eJobStatus"))
        pickImmidiate = dict.getStringValue(key: "ePickImmediately")
        distanceFrom = dict.getDoubleValue(key: "distanceFromS")
        order = dict.getIntValue(key: "order")
        
        if let size = dict["jobSize"] as? NSDictionary{
            itemSize = ItemSize.addUpdateEntity(key: "id", value: size.getStringValue(key: "_id"))
            itemSize.initWith(dict: size)
            _appDelegator.saveContext()
        }
        
        if let office = dict["pickOffice"] as? NSDictionary{
            pickOffice = SwishdPoint(dict: office)
        }else{
            pickLocation = Address(jobDict: dict, isDrop: false)
        }
        
        if let office = dict["dropOffice"] as? NSDictionary{
            dropOffice = SwishdPoint(dict: office)
        }else{
            dropLocation = Address(jobDict: dict, isDrop: true)
        }
        
        // Job Detail
        if let userDict = dict["sender"] as? NSDictionary {
            sender = OtherUser(dict: userDict)
        }
        
        if let swishrDict = dict["swishr"] as? NSDictionary{
            swishr = OtherUser(dict: swishrDict)
        }
        isJobRequestSent = dict.getBooleanValue(key: "jobRequested")
        jobRequestCount = dict.getIntValue(key: "jobRequestCount")
        
        if let arr = dict["qrcode"] as? [NSDictionary] {
            for codeDict in arr{
                let code = QRCode(dict: codeDict)
                qrCodes.append(code)
            }
        }
        
        if let pickByDict = dict["sPickupBy"] as? NSDictionary{
            sendBy = Receiver(dict: pickByDict)
        }
        
        if let recByDict = dict["sRecievedBy"] as? NSDictionary{
            receiveBy = Receiver(dict: recByDict)
        }
    }
}

enum CodeType: String {
    case dropToPickOffice       = "drop_office"
    case receiveFromPickOffice  = "pickup_office"
    case dropToDelOffice        = "deliver_office"
    case receiveFromDelOffice   = "deliver_receiver"
    case directPickUp           = "pickup"
    case directDeliver          = "deliver"
    case unknown                = "unknown"
    
    init(str: String) {
        if let type = CodeType(rawValue: str) {
            self = type
        }else{
            self = .unknown
        }
    }
}

class QRCode{
    let id: String
    let code: String
    let image: String
    var type = CodeType.unknown
    
    var codeUrl: URL?{
        return URL(string: "\(_baseUrlFile)\(image)")
    }
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "_id")
        code = dict.getStringValue(key: "sScanCode")
        image = dict.getStringValue(key: "sScanImage")
        type = CodeType(str: dict.getStringValue(key: "sType"))
    }
}

class Receiver {
    let email: String
    let fName: String
    let lName: String
    let mobile: String
    let swishEmail: String
    let swishUserName: String
    let userId: String
    
    var isMe: Bool{
        return userId == _user.id
    }
    
    init(dict: NSDictionary) {
        email = dict.getStringValue(key: "sEmail")
        fName = dict.getStringValue(key: "sFirstName")
        lName = dict.getStringValue(key: "sLastName")
        mobile = dict.getStringValue(key: "sMobile")
        swishEmail = dict.getStringValue(key: "sSwishrEmail")
        swishUserName = dict.getStringValue(key: "sSwishrUserName")
        userId = dict.getStringValue(key: "sUserId")
    }
}
