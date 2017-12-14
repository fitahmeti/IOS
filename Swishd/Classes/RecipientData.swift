

import Foundation
import UIKit

class RecipientData{
    
    var isReceivedByMe: Bool = true
    var isPickByMe: Bool = true
    var isAppPickUser: Bool = false
    var isAppDropUser: Bool = false
    
    var pickSwishrName: String?
    var pickSwishrEmail: String?
    var pickUserFname: String?
    var pickUserLname: String?
    var pickUserEmail: String?
    var pickUserMobile: String?
    
    var dropSwishrName: String?
    var dropSwishrEmail: String?
    var dropUserFname: String?
    var dropUserLname: String?
    var dropUserEmail: String?
    var dropUserMobile: String?
    
    func getParamDict() -> [String: Any]{
        var dict: [String: Any] = [:]
        
        if !isPickByMe{
            if isAppPickUser{
                if let sName = pickSwishrName{
                    dict["sPickSwishrUserName"] = sName
                }
                if let sEmail = pickSwishrEmail{
                    dict["sPickSwishrEmail"] = sEmail
                }
            }else{
                if let uFname = pickUserFname{
                    dict["sPickFirstName"] = uFname
                }
                if let uLname = pickUserLname{
                    dict["sPickLastName"] = uLname
                }
                if let uEmail = pickUserEmail{
                    dict["sPickEmail"] = uEmail
                }
                if let uMobile = pickUserMobile{
                    dict["sPickMobile"] = uMobile
                }
            }
        }
        
        if !isReceivedByMe{
            if isAppDropUser{
                if let dSwihr = dropSwishrName{
                    dict["sRecievedSwishrUserName"] = dSwihr
                }
                if let dSwishrEmail = dropSwishrEmail{
                    dict["sRecievedSwishrEmail"] = dSwishrEmail
                }
            }else{
                if let dFname = dropUserFname{
                    dict["sRecievedFirstName"] = dFname
                }
                if let dLname = dropUserLname{
                    dict["sRecievedLastName"] = dLname
                }
                if let dEmail = dropUserEmail{
                    dict["sRecievedEmail"] = dEmail
                }
                if let dMobile = dropUserMobile{
                    dict["sRecievedMobile"] = dMobile
                }
            }
            
        }
        return dict
    }
    
    func isValidData() -> (valid: Bool, error: String) {
        
        var result = (valid: true, error: "")
        if !isPickByMe{
            if isAppPickUser{
                if  String.validateStringValue(str: pickSwishrName){
                    result.valid = false
                    result.error = kEnterPickSwishrName
                    return result
                }
                
                if  String.validateStringValue(str: pickSwishrEmail){
                    result.valid = false
                    result.error = kEnterPickSwishrEmail
                    return result
                }else if !(pickSwishrEmail?.isValidEmailAddress())! {
                    result.valid = false
                    result.error = kValidPickSwishrEmail
                    return result
                }
            }else{
                if  String.validateStringValue(str: pickUserFname){
                    result.valid = false
                    result.error = kEnterPickFname
                    return result
                }
                
                if pickUserMobile != nil && !(pickUserMobile?.isEmpty)!{
                    if !pickUserMobile!.validateContact() {
                        result.valid = false
                        result.error = kValidPickUserMobile
                        return result
                    }
                }
                
                if  String.validateStringValue(str: pickUserEmail){
                    result.valid = false
                    result.error = kEnterPickUseremail
                    return result
                }
                else if !(pickUserEmail?.isValidEmailAddress())! {
                    result.valid = false
                    result.error = kValidPickUseremail
                    return result
                }
            }
        }
        if !isReceivedByMe{
            if isAppDropUser{
                if  String.validateStringValue(str: dropSwishrName){
                    result.valid = false
                    result.error = kEnterDropSwishrName
                    return result
                }
                
                if  String.validateStringValue(str: dropSwishrEmail){
                    result.valid = false
                    result.error = kEnterDropSwishrEmail
                    return result
                }else if !(dropSwishrEmail?.isValidEmailAddress())! {
                    result.valid = false
                    result.error = kValidDropSwishrEmail
                    return result
                }
            }else{
                if  String.validateStringValue(str: dropUserFname){
                    result.valid = false
                    result.error = kEnterDropFname
                    return result
                }
                
                if dropUserMobile != nil && !(dropUserMobile?.isEmpty)!{
                    if !dropUserMobile!.validateContact() {
                        result.valid = false
                        result.error = kValidDropUserMobile
                        return result
                    }
                }
                
                if  String.validateStringValue(str: dropUserEmail){
                    result.valid = false
                    result.error = kEnterDropUseremail
                    return result
                }
                else if !(dropUserEmail?.isValidEmailAddress())! {
                    result.valid = false
                    result.error = kValidDropUseremail
                    return result
                }
            }
        }
        return result
    }
}
