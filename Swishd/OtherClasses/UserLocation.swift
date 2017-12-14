//  Created by iOS Development Company on 26/01/16.
//  Copyright © 2016 The App Developers. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

enum LocationPermission: Int {
    case Accepted;
    case Denied;
    case Error;
}

class UserLocation: NSObject  {
    
    // MARK: - Variables
    var locationManger: CLLocationManager = {
        let lm = CLLocationManager()
        lm.activityType = .other
        lm.desiredAccuracy = kCLLocationAccuracyBest
        return lm
    }()
    
    // Will be assigned by host controller. If not set can throw Exception.
    typealias LocationBlock = (CLLocation?, NSError?)->()
    var completionBlock : LocationBlock? = nil
    weak var controller: UIViewController!
    
    // MARK: - Init
    static let sharedInstance = UserLocation()
    

    // MARk: - Func
    func fetchUserLocationForOnce(controller: UIViewController, block: LocationBlock?) {
        self.controller = controller
        locationManger.delegate = self
        completionBlock = block
        if checkAuthorizationStatus() {
            locationManger.startUpdatingLocation()
        }else{
            completionBlock?(nil,nil)
        }
    }
    
    func checkAuthorizationStatus() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        // If status is denied or only granted for when in use
        if status == CLAuthorizationStatus.denied || status == CLAuthorizationStatus.restricted {
            let title = "Location services are off"
            let msg = "To use location you must turn on 'WhenInUse' in the location services settings"
            
            let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
            
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            let settings = UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: { (action) in
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                }
            })
            
            alert.addAction(cancel)
            alert.addAction(settings)
            controller.present(alert, animated: true, completion: nil)
            return false
        } else if status == CLAuthorizationStatus.notDetermined {
            locationManger.requestWhenInUseAuthorization()
            return false
        } else if status == CLAuthorizationStatus.authorizedAlways || status == CLAuthorizationStatus.authorizedWhenInUse {
            return true
        }
        return false
    }
}

// MARK: - Location manager Delegation
extension UserLocation: CLLocationManagerDelegate {
  
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        DispatchQueue.main.async {
            self.completionBlock?(lastLocation,nil)
            self.locationManger.delegate = nil
            self.completionBlock = nil
        }
    }
    
    func addressFromlocation(location: CLLocation, block: @escaping (Address?)->()){
        let geoLocation = CLGeocoder()
        geoLocation.reverseGeocodeLocation(location, completionHandler: { (placeMarks, error) -> Void in
            if let pmark = placeMarks, pmark.count > 0 {
                let place :CLPlacemark = pmark.last! as CLPlacemark
                if let addr = place.addressDictionary {
                    
                    DispatchQueue.main.async {
                        block(Address(location: location, dict: addr as NSDictionary))
                    }
                }
            }else{
                DispatchQueue.main.async {
                    block(nil)
                }
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManger.delegate = nil
        DispatchQueue.main.async {
            self.completionBlock?(nil,error as NSError?)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        locationManger.startUpdatingLocation()
    }
}
