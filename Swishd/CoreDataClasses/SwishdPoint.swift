

import Foundation
import UIKit

enum SwishdPointStatus: String {
    case open = "Open"
    case close = "Close"
    case unknown = "unknown"
    
    init(str: String) {
        if let val = SwishdPointStatus(rawValue: str){
            self = val
        }else{
            self = .unknown
        }
    }
}

class Schedule {
    var day: Int
    var close: Int
    var open: Int
    
    var dayString: String{
        switch day {
        case 1:
            return "Monday"
        case 2:
            return "Tuesday"
        case 3:
            return "Wednesday"
        case 4:
            return "Thursday"
        case 5:
            return "Friday"
        case 6:
            return "Saturday"
        case 7:
            return "Sunday"
        default:
            return "unknown"
        }
    }
    
    var timeString: String{
        return "\(openStr) - \(colseStr)"
    }
    
    var openStr: String{
        let hour = open / 60
        let sec = open % 60
        let amStr = hour > 12 ? "pm" : "am"
        let exatHour = hour > 12 ? hour - 12 : hour
        if sec == 0{
            return "\(exatHour)\(amStr)"
        }else{
            return "\(exatHour):\(sec)\(amStr)"
        }
    }
    
    var colseStr: String{
        let hour = close / 60
        let sec = close % 60
        let amStr = hour > 12 ? "pm" : "am"
        let exatHour = hour > 12 ? hour - 12 : hour
        if sec == 0{
            return "\(exatHour)\(amStr)"
        }else{
            return "\(exatHour):\(sec)\(amStr)"
        }
    }
    
    init(dict: NSDictionary) {
        day = dict.getIntValue(key: "day")
        close = dict.getIntValue(key: "close")
        open = dict.getIntValue(key: "open")
    }
}

class SwishdPoint {
    let id: String
    let name: String
    let distance: Double
    var status = SwishdPointStatus.unknown
    var schedules:[Schedule] = []
    var address: Address
    var phone: String
    var webSite: String
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "_id")
        name = dict.getStringValue(key: "sOfficeName")
        distance = dict.getDoubleValue(key: "distance")
        status = SwishdPointStatus(str: dict.getStringValue(key: "workStatus"))
        address = Address(pointDict: dict)
        schedules = []
        phone = dict.getStringValue(key: "sMobile")
        webSite = dict.getStringValue(key: "sWebsite")
        if let arr = dict["oHours"] as? [NSDictionary] {
            for dictime in arr{
                let sch = Schedule(dict: dictime)
                schedules.append(sch)
            }
        }
    }
}
