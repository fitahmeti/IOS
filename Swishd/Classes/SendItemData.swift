//
//  SendItemData.swift
//  Swishd
//
//
//

import Foundation
import UIKit

struct SendData {
    var title = ""
    var itemSize: ItemSize?
    var price: Double?
    var picAddress: SearchAddress?
    var picLookAdd: SearchAddress?
//    var picSwsPoint: SwishdPoint?
    var dropAddress: SearchAddress?
    var dropLookAdd: SearchAddress?
//    var dropSwsPoint: SwishdPoint?
    var vat: Double = 1
    var fee: Double = 3
    var recommendedCharge: Double = 8
    var ownCharge: Double = 0
    var delDate: Date?
    var pickDate: Date?
    var isOwnPriceSet: Bool = false
    
    func getParamDict() -> [String: Any] {
        var dict:[String: Any] = [:]
        dict["sJobTitle"] = title
        dict["sSizeId"] = itemSize!.id
        
        if let _ = price{
            dict["sPriceValue"] = price!
        }
        
        if let add = picAddress{
            dict["sPickLatitude"] = add.lat
            dict["sPickLongitude"] = add.long
            dict["sPickAddress"] = add.formatedAddress
        }else{
            dict["sPickLatitude"] = picLookAdd!.lat
            dict["sPickLongitude"] = picLookAdd!.long
            dict["sPickAddress"] = picLookAdd!.formatedAddress
//            dict["sPickOfficeId"] = picSwsPoint!.id
        }
        
        if let date = pickDate{
            dict["sPickDateTime"] = Date.getServerString(from: date)
        }
        
        if let add = dropAddress{
            dict["sDropLatitude"] = add.lat
            dict["sDropLongitude"] = add.long
            dict["sDropAddress"] = add.formatedAddress
        }else{
            dict["sDropLatitude"] = dropLookAdd!.lat
            dict["sDropLongitude"] = dropLookAdd!.long
            dict["sDropAddress"] = dropLookAdd!.formatedAddress
//            dict["sDropOfficeId"] = dropSwsPoint!.id
        }
        
        if let date = delDate{
            dict["sDropDateTime"] = Date.getServerString(from: date)
        }
        
        let tempPrice: Double!
        if isOwnPriceSet{
            tempPrice = ownCharge
        }else{
            tempPrice = recommendedCharge
        }
        
        dict["sRecommendedPrice"] = tempPrice
        dict["sRewardPrice"] = tempPrice - fee - vat
        dict["sInsuranceFee"] = fee
        dict["sVat"] = vat
        return dict
    }
}
