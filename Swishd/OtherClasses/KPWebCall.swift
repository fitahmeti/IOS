//  Created by iOS Development Company on 12/12/16.
//  Copyright © 2016 iOS Development Company. All rights reserved.
//

import Foundation
import Alamofire

// MARK: Web Operation
class AccessTokenAdapter: RequestAdapter {
    private let accessToken: String
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.setValue(accessToken, forHTTPHeaderField: "Authorization")
        return urlRequest
    }
}

#if DEBUG
let _baseUrl = "http://ec2-18-221-37-87.us-east-2.compute.amazonaws.com:3000/api/v1/" // Dev URL
let _baseUrlFile = "http://ec2-18-221-37-87.us-east-2.compute.amazonaws.com:3000/public/uploads/"
#else
let _baseUrl = "http://ec2-18-221-37-87.us-east-2.compute.amazonaws.com:3000/api/v1/" // Live Url
let _baseUrlFile = "http://ec2-18-221-37-87.us-east-2.compute.amazonaws.com:3000/public/uploads/"
#endif

typealias WSBlock = (_ json: Any?, _ flag: Int) -> ()
typealias WSProgress = (Progress) -> ()?
typealias WSFileBlock = (_ path: String?, _ success: Bool) -> ()

class KPWebCall:NSObject{

    static var call: KPWebCall = KPWebCall()
    
    let manager: SessionManager
    var networkManager: NetworkReachabilityManager = NetworkReachabilityManager()!
    var headers: HTTPHeaders = [
        "Content-Type": "application/x-www-form-urlencoded"
    ]
    var toast: ValidationToast!
    var paramEncode: ParameterEncoding = URLEncoding.default
    var successBlock: (String, HTTPURLResponse?, AnyObject?, WSBlock) -> Void
    var errorBlock: (String, HTTPURLResponse?, NSError, WSBlock) -> Void
    
    override init() {
        manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
       
        // Will be called on success of web service calls.
        successBlock = { (relativePath, res, respObj, block) -> Void in
            // Check for response it should be there as it had come in success block
            if let response = res{
                kprint(items: "Response Code: \(response.statusCode)")
                kprint(items: "Response(\(relativePath)): \(String(describing: respObj))")
                
                if response.statusCode == 200 {
                    block(respObj, response.statusCode)
                } else {
                    if response.statusCode == 401{
                        if _user != nil{
                            _appDelegator.removeUserInfoAndNavToLogin()
                            if let msg = respObj?["error"] as? String{
                                _ = ValidationToast.showStatusMessage(message: msg, yCord: _topMsgBarConstant)
                            }else{
                                _ = ValidationToast.showStatusMessage(message: kTokenExpire, yCord: _topMsgBarConstant)
                            }
                        }
                        block([_appName: kInternetDown] as AnyObject, response.statusCode)
                    }else {
                        block(respObj, response.statusCode)
                    }
                }
            } else {
                // There might me no case this can get execute
                block(nil, 404)
            }
        }
        
        // Will be called on Error during web service call
        errorBlock = { (relativePath, res, error, block) -> Void in
            // First check for the response if found check code and make decision
            if let response = res {
                kprint(items: "Response Code: \(response.statusCode)")
                kprint(items: "Error Code: \(error.code)")
                if let data = error.userInfo["com.alamofire.serialization.response.error.data"] as? NSData {
                    let errorDict = (try? JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSDictionary
                    if errorDict != nil {
                        kprint(items: "Error(\(relativePath)): \(errorDict!)")
                        block(errorDict!, response.statusCode)
                    } else {
                        let code = response.statusCode
                        block(nil, code)
                    }
                } else {
                    block(nil, response.statusCode)
                }
                // If response not found rely on error code to find the issue
            } else if error.code == -1009  {
                kprint(items: "Error(\(relativePath)): \(error)")
                block([_appName: kInternetDown] as AnyObject, error.code)
                return
            } else if error.code == -1003  {
                kprint(items: "Error(\(relativePath)): \(error)")
                block([_appName: kHostDown] as AnyObject, error.code)
                return
            } else if error.code == -1001  {
                kprint(items: "Error(\(relativePath)): \(error)")
                block([_appName: kTimeOut] as AnyObject, error.code)
                return
            } else {
                kprint(items: "Error(\(relativePath)): \(error)")
                block(nil, error.code)
            }
        }
        super.init()
        addInterNetListner()
    }
    
    deinit {
        networkManager.stopListening()
    }
}

// MARK: Other methods
extension KPWebCall{
    func getFullUrl(relPath : String) throws -> URL{
        do{
            if relPath.lowercased().contains("http") || relPath.lowercased().contains("www"){
                return try relPath.asURL()
            }else{
                return try (_baseUrl+relPath).asURL()
            }
        }catch let err{
            throw err
        }
    }
    
