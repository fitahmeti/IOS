

import UIKit

enum ActivityType: String {
    case dropToPickOffice       = "drop_office"
    case receiveFromPickOffice  = "pickup_office"
    case dropToDelOffice        = "deliver_office"
    case receiveFromDelOffice   = "deliver_receiver"
    case directPickUp           = "pickup"
    case directDeliver          = "deliver"
    case jobAccept              = "job_accept"
    case message                = "message"
    case unknown                = "unknown"
    
    init(str: String) {
        if let type = ActivityType(rawValue: str) {
            self = type
        }else{
            self = .unknown
        }
    }
}

class JobActivity: NSObject {

    var id: String
    var type = ActivityType.unknown
    var message: String
    var activityDate: Date?
    var offerDelDate: Date?
    var sender: OtherUser?
    var otherUser: OtherUser?
    
    var senderUserName: String{
        if sender!.id == _user.id{
            return sender!.userName
        }else{
            return sender!.userName
        }
    }
    
    var displayString: String{
        switch type {
        case .message:
            return message
        case .dropToPickOffice:
            return "\(senderUserName) has dropped the item at the pickup collection point."
        case .receiveFromPickOffice:
            return "\(senderUserName) has picked item from collection point."
        case .dropToDelOffice:
            return "\(senderUserName) has dropped item to collection point."
        case .receiveFromDelOffice:
            return "\(senderUserName) has picked item from delivery collection point."
        case .directPickUp:
            return "\(senderUserName) has picked item from user"
        case .directDeliver:
            return "\(senderUserName) has deliver item to user"
        case .jobAccept:
            return "\(senderUserName) has accept \(otherUser!.userName)'s job request."
        case .unknown:
            return "unknown event."
        }
    }
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "_id")
        type = ActivityType(str: dict.getStringValue(key: "eActivityStatus"))
        message = dict.getStringValue(key: "sMessage")
        activityDate = Date.getDateFromServerFormat(from: dict.getStringValue(key: "dMessageDate"))
        offerDelDate = Date.getDateFromServerFormat(from: dict.getStringValue(key: "dSwishDate"))
        if let user = dict["messageSender"] as? NSDictionary {
            sender = OtherUser(actUser: user)
        }
        
        if let user = dict["sender"] as? NSDictionary {
            otherUser = OtherUser(actUser: user)
        }
    }
}
