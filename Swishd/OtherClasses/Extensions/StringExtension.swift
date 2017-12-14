//  Created by Tom Swindell on 07/12/2015.
//  Copyright © 2015 The App Developers. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Registration Validation
extension String {
    
    static func validateStringValue(str:String?) -> Bool{
        var strNew = ""
        if str != nil{
            strNew = str!.trimWhiteSpace(newline: true)
        }
        if str == nil || strNew == "" || strNew.count == 0  {  return true  }
        else  {  return false  }
    }
    
    static func validatePassword(str:String?) -> Bool{
        if str == nil || str == "" || str!.count < 6  {  return true  }
        else  {  return false  }
    }
    
    func isValidUsername() -> Bool {
        let usernameRegex = "[A-Z0-9a-z_]{3,20}" //^[a-zA-Z0-9_]{3,15}$
        let temp = NSPredicate(format: "SELF MATCHES %@", usernameRegex).evaluate(with: self)
        return temp
    }
    
    func isValidName() -> Bool{
        let nameRegix = "(?:[\\p{L}\\p{M}]|\\d)"
        return NSPredicate(format: "SELF MATCHES %@", nameRegix).evaluate(with: self)
    }
    
    func isValidEmailAddress() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let temp = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
        return temp
    }

    func validateContact() -> Bool{
//        let contactRegEx = "^\\d{3}-\\d{3}-\\d{4}$"
        let contactRegEx = "^[0-9]{10,10}$"
        let contactTest = NSPredicate(format:"SELF MATCHES %@", contactRegEx)
        return contactTest.evaluate(with: self)
    }
    
    func validateBankAccNo() -> Bool{
        let accountRegEx = "^[0-9]{10,15}$"
        let accountTest = NSPredicate(format:"SELF MATCHES %@", accountRegEx)
        return accountTest.evaluate(with: self)
    }
    
//    func isValidMobileNumber() -> Bool{
//        let numkit = PhoneNumberKit()
//        do{
//            _ = try numkit.parse(self, ignoreType: true)
//            return true
//        }catch{
//            return false
//        }
//    }
//    
//    func getMobileString() -> String{
//        let numkit = PhoneNumberKit()
//        do{
//            let mobile = try numkit.parse(self, ignoreType: true)
//            return mobile.adjustedNationalNumber()
//        }catch{
//            return ""
//        }
//    }
//    
//    func getFormattedMobileString() -> String{
//        return PartialFormatter().formatPartial(self)
//    }
}

// MARK: - Character check
extension String {
    
    func trimmedString() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }
    
    func contains(find: String) -> Bool{
        return self.range(of: find, options: String.CompareOptions.caseInsensitive) != nil
    }
    
    func trimWhiteSpace(newline: Bool = false) -> String {
        if newline {
            return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        } else {
            return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
        }
    }
    
    func removeSpecial(_ character: String) -> String {
        let okayChars : Set<Character> = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
        return String(self.filter {okayChars.contains($0) })
    }
}


// MARK: - Layout
extension String {
    
    func isEqual(str: String) -> Bool {
        if self.compare(str) == ComparisonResult.orderedSame{
            return true
        }else{
            return false
        }
    }
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [NSStringDrawingOptions.usesLineFragmentOrigin], attributes: [NSAttributedStringKey.font: font], context: nil)
        return boundingBox.height
    }
    
    func WidthWithNoConstrainedHeight(font: UIFont) -> CGFloat {
        let width = CGFloat(999)
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        return boundingBox.width
    }
}
