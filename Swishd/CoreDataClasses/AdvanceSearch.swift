
import UIKit

enum SearchStatus : String {
    case saved = "saved"
    case unsaved = "unsaved"
    case unknown = "unknown"
    
    init(str: String) {
        if let val = SearchStatus(rawValue: str){
            self = val
        }else{
            self = .unknown
        }
    }
}

class Search: NSObject {
    
    var searchID : String?
    var specificDate : Date?
    var filterCount : Int = 0
    var everyDay = [Day]()
    var isSwishPoint: Bool = false
    var isAnytime: Bool = false
    var sourceAddress: Address?
    var destAddress: Address?
    var searchStatus:SearchStatus = .unsaved
    
    override init() {}
    
    init(dict : NSDictionary) {
        searchID = dict.getStringValue(key: "_id")
        specificDate = Date.getDateFromServerFormat(from: dict.getStringValue(key: "specific_date"))
        isSwishPoint = dict.getBooleanValue(key: "swishdoffice")
        isAnytime = dict.getBooleanValue(key: "anytime")
        filterCount = dict.getIntValue(key: "filter_counter")
        searchStatus = SearchStatus(str: dict.getStringValue(key: "filter_status"))
        destAddress = Address(searchDict: dict, isSource: false)
        sourceAddress = Address(searchDict: dict, isSource: true)
        
        if let days = dict["everyday"] as? NSArray{
            for day in days{
                everyDay.append(Day(str: day as! String))
            }
        }
    }
    
    func setSearchId(dict:NSDictionary) {
        searchID = dict.getStringValue(key: "_id")
    }
    
    func getParamDict()-> [String: Any]{
        var dict: [String: Any] = [:]
        
        dict["source_latitude"] = sourceAddress!.lat
        dict["source_longitude"] = sourceAddress!.long
        dict["source_address"] = sourceAddress!.formattedAddress
        dict["destination_latitude"] = destAddress!.lat
        dict["destination_longitude"] = destAddress!.long
        dict["destination_address"] = destAddress!.formattedAddress
        
        if isAnytime{
            dict["anytime"] = isAnytime
        }
        
        if isSwishPoint {
            dict["swishdoffice"] = isSwishPoint
        }
        
        if let date = specificDate{
            dict["specific_date"] = Date.getServerString(from: date)
        }
        
        if !everyDay.isEmpty{
            if everyDay.count == 7{
                dict["everyday"] = ["all"]
            }else{
                dict["everyday"] = everyDay.map {$0.rawValue}
            }
        }
        return dict
    }
}
