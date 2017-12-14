//
//  AppDelegate.swift
//  Swishd
//
//  Created by iOS Development Company on 9/4/17.
//  Copyright © 2017 iOS Development Company. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import Google
import Fabric
import Crashlytics
import LinkedinSwift
import UserNotifications
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var isPaymentAllow: Bool = true
    var tabBarLoaded:(()->())?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Init Fabric.
        Fabric.with([Crashlytics.self, STPAPIClient.self])
        
        if isUserLoggedIn(){
            self.navigateUserToHome()
            KPWebCall.call.setAccesTokenToHeader(token: getAuthorizationToken()!)
            getUserProfile()
            registerPushNotification()
        }
        
        // FireBase Configure
        FirebaseApp.configure()
    
        // Google LogIn
        prepareForGoogleLogin()
        
        // Stripe
        STPPaymentConfiguration.shared().publishableKey = "pk_live_7N83XoJ96Im7WsTaf2YL0nKC"
        // My account
        //"pk_live_IgAYkBjlrV3MxxckV8WRvOKZ"
        // Ben Hogen
        //pk_test_HbHOHe1bFo4SyWUU47MCXFDx //pk_live_7N83XoJ96Im7WsTaf2YL0nKC
        
        //SetUp Facebook
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Settings Version in Device settings
        setAppSettingsBundleInformation()
        
        // Check for internet
        if !KPWebCall.call.isInternetAvailable(){
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                KPWebCall.call.networkManager.listener?(NetworkReachabilityManager.NetworkReachabilityStatus.notReachable)
            })
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Swishd", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}

// MARK: - Hundle app open call
extension AppDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let isHundleByGoogle = GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        if isHundleByGoogle{
            return isHundleByGoogle
        }else if LinkedinSwiftHelper.shouldHandle(url) {
            return LinkedinSwiftHelper.application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        }else if canHundleDeepLink(url: url){
            return true
        } else{
            return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        }
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let isHundleByGoogle = GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
        if isHundleByGoogle{
            return isHundleByGoogle
        }else if LinkedinSwiftHelper.shouldHandle(url) {
            return LinkedinSwiftHelper.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        }else if canHundleDeepLink(url: url){
            return true
        }else{
            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        }
    }
    
    func canHundleDeepLink(url: URL) -> Bool {
        if let scheme = url.scheme, scheme == "swishddeeplink" {
            if let query = url.query {
                let comp = query.components(separatedBy: "=")
                if comp.count == 2{
                    if comp[0] == "jobId" {
                        let payLoad = PushNotification(id: comp[1])
                        self.redirectionFromPush(noti: payLoad)
                        return true
                    }
                }
            }
        }
        return false
    }
}

// MARK: - Authorization token
extension AppDelegate{
    
    func storeAuthorizationToken(strToken: String) {
        _userDefault.set(strToken, forKey: swishdAuthTokenKey)
        _userDefault.synchronize()
    }
    
    func getAuthorizationToken() -> String? {
        return _userDefault.value(forKey: swishdAuthTokenKey) as? String
    }
}

// MARK: - User Login and Logout
extension AppDelegate{
    
    func getUserProfile() {
        KPWebCall.call.getUserProfile { (json, status) in
            if status == 200 {
                if let dict = json as? NSDictionary, let userInfo = dict["userProfile"] as? NSDictionary{
                    _user = User.addUpdateEntity(key: "id", value: userInfo.getStringValue(key: "_id"))
                    _user.initWith(dict: userInfo)
                    _appDelegator.saveContext()
                }
            }
        }
    }
    
    func prepareForGoogleLogin() {
        // Initialize sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")
    }
    
    func isUserLoggedIn() -> Bool{
        let users = User.fetchDataFromEntity(predicate: nil, sortDescs: nil)
        if getAuthorizationToken() != nil && !users.isEmpty{
            _user = users.first
            return true
        }else{
            return false
        }
    }
    