    func setAccesTokenToHeader(token:String){
        manager.adapter = AccessTokenAdapter(accessToken: token)
    }
    
    func removeAccessTokenFromHeader(){
        manager.adapter = nil
    }
}

// MARK: - Request, ImageUpload and Dowanload methods
extension KPWebCall{
    func getRequest(relPath: String, param: [String: Any]?, headerParam: HTTPHeaders?, block: @escaping WSBlock)-> DataRequest?{
        do{
            kprint(items: "Url: \(try getFullUrl(relPath: relPath))")
            kprint(items: "Param: \(String(describing: param))")
            return manager.request(try getFullUrl(relPath: relPath), method: HTTPMethod.get, parameters: param, encoding: paramEncode, headers: (headerParam ?? headers)).responseJSON { (resObj) in
                switch resObj.result{
                case .success:
                    if let resData = resObj.data{
                        do {
                            let res = try JSONSerialization.jsonObject(with: resData, options: []) as AnyObject
                            self.successBlock(relPath, resObj.response, res, block)
                        } catch let errParse{
                            kprint(items: errParse)
                            self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                        }
                    }
                    break
                case .failure(let err):
                    kprint(items: err)
                    self.errorBlock(relPath, resObj.response, err as NSError, block)
                    break
                }
            }
        }catch let error{
            kprint(items: error)
            errorBlock(relPath, nil, error as NSError, block)
            return nil
        }
    }
    
    func postRequest(relPath: String, param: [String: Any]?, headerParam: HTTPHeaders?, block: @escaping WSBlock)-> DataRequest?{
        do{
            kprint(items: "Url: \(try getFullUrl(relPath: relPath))")
            kprint(items: "Param: \(String(describing: param))")
            return manager.request(try getFullUrl(relPath: relPath), method: HTTPMethod.post, parameters: param, encoding: paramEncode, headers: (headerParam ?? headers)).responseJSON { (resObj) in
                switch resObj.result{
                case .success:
                    if let resData = resObj.data{
                        do {
                            let res = try JSONSerialization.jsonObject(with: resData, options: []) as AnyObject
                            self.successBlock(relPath, resObj.response, res, block)
                        } catch let errParse{
                            kprint(items: errParse)
                            self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                        }
                    }
                    break
                case .failure(let err):
                    kprint(items: err)
                    self.errorBlock(relPath, resObj.response, err as NSError, block)
                    break
                }
            }
        }catch let error{
            kprint(items: error)
            errorBlock(relPath, nil, error as NSError, block)
            return nil
        }
    }
    
    func putRequest(relPath: String, param: [String: Any]?, headerParam: HTTPHeaders?, block: @escaping WSBlock)-> DataRequest?{
        do{
            kprint(items: "Url: \(try getFullUrl(relPath: relPath))")
            kprint(items: "Param: \(String(describing: param))")
            return manager.request(try getFullUrl(relPath: relPath), method: HTTPMethod.put, parameters: param, encoding: paramEncode, headers: (headerParam ?? headers)).responseJSON { (resObj) in
                switch resObj.result{
                case .success:
                    if let resData = resObj.data{
                        do {
                            let res = try JSONSerialization.jsonObject(with: resData, options: []) as AnyObject
                            self.successBlock(relPath, resObj.response, res, block)
                        } catch let errParse{
                            kprint(items: errParse)
                            self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                        }
                    }
                    break
                case .failure(let err):
                    kprint(items: err)
                    self.errorBlock(relPath, resObj.response, err as NSError, block)
                    break
                }
            }
        }catch let error{
            kprint(items: error)
            errorBlock(relPath, nil, error as NSError, block)
            return nil
        }
    }

    
    func deleteRequest(relPath: String, param: [String: Any]?, headerParam: HTTPHeaders?, block: @escaping WSBlock)-> DataRequest?{
        do{
            kprint(items: "Url: \(try getFullUrl(relPath: relPath))")
            kprint(items: "Param: \(String(describing: param))")
            return manager.request(try getFullUrl(relPath: relPath), method: HTTPMethod.delete, parameters: param, encoding: paramEncode, headers: (headerParam ?? headers)).responseJSON { (resObj) in
                switch resObj.result{
                case .success:
                    if let resData = resObj.data{
                        do {
                            let res = try JSONSerialization.jsonObject(with: resData, options: []) as AnyObject
                            self.successBlock(relPath, resObj.response, res, block)
                        } catch let errParse{
                            kprint(items: errParse)
                            self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                        }
                    }
                    break
                case .failure(let err):
                    kprint(items: err)
                    self.errorBlock(relPath, resObj.response, err as NSError, block)
                    break
                }
            }
        }catch let error{
            kprint(items: error)
            errorBlock(relPath, nil, error as NSError, block)
            return nil
        }
    }
    
