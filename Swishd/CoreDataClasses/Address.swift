

import UIKit
import CoreLocation
import MapKit

struct Address {
    var lat = 0.0
    var long = 0.0
    var addressLine1 = ""
    var addressLine2 = ""
    var city = ""
    var state = ""
    var country = ""
    var zipCode = ""
    var formattedAddress = ""
    
    init() {}
    
    init(location: CLLocation, dict: NSDictionary) {
        lat = location.coordinate.latitude
        long = location.coordinate.longitude
        addressLine1 = dict.getStringValue(key: "Name")
        
        if let street = dict["Street"] as? String{
            if addressLine1.isEmpty{
                addressLine1 = street
            }else{
                addressLine1 = "\(addressLine1), \(street)"
            }
        }
        city = dict.getStringValue(key: "City")
        state = dict.getStringValue(key: "State")
        country = dict.getStringValue(key: "Country")
        zipCode = dict.getStringValue(key: "ZIP")
        
        if let arr = dict["FormattedAddressLines"] as? NSArray{
            formattedAddress = arr.componentsJoined(by: ", ")
        }
    }
    
    init(pointDict: NSDictionary) {
        if let loc = pointDict["oLoc"] as? [Double], !loc.isEmpty{
            long = loc[0]
            lat = loc[1]
        }
        addressLine1 = pointDict.getStringValue(key: "sAddressLine1")
        addressLine2 = pointDict.getStringValue(key: "sAddressLine2")
        city = pointDict.getStringValue(key: "sCity")
        state = pointDict.getStringValue(key: "sState")
        country = pointDict.getStringValue(key: "sCountry")
        zipCode = pointDict.getStringValue(key: "sZipCode")
        
        if !addressLine1.isEmpty{
            formattedAddress.append("\(addressLine1), ")
        }
        if !addressLine2.isEmpty{
            formattedAddress.append("\(addressLine2), ")
        }
        if !city.isEmpty{
            formattedAddress.append("\(city), ")
        }
        if !state.isEmpty{
            formattedAddress.append("\(state), ")
        }
        if !zipCode.isEmpty{
            formattedAddress.append("\(zipCode), ")
        }
        if !country.isEmpty{
            formattedAddress.append(country)
        }
        formattedAddress = formattedAddress.trimmedString()
        if formattedAddress.last == ","{
            formattedAddress = String(formattedAddress.removeLast())
        }
    }
    
    init(searchDict: NSDictionary ,isSource: Bool) {
        if isSource{
            if let source = searchDict["source"] as? NSDictionary, let cord = source["coordinates"] as? [Double] {
                long = cord[0]
                lat = cord[1]
            }
            formattedAddress = searchDict.getStringValue(key: "source_address")
        }else{
            if let source = searchDict["destination"] as? NSDictionary, let cord = source["coordinates"] as? [Double] {
                long = cord[0]
                lat = cord[1]
            }
            formattedAddress = searchDict.getStringValue(key: "destination_address")
        }
    }

    init(jobDict: NSDictionary, isDrop: Bool) {
        if isDrop{
            if let loc = jobDict["oDropLoc"] as? [Double], !loc.isEmpty{
                long = loc[0]
                lat = loc[1]
            }
            formattedAddress = jobDict.getStringValue(key: "sDropAddress")
        }else{
            if let loc = jobDict["oPickLoc"] as? [Double], !loc.isEmpty{
                long = loc[0]
                lat = loc[1]
            }
            formattedAddress = jobDict.getStringValue(key: "sPickAddress")
        }
    }
    
    init(searchObj: SearchAddress) {
        lat = searchObj.lat
        long = searchObj.long
        addressLine1 = searchObj.address1
        addressLine2 = searchObj.address2
        city = searchObj.city
        state = searchObj.state
        country = searchObj.country
        zipCode = searchObj.zipcode
        formattedAddress = searchObj.formatedAddress
    }
    
    func getDistanceInMile(userLat: Double, userLong: Double) -> Double {
        let selfCoordinate = CLLocation(latitude: lat, longitude: long)
        let otherCoordinate = CLLocation(latitude: userLat, longitude: userLong)
        let distanceInMeters = selfCoordinate.distance(from: otherCoordinate) // result is in meters
        return distanceInMeters / _1mileToMeter
    }
}
