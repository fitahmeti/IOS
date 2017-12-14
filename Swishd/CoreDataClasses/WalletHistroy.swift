
import UIKit

enum Paymentflow: String{
    case add = "add"
    case deduct = "deduct"
    case unknown = "unknown"
    
    init(str: String) {
        if let val = Paymentflow(rawValue: str){
            self = val
        }else{
            self = .unknown
        }
    }
}

class WalletHistroy{
    
    var id: String
    var paymentFlow: Paymentflow = .unknown
    var paymentMethod: String
    var paymentType: String
    var amoumt: Double
    var total: Double
    var desc: String
    var date: Date?
    var userHistroy: OtherUser!
    
    var dateateStr: String{
        if let str = date{
            return Date.getLocalString(from: str, format: "eee dd MMM yyyy - hh:mm")
        }else{
            return ""
        }
    }
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "_id")
        paymentFlow = Paymentflow(str: dict.getStringValue(key: "sPaymentFlow"))
        paymentMethod = dict.getStringValue(key: "sPaymentMethod")
        paymentType = dict.getStringValue(key: "sPaymentType")
        total = dict.getDoubleValue(key: "sTotal")
        desc = dict.getStringValue(key: "sDescription")
        amoumt = dict.getDoubleValue(key: "sAmount")
        date = Date.getDateFromServerFormat(from: dict.getStringValue(key: "dCreatedDate"))
        
        if let user = dict["user"] as? NSDictionary{
            userHistroy = OtherUser(dict: user)
        }
    }
}
