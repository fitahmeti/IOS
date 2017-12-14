//
//  ParentViewController.swift
//  manup
//
//  Created by iOS Development Company on 08/01/16.
//  Copyright © 2016 The App Developers. All rights reserved.
//

import UIKit

@objc protocol RefreshProtocol: NSObjectProtocol{
    @objc optional func refreshController()
}

class ParentViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var myColView: UICollectionView!
    @IBOutlet var lblTitle: UILabel?
    @IBOutlet var btnScan: UIButton?
    @IBOutlet var btnNotification: UIButton?
    
    /// Localize background
    @IBOutlet var imgBackground: UIImageView!
    @IBOutlet var imgAppBackground: UIImageView!
    @IBOutlet var blurViews: [BlurView]?
    @IBOutlet var blackLayerViews: [UIView]?

    @IBOutlet var horizontalConstraints: [NSLayoutConstraint]?
    @IBOutlet var verticalConstraints: [NSLayoutConstraint]?
    
    // MARK: - Actions
    @IBAction func parentBackAction(sender: UIButton!) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func parentDismissAction(sender: UIButton!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Variables for Pull to Referesh
    let referesh = UIRefreshControl()
    let pullToReferesh = UIControl()
    let viewLoader = UIView()
    var isRefereshing = false
   
    // MARK: - iOS Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        constraintUpdate()
        setDefaultUI()
        setLoaderUI()
        kprint(items: "Allocated: \(self.classForCoder)")
    }
    
    deinit{
        _defaultCenter.removeObserver(self)
        kprint(items: "Deallocated: \(self.classForCoder)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    
    // Set Default UI
    func setDefaultUI() {
        tableView?.scrollsToTop = true;
        tableView?.tableFooterView = UIView()
    }
    
    func setLoaderUI() {
        viewLoader.backgroundColor = UIColor.black.withAlphaComponent(0.70)
        viewLoader.layer.cornerRadius = 15
        viewLoader.layer.borderColor = UIColor.white.cgColor
        viewLoader.layer.borderWidth = 1.0
        activityIndicator.hidesWhenStopped = false
        activityIndicator.isHidden = false
    }
    
    // This will update constaints and shrunk it as device screen goes lower.
    func constraintUpdate() {
        if let hConts = horizontalConstraints {
            for const in hConts {
                let v1 = const.constant
                let v2 = v1 * _widthRatio
                const.constant = v2
            }
        }
        if let vConst = verticalConstraints {
            for const in vConst {
                let v1 = const.constant
                let v2 = v1 * _heighRatio
                const.constant = v2
            }
        }
    }
    
    // MARK: - Lazy Variables
    lazy internal var activityIndicator : UIActivityIndicatorView = {
        let act = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        act.color = UIColor.white
        return act
    }()
    
    lazy internal var smallActivityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: kActivitySmallImageName)!
        return CustomActivityIndicatorView(image: image)
    }()
    
    lazy internal var centralActivityIndicator : UIActivityIndicatorView = {
        let act = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        return act
    }()
    
    lazy internal var tableActivity : UIImageView = {
        let img = UIImage(named: kActivityTableImageName)!
        let imageView : UIImageView = UIImageView(image: UIImage(named: kActivityTableImageName)!)
        imageView.frame = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        return imageView
    }()
}

//MARK:- Uitility Methods
extension ParentViewController {
    
    func tableViewCell(index: Int) -> UITableViewCell {
        let cell = tableView.cellForRow(at: NSIndexPath(row: index, section: 0) as IndexPath)
        return cell!
    }
    
    func tableViewSegmentCell(index: Int , section : Int) -> UITableViewCell {
        let cell = tableView.cellForRow(at: NSIndexPath(row: index, section: section) as IndexPath)
        return cell!
    }
    
    func scrollToIndex(index: Int, animate: Bool = false){
        if index >= 0{
            let indexPath = NSIndexPath(row: index, section: 0)
            tableView.scrollToRow(at: indexPath as IndexPath, at: UITableViewScrollPosition.none, animated: animate)
        }
    }
    
    func scrollToIndexChat(section: Int, index: Int, animate: Bool = false){
        if index >= 0{
            let indexPath = NSIndexPath(row: index, section: section)
            tableView.scrollToRow(at: indexPath as IndexPath, at: UITableViewScrollPosition.top, animated: animate)
        }
    }
    
    func scrollToTop(animate: Bool = false) {
        let point = CGPoint(x: 0, y: -tableView.contentInset.top)
        tableView.setContentOffset(point, animated: animate)
    }
    