    func uploadUserImages(relPath: String,imgs: [UIImage?],param: [String: String]?, keyStr : [String], headerParam: HTTPHeaders?, block: @escaping WSBlock, progress: WSProgress?){
        do{
            manager.upload(multipartFormData: { (formData) in
                for (idx,img) in imgs.enumerated(){
                    if let _ = img{
                        formData.append(UIImageJPEGRepresentation(img!, 0.4)!, withName: keyStr[idx], fileName: "image.jpeg", mimeType: "image/jpeg")
                    }
                }
                if let _ = param{
                    for (key, value) in param!{
                        formData.append(value.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: key)
                    }
                }
            }, to: try getFullUrl(relPath: relPath), method: HTTPMethod.post, headers: (headerParam ?? headers), encodingCompletion: { encoding in
                switch encoding{
                case .success(let req, _, _):
                    req.uploadProgress(closure: { (prog) in
                        progress?(prog)
                    }).responseJSON { (resObj) in
                        switch resObj.result{
                        case .success:
                            if let resData = resObj.data{
                                do {
                                    let res = try JSONSerialization.jsonObject(with: resData, options: []) as AnyObject
                                    self.successBlock(relPath, resObj.response, res, block)
                                } catch let errParse{
                                    kprint(items: errParse)
                                    self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                                }
                            }
                            break
                        case .failure(let err):
                            kprint(items: err)
                            self.errorBlock(relPath, resObj.response, err as NSError, block)
                            break
                        }
                    }
                    break
                case .failure(let err):
                    kprint(items: err)
                    self.errorBlock(relPath, nil, err as NSError, block)
                    break
                }
            })
        }catch let err{
            self.errorBlock(relPath, nil, err as NSError, block)
        }
    }
    
    func dowanloadFile(relPath : String, saveFileWithName: String, progress: WSProgress?, block: @escaping WSFileBlock){
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("pig.png")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        do{
            manager.download(try getFullUrl(relPath: relPath), to: destination).downloadProgress { (prog) in
                progress?(prog)
                }.response { (responce) in
                    if responce.error == nil, let path = responce.destinationURL?.path{
                        block(path, true)
                    }else{
                        block(nil, false)
                    }
                }.resume()
        }catch{
            block(nil, false)
        }
    }
}


// MARK: - Internet Availability
extension KPWebCall{
    func addInterNetListner(){
        networkManager.startListening()
        networkManager.listener = { (status) -> Void in
            if status == NetworkReachabilityManager.NetworkReachabilityStatus.notReachable{
                print("No InterNet")
                if self.toast == nil{
                    self.toast = ValidationToast.showStatusMessageForInterNet(message: kInternetDown)
                }
            }else{
                print("Internet Avail")
                if self.toast != nil{
                    self.toast.animateOut(duration: 0.2, delay: 0.2, completion: { () -> () in
                        if let window = self.toast.superview as? UIWindow{
                            window.rootViewController?.dismiss(animated: false, completion: nil)
                        }
                        self.toast.removeFromSuperview()
                        self.toast = nil
                    })
                }
            }
        }
    }
    
    func isInternetAvailable() -> Bool {
        if networkManager.isReachable{
            return true
        }else{
            return false
        }
    }
}

// MARK: - Entry
extension KPWebCall{
    
