

import UIKit

class Charity: NSObject{
    
    var id: String
    var accNo: String
    var name: String
    var sortCode: String
    var imgStr: String
    
    var imgUrl: URL?{
        return URL(string: "\(_baseUrlFile)\(imgStr)")
    }
    
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "_id")
        accNo = dict.getStringValue(key: "sAccountNumber")
        name = dict.getStringValue(key: "sCharityName")
        sortCode = dict.getStringValue(key: "sSortCode")
        imgStr = dict.getStringValue(key: "sCharityImage")
    }
}
