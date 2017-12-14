//
//  EntryData.swift
//  Swishd
//
//
//

import Foundation
import UIKit

enum EntryVCType {
    case login
    case register
    case forgotPass
}

struct EntryData {
    
    var fields:[Field] = []
    var type: EntryVCType = .login
    
    struct Field {
        var placeHolder = ""
        var value = ""
        var isValid = false
        
        init(place: String) {
            placeHolder = place
        }
    }
    
    init(typ: EntryVCType) {
        type = typ
        switch type {
        case .login:
            fields.append(Field(place: "Username/Email"))
            fields.append(Field(place: "Password"))
            break
        case .forgotPass:
            fields.append(Field(place: "Email"))
            break
        case .register:
            fields.append(Field(place: "First Name"))
            fields.append(Field(place: "Last Name"))
            fields.append(Field(place: "Email"))
            fields.append(Field(place: "Username"))
            fields.append(Field(place: "Password"))
            fields.append(Field(place: "Promo code (optional)"))
            break
        }
    }
    
    func isDataValid() -> (Bool, String) {
        for (idx,field) in fields.enumerated(){
            if field.value.isEmpty{
                if idx != 5{
                    return (false, "Please enter \(field.placeHolder).")
                }
            }
        }
        
        if type == .register && !fields[2].value.isValidEmailAddress(){
            return (false, kValidEmail)
        }else if type == .register && !fields[3].value.isValidUsername(){
            return (false, kValidUserName)
        }else if type == .register && !fields[3].isValid{
            return (false, kUserNameTaken)
        }else if type == .register && String.validatePassword(str: fields[4].value){
            return (false, kPasswordSmall)
        }else if type == .forgotPass && !fields[0].value.isValidEmailAddress(){
            return (false, kValidEmail)
        }
        return (true, "")
    }
    
    func getParamDict() -> [String: Any]{
        var dict:[String: Any] = [:]
        if type == .login{
            dict["email"] = fields[0].value
            dict["password"] = fields[1].value
        }else if type == .register{
            dict["first_name"] = fields[0].value
            dict["last_name"] = fields[1].value
            dict["email"] = fields[2].value
            dict["username"] = fields[3].value
            dict["password"] = fields[4].value
            dict["promocode"] = fields[5].value
        }else{
            dict["email"] = fields[0].value
        }
        return dict
    }
}
