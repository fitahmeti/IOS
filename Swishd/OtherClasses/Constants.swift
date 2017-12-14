import UIKit
import Foundation

let _screenSize     = UIScreen.main.bounds.size
let _screenFrame    = UIScreen.main.bounds

let _defaultCenter  = NotificationCenter.default
let _userDefault    = UserDefaults.standard
let _appDelegator   = UIApplication.shared.delegate! as! AppDelegate
let _application    = UIApplication.shared

let _facebookPermission              = ["public_profile", "email", "user_friends"]
let _facebookMeUrl                   = "me"
let _facebookAlbumUrl                = "me/albums"
let _facebookUserField: [String:Any] = ["fields" : "id,first_name,last_name,gender,birthday,email,education,work,picture.height(700)"]
let _facebookJobSchoolField          = ["fields" : "education,work"]
let _facebookAlbumField              = ["fields":"id,name,count,picture"]
let _facebookPhotoField              = ["fields":"id,picture"]

// Privacy and Terms URL
let _aboutUsUrl        = "https://www.google.com"
let _privacyUrl        = "https://www.google.com"
let _helpUrl            = "https://www.google.com"
let _termsUrl         = "https://www.google.com"

// MARK: Paging Structure

struct LoadMore{
    var index: Int = 0
    var isLoading: Bool = false
    var limit: Int = 20
    var isAllLoaded = false
    
    var offset: Int{
        return index * limit
    }
}

// Place Holder image
let _userPlaceImage = UIImage(named: "userPlace")

// Current loggedIn User
var _user: User!

let _heighRatio : CGFloat = {
    let ratio = _screenSize.height/736
    return ratio
}()

let _widthRatio : CGFloat = {
    let ratio = _screenSize.width/414
    return ratio
}()

let _serverFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    df.timeZone = TimeZone(secondsFromGMT: 0)
    df.locale = Locale(identifier: "en_US_POSIX")
    return df
}()

let _deviceFormatter: DateFormatter = {
    let df = DateFormatter()
    df.timeZone = TimeZone.current
    df.dateFormat = "MM-dd-yyyy"
    return df
}()

let _numberFormatter:NumberFormatter = {
    let format = NumberFormatter()
    format.locale = Locale(identifier: "en_GB")
    format.numberStyle = .currency
    return format
}()

//Place Holder image
let _placeImage = UIImage(named: "ic_placeholder")
let _highliteImage = UIImage(named: "image_Highlight")

// User Default keys
let swishdAuthTokenKey      = "swishdAuthorizationKey"

// MARK: Observers
let observerScanCompelte    = "ObserverScanningCompleted"

// MARK: Comment in release mode
func kprint(items: Any...) {
    #if DEBUG
        for item in items {
            print(item)
        }
    #endif
}

// MARK: - Settings Version Maintenance
func getAppVersionAndBuild() -> String{
    if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String{
        return "Version - \(version)(\(build))"
    }else{
        return ""
    }
}

func getAppversion() -> String{
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String{
        return version
    }else{
        return ""
    }
}

func setAppSettingsBundleInformation(){
    if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String{
        _userDefault.set(build, forKey: "application_build")
        _userDefault.set(version, forKey: "application_version")
        _userDefault.synchronize()
    }
}

extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
}

//MARK:- Constant
//-------------------------------------------------------------------------------------------
// Common
//-------------------------------------------------------------------------------------------
let _statusBarHeight           : CGFloat = _appDelegator.window!.rootViewController!.topLayoutGuide.length
let _topNavigationHeight       : CGFloat = 80 * _widthRatio
let _topMsgBarConstant         : CGFloat = _statusBarHeight + _topNavigationHeight
let _vcTransitionTime                    = 0.4
let _1mileToMeter              : Double  = 1609.34
let _browseAgeRangeExpandLimit : Int     = 10
let _imageFadeTransitionTime   : Double  = 0.3

//-------------------------------------------------------------------------------------------
// Custom Picker
//-------------------------------------------------------------------------------------------
/// Picker bottom constant
let _customDatePickerHideConstant: CGFloat  = 385 * _widthRatio
let _datePickerHideConstant  = 278 * _widthRatio
let _swdDatePickerhideConstant = 736 * _widthRatio
let _dataPickerHideConstant  = 278 * _widthRatio
let _rangePickerHideConstant = 278 * _widthRatio

// Picker Min - Max values
let _ageMinValue:      Double = 18
let _ageMaxValue:      Double = 80
let _distanceMaxValue: Double = 100
let _pickerAnimationTime      = 0.25

