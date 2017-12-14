////
////  SocialConnect.swift
////  Charmr
////
////  Created by iOS Development Company on 12/10/15.
////  Copyright © 2015 iOS Development Company All rights reserved.
////
//

import LinkedinSwift

struct SocialUser {
    var id: String
    var fName: String
    var lName: String
    var email: String
    var imgUrl: URL?
    
    var fullName: String {
        return "\(fName) \(lName)"
    }
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        fName = dict.getStringValue(key: "first_name")
        lName = dict.getStringValue(key: "last_name")
        email = dict.getStringValue(key: "email")
        //        gender = dict.getStringValue(key: "gender")
        if let urlStr = ((dict["picture"] as? NSDictionary)?["data"] as? NSDictionary)?["url"] as? String{
            imgUrl = URL(string: urlStr)
        }
    }
    
    init(googleUser: GIDGoogleUser) {
        id = googleUser.userID
        fName = googleUser.profile.givenName
        lName = googleUser.profile.familyName
        email = googleUser.profile.email
    }
    
    func fbParamDict() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["facebook_id"] = id
        dict["first_name"] = fName
        dict["last_name"] = lName
        dict["email"] = email
        if let url = imgUrl{
            dict["profile_image"] = url.absoluteString
        }
        return dict
    }
    
    func gleParamDict() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["google_id"] = id
        dict["first_name"] = fName
        dict["last_name"] = lName
        dict["email"] = email
        if let url = imgUrl{
            dict["profile_image"] = url.absoluteString
        }
        return dict
    }
}