    func scroolToBottom(animate: Bool = false)  {
        let point = CGPoint(x: 0, y: tableView.contentSize.height + tableView.contentInset.bottom - tableView.frame.height)
        if point.y >= 0{
            tableView.setContentOffset(point, animated: animate)
        }
    }
    
    func customPresentationTransition() {
        let transition = CATransition()
        transition.duration = _vcTransitionTime
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        view.window?.layer.add(transition, forKey: kCATransition)
    }
    
    // Show API Error
    /// Desc
    ///
    /// - Parameters:
    ///   - data: json object
    ///   - yPos: Banner possition
    func showError(data: Any?,yPos: CGFloat = 64) {
        if let dict = data as? NSDictionary{
            if let msg = dict["message"] as? String{
                let _ = ValidationToast.showStatusMessage(message: msg, yCord: yPos, inView: self.view)
            }else if let msg = dict["error"] as? String{
                let _ = ValidationToast.showStatusMessage(message: msg, yCord: yPos, inView: self.view)
            }else if let msg = dict[_appName] as? String {
                if msg != kInternetDown{
                    let _ = ValidationToast.showStatusMessage(message: msg, yCord: yPos, inView: self.view)
                }
            }else{
                let _ = ValidationToast.showStatusMessage(message: kInternalError, yCord: yPos, inView: self.view)
            }
        }else{
            let _ = ValidationToast.showStatusMessage(message: kInternalError, yCord: yPos, inView: self.view)
        }
    }
    
    func showSucMsg(data: Any?,view: UIView? = nil,yPos: CGFloat = 64) {
        if let dict = data as? NSDictionary{
            if let msg = dict["message"] as? String{
                let _ = ValidationToast.showStatusMessage(message: msg, yCord: yPos, inView: view, withColor: UIColor.swdSuccessPopUp())
            }else if let msg = dict["error_description"] as? String{
                let _ = ValidationToast.showStatusMessage(message: msg, yCord: yPos, inView: view, withColor: UIColor.swdSuccessPopUp())
            }else if let msg = dict[_appName] as? String {
                if msg != kInternetDown{
                    let _ = ValidationToast.showStatusMessage(message: msg, yCord: yPos, inView: view, withColor: UIColor.swdSuccessPopUp())
                }
            }
        }
    }
}

//MARK: - TableView
extension ParentViewController{
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
}

// MARK: - Button Actions
extension ParentViewController {

    @IBAction func btnScanTap(_ sender: UIButton) {
        openScanner()
    }
    
    @IBAction func btnNotificationTap(_ sender: UIButton) {
        let notiVc = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        self.navigationController?.pushViewController(notiVc, animated: true)
    }
}

// MARK: - Scan Code Methods
extension ParentViewController {
    
    func openScanner() {
        let scanner = UIStoryboard(name: "Scanner", bundle: nil).instantiateInitialViewController()! as! ScannerVC
        scanner.completion = { (code) in ()
            self.scanCode(code: code)
        }
        self.present(scanner, animated: true, completion: nil)
    }
    
