//
//  EntryCell.swift
//  Swishd
//
//
//

import Foundation
import UIKit
import Alamofire

class EntryCell: ConstrainedTableViewCell, UITextFieldDelegate {
    
    @IBOutlet var tfInput: UITextField!
    @IBOutlet var lblPlace: UILabel!
    @IBOutlet var imgTick: UIImageView!
    @IBOutlet var tvTerms: LinkTextView!
    
    var dataTask : DataRequest?
    var type: EntryVCType = .login
    weak var parentLogin: LoginVC!
    weak var parentReg: RegisterVC!
    weak var parentForgot: ForgotPassVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareLoginUI() {
        tfInput.keyboardType = .asciiCapable
        tfInput.returnKeyType = .next
        tfInput.autocorrectionType = .no
        tfInput.autocapitalizationType = .none
        tfInput.isSecureTextEntry = false
        tfInput.placeholder = ""
        tfInput.tintColor = UIColor.swdThemeRedColor()
        lblPlace.text = parentLogin.data.fields[self.tag].placeHolder
        tfInput.text = parentLogin.data.fields[self.tag].value
        if self.tag == 1{
            tfInput.isSecureTextEntry = true
            tfInput.returnKeyType = .done
        }
    }
    
    func prepareRegUI() {
        tfInput.keyboardType = .asciiCapable
        tfInput.returnKeyType = .next
        tfInput.autocorrectionType = .no
        tfInput.autocapitalizationType = .none
        tfInput.isSecureTextEntry = false
        imgTick.isHidden = true
        lblPlace.text = parentReg.data.fields[self.tag].placeHolder
        tfInput.placeholder = ""
        tfInput.text = parentReg.data.fields[self.tag].value
        if self.tag == 0 || self.tag == 1{
            tfInput.autocapitalizationType = .words
        }else if self.tag == 2{
            tfInput.keyboardType = .emailAddress
        }else if self.tag == 3{
            imgTick.isHidden = !parentReg.data.fields[self.tag].isValid
        }else if self.tag == 4{
            tfInput.isSecureTextEntry = true
        }else if self.tag == 5{
            tfInput.returnKeyType = .done
        }
    }
    
    func prepareForgotUI() {
        tfInput.keyboardType = .emailAddress
        tfInput.returnKeyType = .done
        tfInput.autocorrectionType = .no
        tfInput.autocapitalizationType = .none
        tfInput.text = parentForgot.data.fields[self.tag].value
    }
    
    @IBAction func textFieldChange(_ sender: UITextField) {
        switch type {
        case .login:
            parentLogin.data.fields[self.tag].value = sender.text!.trimmedString()
            break
        case .register:
            if self.tag == 3{
                isUserNameValid(str: sender.text!)
            }else{
                parentReg.data.fields[self.tag].value = sender.text!.trimmedString()
            }
            break
        case .forgotPass:
            parentForgot.data.fields[self.tag].value = sender.text!.trimmedString()
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next{
            if type == .login{
                parentLogin.scrollToIndex(index: self.tag + 1)
                let cell = parentLogin.tableViewCell(index: self.tag + 1) as! EntryCell
                cell.tfInput.becomeFirstResponder()
            }else{
                parentReg.scrollToIndex(index: self.tag + 1)
                let cell = parentReg.tableViewCell(index: self.tag + 1) as! EntryCell
                cell.tfInput.becomeFirstResponder()
            }
        }else{
            textField.resignFirstResponder()
        }
        return true
    }
}

// MARK: - API Calls
extension EntryCell {
    
    func isUserNameValid(str: String) {
        var username = str
        username = username.replacingOccurrences(of: " ", with: "_")
        tfInput.text = username
        parentReg.data.fields[self.tag].value = username
        if username.isValidUsername(){
            dataTask?.cancel()
            dataTask = KPWebCall.call.checkForUserName(userName: username, block: { (json, status) in
                if status == 200{
                    self.parentReg.data.fields[self.tag].isValid = true
                    self.imgTick.isHidden = false
                }else{
                    self.parentReg.data.fields[self.tag].isValid = false
                    self.imgTick.isHidden = true
                }
            })
        }else{
            dataTask?.cancel()
            parentReg.data.fields[self.tag].isValid = false
            self.imgTick.isHidden = true
        }
    }
}