class SocialViewController: ParentViewController {
    var googleBlock: ((GIDGoogleUser?) -> ())?
    let linkedinHelper = LinkedinSwiftHelper(configuration: LinkedinSwiftConfiguration(clientId: "81ay71uori1tbi", clientSecret: "oBX8eKA6Fk0gRYB3", state: "DLKDJF46ikMMZADfdfds", permissions: ["r_basicprofile", "r_emailaddress"], redirectUrl: "https://com.swishd/oauth"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension SocialViewController {
    
    @objc func connectToFacebook() {
        self.showCentralSpinner()
        loginWithFacebook(permission: _facebookPermission) { (fbToken, error) in
            if let _ = fbToken {
                self.fetchDataFromFacebook(graphPath: _facebookMeUrl, param: _facebookUserField, complitionHandler: { (userInfo, error) in
                    if let data = userInfo{
                        let fbUser = SocialUser(dict: data as NSDictionary)
                        kprint(items: fbUser)
                        self.connectUsertoFb(fbId: fbUser.id)
                    }else{
                        self.hideCentralSpinner()
                        _ = ValidationToast.showStatusMessage(message: error!.localizedDescription, yCord: _topMsgBarConstant)
                    }
                })
            } else {
                self.hideCentralSpinner()
                if let _ = error {
                    _ = ValidationToast.showStatusMessage(message: kFacebookConnectionError, yCord: _topMsgBarConstant)
                }
            }
        }
    }
    
    func connectUsertoFb(fbId : String){
        let dict = ["facebook_id" : fbId]
        connectUserToSocialMedia(paramDict: dict, isFromFb: true, isFromLnkdin: false)
    }
    
    //MARK: - FACEBOOK SDK
    func loginWithFacebook(permission: [Any], complitionHandler: @escaping ((_ authToken: String?, _ error: Error?)->())) {
        let fbSDKLoginManager = FBSDKLoginManager()
        fbSDKLoginManager.logOut()
        fbSDKLoginManager.logIn(withReadPermissions: permission, from: self) { (result, error) in
            DispatchQueue.main.async {
                if error != nil {
                    complitionHandler(nil, error)
                } else {
                    if let res = result {
                        if res.isCancelled {
                            kprint(items: "Cancelled: \(res.isCancelled)")
                            complitionHandler(nil, error)
                        } else if error == nil && !res.isCancelled && res.token != nil {
                            complitionHandler(res.token.tokenString, error)
                        }
                    } else {
                        complitionHandler(nil, error)
                        _ = ValidationToast.showStatusMessage(message: kInternalError, yCord: _topMsgBarConstant)
                    }
                }
            }
        }
    }
    
    func fetchDataFromFacebook(graphPath: String, param: [String:Any], complitionHandler: @escaping ((_ data: [String:Any]?, _ error: Error?)->())) {
        FBSDKGraphRequest(graphPath: graphPath, parameters: param).start(completionHandler: { (connection, userData, error) in
            DispatchQueue.main.async {
                if error != nil {
                    complitionHandler(nil, error)
                } else {
                    complitionHandler(userData as? [String:Any], error)
                }
            }
        })
    }
}

// MARK: - FB LogIn
extension SocialViewController {
    
    func connectToFacebookForLoginReg() {
        self.showCentralSpinner()
        loginWithFacebook(permission: _facebookPermission) { (fbToken, error) in
            if let _ = fbToken {
                self.fetchDataFromFacebook(graphPath: _facebookMeUrl, param: _facebookUserField, complitionHandler: { (userInfo, error) in
                    if let data = userInfo{
                        let fbUser = SocialUser(dict: data as NSDictionary)
                        self.signUserIn(param: fbUser.fbParamDict(), comp: { (success) in
                            self.hideCentralSpinner()
                            if success{
                                _appDelegator.prepareForLogin()
                                self.performSegue(withIdentifier: "homeSegue", sender: nil)
                            }
                        })
                    }else{
                        self.hideCentralSpinner()
                        _ = ValidationToast.showStatusMessage(message: error!.localizedDescription, yCord: _topMsgBarConstant)
                    }
                })
            } else {
                self.hideCentralSpinner()
                if let _ = error {
                    _ = ValidationToast.showStatusMessage(message: kFacebookConnectionError, yCord: _topMsgBarConstant)
                }
            }
        }
    }
    
    func signUserIn(param: [String: Any], comp: @escaping (Bool) -> ())  {
        self.loginUser(param: param, comp: { (success) in
            if success{
                self.getUserProfile(comp: { (done) in
                    if done{
                        comp(true)
                    }else{
                        comp(false)
                    }
                })
            }else{
                comp(false)
            }
        })
    }
}

// MARK: - Google Plus Login Extension
extension SocialViewController: GIDSignInUIDelegate, GIDSignInDelegate {
    
    
    func loginRegUserWithGoogle() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        
        self.showCentralSpinner()
        googleBlock = { (user) -> () in
            if let gUser = user{
                let gleUser = SocialUser(googleUser: gUser)
                self.signUserIn(param: gleUser.gleParamDict(), comp: { (success) in
                    self.hideCentralSpinner()
                    if success{
                        _appDelegator.prepareForLogin()
                        self.performSegue(withIdentifier: "homeSegue", sender: nil)
                    }
                })
            }else{
                self.hideCentralSpinner()
            }
        }
    }
    
    func connectToGoogle() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        
        self.showCentralSpinner()
        googleBlock = { (user) -> () in
            if let gUser = user{
                let gleUser = SocialUser(googleUser: gUser)
                self.connectUserWithGoogle(googleId: gleUser.id)
            }else{
                self.hideCentralSpinner()
            }
        }
    }
    
    func connectUserWithGoogle(googleId : String){
        let dict = ["google_id" : googleId]
        connectUserToSocialMedia(paramDict: dict, isFromFb: false, isFromLnkdin: false)
    }
    
    func connectUserToSocialMedia(paramDict : [String : Any] , isFromFb : Bool, isFromLnkdin: Bool){
        self.showCentralSpinner()
        KPWebCall.call.connectToSocialMedia(param: paramDict) { (json, flag) in
            self.hideCentralSpinner()
            if flag == 200 {
                if let dict = json as? NSDictionary{
                    if isFromFb{
                        _user.isFbVerify = true
                    }else if isFromLnkdin{
                        _user.isLinkdinVerify = true
                    }else{
                        _user.isGoogleVerify = true
                    }
                    if self.tableView != nil{
                        self.tableView.reloadData()
                    }
                    kprint(items: dict)
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
    // MARK: GIDSignInDelegate
    // The sign-in flow has finished and was successful if |error| is |nil|.
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            googleBlock?(user)
            // ...
        } else {
            _ = ValidationToast.showStatusMessage(message: error.localizedDescription, yCord: _topMsgBarConstant)
            googleBlock?(nil)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
}

// MARK: - LinkdIn Connect
extension SocialViewController{
    
    func connectWithLinkdin(){
        linkedinHelper.authorizeSuccess({ (token) in
            print(token)
            self.linkedinHelper.requestURL("https://api.linkedin.com/v1/people/~:(id,first-name,last-name,email-address,picture-url,picture-urls::(original),positions,date-of-birth,phone-numbers,location)?format=json", requestType: LinkedinSwiftRequestGet, success: { (response) -> Void in
                print(response)
                
                if let json = response.jsonObject as NSDictionary?{
                    let dict = ["linkedin_id" : json.getStringValue(key: "id")]
                    self.connectUserToSocialMedia(paramDict: dict, isFromFb: false, isFromLnkdin: true)
                }
              
            }) {(error) -> Void in
                print(error.localizedDescription)
                //handle the error
            }
        }, error: { (error) in
            print(error.localizedDescription)
            //show respective error
        }) {
            //show sign in cancelled event
            kprint(items: "error")
        }
    }
}