    func navigateUserToHome() {
        let nav = _appDelegator.window?.rootViewController as! KPNavigationViewController
        let entContainer = UIStoryboard.init(name: "Entry", bundle: nil).instantiateViewController(withIdentifier: "EntryVC")
        let home = UIStoryboard.init(name: "Entry", bundle: nil).instantiateViewController(withIdentifier: "tabBarVc")
        nav.viewControllers = [entContainer, home]
        _appDelegator.window?.rootViewController = nav
    }
    
    func prepareForLogin() {
        registerPushNotification()
    }
    
    func prepareForLogout(block: @escaping ((Bool, Any?) -> ())) {
        KPWebCall.call.logOutUser { (json, status) in
            if status == 200{
                block(true, json)
                self.removeUserInfoAndNavToLogin()
            }else{
                block(false, json)
            }
        }
    }
    
    func removeUserInfoAndNavToLogin() {
        _userDefault.removeObject(forKey: swishdAuthTokenKey)
        _userDefault.removeObject(forKey: "LIAccessToken")
        _userDefault.synchronize()
        KPWebCall.call.removeAccessTokenFromHeader()
        deleteUserObject()
        if let nav = window?.rootViewController as? UINavigationController{
            nav.dismiss(animated: false, completion: nil)
            _ = nav.popToRootViewController(animated: true)
        }
        // Logout from FB
        let fbSDKLoginManager = FBSDKLoginManager()
        fbSDKLoginManager.logOut()
        GIDSignIn.sharedInstance().signOut()
    }
    
    func deleteUserObject() {
        _user = nil
        let users = User.fetchDataFromEntity(predicate: nil, sortDescs: nil)
        for user in users{
            _appDelegator.managedObjectContext.delete(user)
        }
        _appDelegator.saveContext()
    }
}

// MARK: - Firebase Notification
extension AppDelegate: UNUserNotificationCenterDelegate{
    
    func registerPushNotification() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { (granted, error) in
                kprint(items: "Notification Acccess: \(granted)")
            })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Auth.auth().setAPNSToken(deviceToken, type: .unknown)
        Messaging.messaging().apnsToken = deviceToken
        if let token = Messaging.messaging().fcmToken{
            KPWebCall.call.sendPushToken(token: token, block: { (json, status) in
                kprint(items: json ?? "")
            })
        }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void){
        let info = notification.request.content.userInfo
        kprint(items: info as NSDictionary)
        if Auth.auth().canHandleNotification(info){
            completionHandler([])
        }else{
            completionHandler([.alert, .badge, .sound])
        }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void){
        let info = response.notification.request.content.userInfo
        if Auth.auth().canHandleNotification(info){
            return completionHandler()
        }else{
            let push = PushNotification(dict: info as NSDictionary)
            self.redirectionFromPush(noti: push)
            return completionHandler()
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(userInfo){
            completionHandler(.noData)
            return
        }
    }
    
    func redirectionFromPush(noti: PushNotification)  {
        self.tabBarLoaded = { () -> () in
            self.tabBarLoaded = nil
            self.navigateUserForPush(noti: noti)
        }
        self.navigateUserForPush(noti: noti)
    }
    
    func navigateUserForPush(noti: PushNotification){
        if let tab = getTabBarVc(){
            self.tabBarLoaded = nil
            switch noti.type {
            case .jobAccept, .jobOffer, .jobReject, .journyInJob, .deepLinkJob:
                let jobDetail = UIStoryboard(name: "Job", bundle: nil).instantiateViewController(withIdentifier: "JobDetailVC") as! JobDetailVC
                jobDetail.jobId = noti.jobId
                tab.navigationController?.dismiss(animated: false, completion: nil)
                tab.navigationController!.pushViewController(jobDetail, animated: true)
                break
            case .payment:
                break
            default:
                break
            }
        }
    }
    
    func getTabBarVc() -> KPTabBarVC? {
        var tabBar: KPTabBarVC? = nil
        let nav = self.window?.rootViewController as! UINavigationController
        NSLog("---------- Nav ----------")
        NSLog("%@", nav.viewControllers)
        for vc in nav.viewControllers{
            if let tab = vc as? KPTabBarVC{
                if tab.isViewLoaded{
                    tabBar = tab
                }
                break
            }
        }
        return tabBar
    }
}
