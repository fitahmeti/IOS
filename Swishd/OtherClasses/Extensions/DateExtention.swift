//  Created by iOS Development Company on 2/23/17.
//  Copyright © 2017 iOS Development Company. All rights reserved.
//

import Foundation
import UIKit


extension Date{

    static func getDateFromServerFormat(from string: String, format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ") -> Date?{
        _serverFormatter.dateFormat = format
        return _serverFormatter.date(from: string)
    }
    
    static func getDateFromLocalFormat(from string: String, format: String = "MM-dd-yyyy") -> Date?{
        _deviceFormatter.dateFormat = format
        return _deviceFormatter.date(from: string)
    }
    
    static func getLocalString(from date: Date?, format: String = "MM-dd-yyyy") -> String{
        _deviceFormatter.dateFormat = format
        if let _ = date{
            return _deviceFormatter.string(from: date!)
        }else{
            return ""
        }
    }
    
    static func getServerString(from date: Date?, format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ") -> String{
        _serverFormatter.dateFormat = format
        if let _ = date{
            return _serverFormatter.string(from: date!)
        }else{
            return ""
        }
    }
    
    func getDateComponents() -> (day: String, month: String, year: String) {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .weekday], from: self)
        let month = DateFormatter().monthSymbols[components.month! - 1]
        let day = String(components.day!)
        let year = String(components.year!)
        return (day,month,year)
    }
    
    func getAge() -> Int{
        let now = Date()
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: self, to: now)
        return ageComponents.year!
    }
    
    func getTomorrowDate() -> Date{
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }
   
    func agoStringFromTime()-> String {
        let timeScale = ["now"  :1,
                         "min"  :60,
                         "hr"   :3600,
                         "day"  :86400,
                         "week" :605800,
                         "mth"  :2629743,
                         "year" :31556926];
        
        var scale : String = ""
        var timeAgo = 0 - Int(self.timeIntervalSinceNow)
        if (timeAgo < 60) {
            scale = "now";
        } else if (timeAgo < 3600) {
            scale = "min";
        } else if (timeAgo < 86400) {
            scale = "hr";
        } else if (timeAgo < 605800) {
            scale = "day";
        } else if (timeAgo < 2629743) {
            scale = "week";
        } else if (timeAgo < 31556926) {
            scale = "mth";
        } else {
            scale = "year";
        }
        
        timeAgo = timeAgo / Int(timeScale[scale]!)
        if scale == "now"{
            return scale
        }else{
            return "\(timeAgo) \(scale) ago"
        }
    }
}
