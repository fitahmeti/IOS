
import Foundation
import UIKit

class Card {
    let id: String
    let brand: String
    let country: String
    let expMonth: Int
    let expYear: Int
    let last4Digit: String
    let cardType: String
    
    var cardImg: UIImage{
        if let img = UIImage(named: "swd_card_\(brand.lowercased())"){
            return img
        }else{
            return UIImage(named: "swd_card_unknown")!
        }
    }
    
    var cardNoStr: String{
        return "**** **** **** \(last4Digit)"
    }
    
    var expString: String{
        return "\(expMonth)/\(expYear)"
    }
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        brand = dict.getStringValue(key: "brand")
        country = dict.getStringValue(key: "country")
        expMonth = dict.getIntValue(key: "exp_month")
        expYear = dict.getIntValue(key: "exp_year")
        last4Digit = dict.getStringValue(key: "last4")
        cardType = dict.getStringValue(key: "funding")
    }
}
