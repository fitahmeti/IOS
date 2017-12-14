
import UIKit

class Bank: NSObject {
    
    var id: String
    var accountName: String
    var accountNo: String
    var sortCode: String
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "_id")
        accountNo = dict.getStringValue(key: "sAccountNumber")
        accountName = dict.getStringValue(key: "sAccountName")
        sortCode = dict.getStringValue(key: "sSortCode")
    }
    
    func makeString() -> String{
        let number = accountNo
        let start =  number.index(number.startIndex, offsetBy: 0)
        let end = number.index(number.endIndex, offsetBy: -4)
        let range = start..<end
        let str = number.replacingCharacters(in: range, with: getReplacementStr(number: number))
        return str
    }
    
    func getReplacementStr(number: String)-> String{
        var str = ""
        for _ in 0...number.count - 4{
            str.append("*")
        }
        return str
    }
}
