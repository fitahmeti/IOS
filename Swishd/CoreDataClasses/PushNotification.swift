//
//  PushNotification.swift
//  Swishd
//
//
//

import Foundation
import UIKit

enum PushType: String{
    case jobOffer    = "swishr_offer"
    case jobAccept   = "sendr_accept"
    case jobReject   = "sendr_reject"
    case journyInJob = "newjob_saved_journy"
    case payment     = "payment"
    case deepLinkJob = "deepLinkJob"
    case unknown     = "unknown"
    
    init(str: String) {
        if let type = PushType(rawValue: str){
            self = type
        }else{
            self = PushType.unknown
        }
    }
}

class PushNotification {
    var jobId: String
    var userId: String
    var type: PushType = PushType.unknown
    
    init(dict: NSDictionary) {
        jobId = dict.getStringValue(key: "job")
        userId = dict.getStringValue(key: "swishr")
        type = PushType(str: dict.getStringValue(key: "type"))
    }
    
    init(id: String) {
        jobId = id
        userId = ""
        type = PushType.deepLinkJob
    }
}