    func loginUser(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "---------- Login User ---------")
        let repPath = "login"
        _ = postRequest(relPath: repPath, param: param, headerParam: nil, block: block)
    }
    
    func forgotPassword(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "--------- Forgot Password ---------")
        let relPath = "forgetpassword"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func registerUser(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ User Registration -------------")
        let relPath = "register"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func checkForUserName(userName: String, block: @escaping WSBlock) -> DataRequest?{
        kprint(items: "------------- Check For User Name --------------")
        let relPath = "username"
        return postRequest(relPath: relPath, param: ["username": userName], headerParam: nil, block: block)
    }
}

// MARK: - User Related
extension KPWebCall {
    
    func getUserProfile(block: @escaping WSBlock) {
        kprint(items: "------------- Get User Profile -----------")
        let relPath = "profile"
        _ = getRequest(relPath: relPath, param: nil, headerParam: nil, block: block)
    }
    
    func sendPushToken(token: String, block: @escaping WSBlock) {
        kprint(items: "------------- Send Push Token ------------")
        let relPath = "savepushtoken"
        let param: [String: Any] = ["sPushToken": token, "sDeviceType": "IOS"]
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func logOutUser(block: @escaping WSBlock) {
        kprint(items: "------------ Log Out User -------------")
        let relPath = "logout"
        _ = getRequest(relPath: relPath, param: nil, headerParam: nil, block: block)
    }
    
    func setProfileInfo(param: [String: Any], img : UIImage? , block: @escaping WSBlock) {
        kprint(items: "------------ editprofile -----------")
        let relPath = "profile"
        if let imgUser = img{
            _ = uploadUserImages(relPath: relPath, imgs: [imgUser], param: param as? [String : String], keyStr: ["profile_image"], headerParam: nil, block: block, progress: nil)
        } else {
            _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
        }
    }
    
    func verifyIdProof(imgAddress : UIImage , imgPhoto : UIImage,  block: @escaping WSBlock) {
        kprint(items: "------------- Verify ID Proof -----------")
        let relPath = "uploadidproof"
        _ = uploadUserImages(relPath: relPath, imgs: [imgPhoto , imgAddress], param: nil, keyStr: ["verify_id_proof","verify_address_proof"], headerParam: nil, block: block, progress: nil)
    }
    
    func getQRcode(block: @escaping WSBlock) {
        kprint(items: "------------- Get QR Code for Proof -----------")
        let relPath = "verifications"
        _ = getRequest(relPath: relPath, param: nil, headerParam: nil, block: block)
    }
    
    func verifyMobile(param: [String: Any],block: @escaping WSBlock) {
        kprint(items: "------------- Verify Mobile Number -----------")
        let relPath = "mobile"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func connectToSocialMedia(param: [String: Any],block: @escaping WSBlock) {
        kprint(items: "------------- Connect User To Social Media -----------")
        let relPath = "socialmedia"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getSenderJob(offSet: Int, limit: Int, status: String?, searchStr: String, sortBy: String,block: @escaping WSBlock) {
        kprint(items: "---------- Get Sender Job -------------")
        let relPath = "senders"
        let param:[String: Any]
        if let sts = status{
            if !searchStr.isEmpty{
                param = ["iStart": offSet, "iLimit": limit, "eJobStatus": sts,"sortBy": sortBy, "vSearch" : searchStr]
            }else{
                param = ["iStart": offSet, "iLimit": limit, "eJobStatus": sts,"sortBy": sortBy]
            }
        }else{
            if !searchStr.isEmpty{
                param = ["iStart": offSet, "iLimit": limit,"sortBy": sortBy, "vSearch" : searchStr]
            }else{
                param = ["iStart": offSet, "iLimit": limit,"sortBy": sortBy]
            }
        }
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getSwishrJob(offSet: Int, limit: Int, status: String?, sortBy: String, searchStr: String, block: @escaping WSBlock) {
        kprint(items: "---------- Get Swishr Job -------------")
        let relPath = "swishrs"
        let param:[String: Any]
        if let sts = status{
            if searchStr.isEmpty{
                param = ["iStart": offSet, "iLimit": limit, "eJobStatus": sts,"sortBy": sortBy]
            }else{
                param = ["iStart": offSet, "iLimit": limit, "eJobStatus": sts,"sortBy": sortBy,"vSearch": searchStr]
            }
        }else{
            if searchStr.isEmpty{
                param = ["iStart": offSet, "iLimit": limit,"sortBy": sortBy]
            }else{
                param = ["iStart": offSet, "iLimit": limit,"sortBy": sortBy, "vSearch": searchStr]
            }
        }
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func addCustomerId(param: [String: Any], block: @escaping WSBlock){
        kprint(items: "---------- Add stripe customer Id --------")
        let relPath = "addStripe"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func isMobileNumberExist(code: String, mobile: String, block: @escaping WSBlock) {
        kprint(items: "----------- Check Mobile Number Availability ----------")
        let relPath = "checkMobile"
        _ = postRequest(relPath: relPath, param: ["countryCode": code, "mobile": mobile], headerParam: nil, block: block)
    }
}

// MARK: - Send Item
extension KPWebCall {

    func getItemSizeList(block: @escaping WSBlock) {
        kprint(items: "--------- Get Item Size List -----------")
        let relPath = "sizes"
        _ = postRequest(relPath: relPath, param: nil, headerParam: nil, block: block)
    }
    
    func sendItem(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "-------------- Send Item -------------")
        let relPath = "job"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
}

// MARK: - Swishd Point
extension KPWebCall{
    
    func getSwishedPoint(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "------------ Get Swishd Point -----------")
        let relPath = "offices"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getSwishdPointDetail(officeId: String, lat: Double, long: Double, block: @escaping WSBlock) {
        kprint(items: "---------- Get Swishd Point Detail -------------")
        let relPath = "viewoffice"
        _ = postRequest(relPath: relPath, param: ["sOfficeId": officeId, "sLatitude": lat, "sLongitude": long], headerParam: nil, block: block)
    }
}

// MARK: - Job
extension KPWebCall {

    func getJobDetail(jobId: String, block: @escaping WSBlock) {
        kprint(items: "---------- Get Job Detail -----------")
        let relPath = "job/\(jobId)"
        _ = getRequest(relPath: relPath, param: nil, headerParam: nil, block: block)
    }
    
    func addJobOffer(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "----------- Add Job Offer -----------")
        let relPath = "offer"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func cancelOffer(jId: String, block: @escaping WSBlock) {
        kprint(items: "--------- Cancel Job Offer ------------")
        let relPath = "offer/\(jId)"
        _ = deleteRequest(relPath: relPath, param: nil, headerParam: nil, block: block)
    }
    
    func getOfferJobList(param: [String: Any], block: @escaping WSBlock){
        kprint(items: "---------- Get Offer Job List -----------")
        let relPath = "offers"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getSwishrProfile(userId: String, block: @escaping WSBlock){
        kprint(items: "---------- Get Swisher Profile -----------")
        let relPath = "userprofile/\(userId)"
        _ = getRequest(relPath: relPath, param: nil, headerParam: nil, block: block)
    }
    
    func respondToOffer(param: [String: Any], block: @escaping WSBlock){
        kprint(items: "---------- Accept or Reject job Offer -----------")
        let relPath = "offerResponse"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func acceptOfferWithReceiver(param: [String: Any], block: @escaping WSBlock){
        kprint(items: "---------- Accept swisher offer -----------")
        let relPath = "recipient"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getJobActivity(jobId: String, block: @escaping WSBlock){
        kprint(items: "---------- Get Job Activity -----------")
        let relPath = "jobActivity/\(jobId)"
        _ = getRequest(relPath: relPath, param: nil, headerParam: nil, block: block)
    }
    
    func getMessageFormatList(msgFor: String, block: @escaping WSBlock)  {
        kprint(items: "---------- Get Message List -----------")
        let relPath = "messages"
        _ = postRequest(relPath: relPath, param: ["sMessageFor": msgFor], headerParam: nil, block: block)
    }
    
    func sendMessage(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "----------- Send Message -----------")
        let relPath = "sendmessage"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getSwishrUsername(param : [String : Any],block: @escaping WSBlock)-> DataRequest?{
        kprint(items: "---------- Get Swisher Username -----------")
        let relPath = "swishrlist"
        return postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
}

// MARK: - Search Job
extension KPWebCall{
    
    func getMostUsedSerach(block: @escaping WSBlock) {
        kprint(items: "--------- Get Most used searches list -----------")
        let relPath = "mostused"
        _ = postRequest(relPath: relPath, param: nil, headerParam: nil, block: block)
    }
    
    func getSavedSerachList(param : [String : Any], block: @escaping WSBlock) {
        kprint(items: "--------- Get Saved searches list -----------")
        let relPath = "searches"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }

    func searchJob(param: [String: Any],block: @escaping WSBlock) {
        kprint(items: "---------  Search job -----------")
        let relPath = "jobs"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func saveSearch(param: [String: Any],block: @escaping WSBlock) {
        kprint(items: "---------  Save Search -----------")
        let relPath = "search"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func searchJobBysearchId(param: [String: Any],block: @escaping WSBlock) {
        kprint(items: "---------  Search job By Search id -----------")
        let relPath = "searchjobs"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }

    func updateSaveSerach(param: [String: Any],block: @escaping WSBlock) {
        kprint(items: "--------- Update Save Search to list -----------")
        let relPath = "status"
        _ = putRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func removeSavedSerach(searchId: String,block: @escaping WSBlock) {
        kprint(items: "--------- Remove Save search from list -----------")
        let relPath = "search/\(searchId)"
        _ = deleteRequest(relPath: relPath, param: nil, headerParam: nil, block: block)
    }
    
    func hideSuggestedJob(jobID: String, block: @escaping WSBlock) {
        kprint(items: "---------  Hide Suggested job -----------")
        let relPath = "jobhide/\(jobID)"
        _ = putRequest(relPath: relPath, param: nil, headerParam: nil, block: block)
    }
}

// MARK: - Setting
extension KPWebCall{
    
    func getNotificationSetting(block: @escaping WSBlock) {
        kprint(items: "---------- Notification Setting List ---------")
        let repPath = "settings"
        _ = getRequest(relPath: repPath, param: nil, headerParam: nil, block: block)
    }
    
    func updateNotification(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "---------- Update Notification Setting ---------")
        let repPath = "setting"
        _ = putRequest(relPath: repPath, param: param, headerParam: nil, block: block)
    }
    
    func referFriend(param: [String: Any], block: @escaping WSBlock){
        kprint(items: "---------- Refer a Friend -----------")
        let relPath = "invitefriend"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getNotification(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "---------- Notification List ---------")
        let repPath = "log"
        _ = postRequest(relPath: repPath, param: param, headerParam: nil, block: block)
    }
}

// MARK: - Wallet
extension KPWebCall{
    
    func getHistroy(param: [String: Any], block: @escaping WSBlock) {
        kprint(items: "---------- Get Wallet Histroy ---------")
        let repPath = "history"
        _ = postRequest(relPath: repPath, param: param, headerParam: nil, block: block)
    }
    
    func addBankAccount(param: [String: Any], block: @escaping WSBlock){
        kprint(items: "---------- Add Bank Account Details--------")
        let relPath = "bank"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getBanksList(block: @escaping WSBlock){
        kprint(items: "---------- Get Bank Account List--------")
        let relPath = "bank"
        _ = getRequest(relPath: relPath, param: nil, headerParam: nil, block: block)
    }
    
    func getCharityList(block: @escaping WSBlock){
        kprint(items: "---------- Get Charity List--------")
        let relPath = "charity"
        _ = getRequest(relPath: relPath, param: nil, headerParam: nil, block: block)
    }

    func cashOut(param: [String: Any], block: @escaping WSBlock){
        kprint(items: "---------- Cash out from Wallet --------")
        let relPath = "cashout"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func payMent(param: [String: Any], block: @escaping WSBlock){
        kprint(items: "---------- Payment --------")
        let relPath = "payment"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
}

// MARK: - QRCode
extension KPWebCall {

    func scanCode(code: String, block: @escaping WSBlock) {
        kprint(items: "------------- Scan Code ----------------")
        let relPath = "scan"
        _ = postRequest(relPath: relPath, param: ["code" : code], headerParam: nil, block: block)
    }
    
    func confirmQRCode(scanId: String, block: @escaping WSBlock) {
        kprint(items: "----------- Confirm Scan Code -------------")
        let relPath = "scanconfirm"
        _ = postRequest(relPath: relPath, param: ["iScanId" : scanId], headerParam: nil, block: block)
    }
}