    func scanCode(code: String) {
        self.showCentralSpinner()
        KPWebCall.call.scanCode(code: code) { (json, status) in
            self.hideCentralSpinner()
            if status == 200{
                if let dict = (json as? NSDictionary)?["data"] as? NSDictionary{
                    let scan = ScanData(dict: dict)
                    self.showScanConfirmation(code: scan)
                }else{
                    self.showError(data: json, yPos: _topMsgBarConstant)
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
    
    func showScanConfirmation(code: ScanData) {
        let validation = code.validateCode()
        let alert = UIAlertController(title: "Scan", message: validation.1, preferredStyle: UIAlertControllerStyle.alert)
        if validation.0{
            let confirm = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { (action) in
                self.confirmScan(code: code)
            }
            alert.addAction(confirm)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func confirmScan(code: ScanData) {
        self.showCentralSpinner()
        KPWebCall.call.confirmQRCode(scanId: code.id) { (json, status) in
            self.hideCentralSpinner()
            if status == 200{
                _defaultCenter.post(name: NSNotification.Name(rawValue: observerScanCompelte), object: nil, userInfo: ["jobId": code.job.jobId])
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
}


//MARK:- Activity Indicator
extension ParentViewController{
    
    // This will show and hide spinner. In middle of container View
    // You can pass any view here, Spinner will be placed there runtime and removed on hide.
    func showSpinnerIn(container: UIView, control: UIButton, isCenter: Bool) {
        container.addSubview(activityIndicator)
        let xConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: container, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: container, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([xConstraint, yConstraint])
        activityIndicator.alpha = 0.0
        view.layoutIfNeeded()
        self.view.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.activityIndicator.alpha = 1.0
            if isCenter{
                control.alpha = 0.0
            }
        }
    }
    
    func hideSpinnerIn(container: UIView, control: UIButton) {
        self.view.isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
        control.isSelected = false
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.activityIndicator.alpha = 0.0
            control.alpha = 1.0
        }
    }
    
    func showSmallSpinnerIn(container: UIView, control: UIControl, isCenter: Bool) {
        container.addSubview(smallActivityIndicator)
        let xConstraint = NSLayoutConstraint(item: smallActivityIndicator, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: container, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: -8.5)
        let yConstraint = NSLayoutConstraint(item: smallActivityIndicator, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: container, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: -8.5)
        smallActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([xConstraint, yConstraint])
        smallActivityIndicator.alpha = 0.0
        view.layoutIfNeeded()
        self.view.isUserInteractionEnabled = false
        smallActivityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.smallActivityIndicator.alpha = 1.0
            if isCenter{
                control.alpha = 0.0
            }
        }
    }
    
    func hideSmallSpinnerIn(container: UIView, control: UIControl) {
        self.view.isUserInteractionEnabled = true
        smallActivityIndicator.stopAnimating()
        control.isSelected = false
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.smallActivityIndicator.alpha = 0.0
            control.alpha = 1.0
        }
    }
    
    func showCentralSpinner() {
        self.view.addSubview(viewLoader)
        self.view.addSubview(centralActivityIndicator)
        setConstraintsToLoderView()
        let xConstraint = NSLayoutConstraint(item: centralActivityIndicator, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: centralActivityIndicator, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        centralActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([xConstraint, yConstraint])
        centralActivityIndicator.alpha = 0.0
        viewLoader.alpha = 0.0
//        self.view.layoutIfNeeded()
        self.view.isUserInteractionEnabled = false
//        _appDelegator.window?.isUserInteractionEnabled = false
        centralActivityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.centralActivityIndicator.alpha = 1.0
            self.viewLoader.alpha = 1.0
        }
    }
    
    func setConstraintsToLoderView() {
        let xConstraint = NSLayoutConstraint(item: viewLoader, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: viewLoader, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        let hei = NSLayoutConstraint(item: viewLoader, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 70)
        let wid = NSLayoutConstraint(item: viewLoader, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 70)
        viewLoader.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([xConstraint, yConstraint, hei, wid])
    }
    
    func hideCentralSpinner() {
        self.view.isUserInteractionEnabled = true
//        _appDelegator.window?.isUserInteractionEnabled = true
        centralActivityIndicator.stopAnimating()
        viewLoader.removeFromSuperview()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.centralActivityIndicator.alpha = 0.0
        }
    }
}

// MARK: - Web call methods
extension ParentViewController {
    
    func loginUser(param: [String: Any], comp: @escaping (Bool) -> ()) {
        KPWebCall.call.loginUser(param: param) { (json, status) in
            if status == 200 {
                if let dict = json as? NSDictionary, let token = dict["Authorization"] as? String{
                    KPWebCall.call.setAccesTokenToHeader(token: token)
                    _appDelegator.storeAuthorizationToken(strToken: token)
                    comp(true)
                }else{
                    self.showError(data: json,yPos: _topMsgBarConstant)
                    comp(false)
                }
            }else{
                self.showError(data: json,yPos: _topMsgBarConstant)
                comp(false)
            }
        }
    }

    func getUserProfile(comp: @escaping (Bool) -> ()) {
        KPWebCall.call.getUserProfile { (json, status) in
            if status == 200 {
                if let dict = json as? NSDictionary, let userInfo = dict["userProfile"] as? NSDictionary{
                    _user = User.addUpdateEntity(key: "id", value: userInfo.getStringValue(key: "_id"))
                    _user.initWith(dict: userInfo)
                    _appDelegator.saveContext()
                    comp(true)
                }else{
                    self.showError(data: json,yPos: _topMsgBarConstant)
                    comp(false)
                }
            }else{
                self.showError(data: json,yPos: _topMsgBarConstant)
                comp(false)
            }
        }
    }
    
//    func showSuccessAlert(msg: String) {
//        let alert = UIAlertController(title: "Email Verification", message: msg, preferredStyle: UIAlertControllerStyle.alert)
//        let cancel = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) { (action) in
//            _ = self.navigationController?.popToRootViewController(animated: true)
//        }
//        alert.addAction(cancel)
//        self.present(alert, animated: true, completion: nil)
//    }

    func showEmailVerificationPopup(msg: String){
        let popup = EmailVerificationPopup.instantiateEmailVerificationViewFromNib(withView: self.view,msg: msg)
        popup.selectionBlock = {
            _ = self.navigationController?.popToRootViewController(animated: true)
        }
    }
}
