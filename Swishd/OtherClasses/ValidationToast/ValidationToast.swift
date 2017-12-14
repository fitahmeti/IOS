//  Created by Tom Swindell on 07/12/2015.
//  Copyright © 2015 The App Developers. All rights reserved.
//

import UIKit

class ValidationToast: UIView {

    // MARK:- Button Action
    @IBAction func btnTap (sender: UIButton){
        self.tapCompletions?(self)
    }
    
    // MARK: - Outlets
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var animatingViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var animatingView: UIView!
    
    // MARK:- Variables
    var tapCompletions: ((ValidationToast)->())?
    
    // MARK: - Initialisers
    class func instanceWithMessageFromNib(message: String, inView view: UIView, withColor color: UIColor, automaticallyAnimateIn shouldAnimate: Bool) -> ValidationToast {
        let toast = UINib(nibName: "ValidationToast", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ValidationToast
        toast.animatingViewBottomConstraint.constant = 28 * _widthRatio
        toast.layoutIfNeeded()
        toast.setToastMessage(message: message)
        toast.animatingView.backgroundColor = color
        view.addSubview(toast)
        var f = view.frame
        f.size.height = 28 * _widthRatio
        f.origin = CGPoint(x: 0, y: 64)
        toast.frame = f
        if shouldAnimate {
            toast.animateIn(duration: 0.2, delay: 0.0, completion: { () -> () in
                toast.animateOut(duration: 0.2, delay: 1.5, completion: { () -> () in
                    toast.removeFromSuperview()
                })
            })
        }
        return toast
    }
    
    // This will show alert message on status bar.
    class func showStatusMessageForInterNet(message: String, withColor color: UIColor = UIColor.swdRedColor()) -> ValidationToast {
        let toast: ValidationToast!
        if _statusBarHeight > 20{
            toast = UINib(nibName: "ValidationToast", bundle: nil).instantiate(withOwner: nil, options: nil)[1] as! ValidationToast
            toast.setToastMessage(message: message)
            toast.animatingView.backgroundColor = UIColor.white
        }else{
            toast = UINib(nibName: "ValidationToast", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ValidationToast
            toast.setToastMessage(message: message)
            toast.animatingView.backgroundColor = color
        }
        
        let vc = UIViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        
        let alertWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: _screenSize.width, height: _statusBarHeight))
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelStatusBar + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.addSubview(toast)
        alertWindow.layoutIfNeeded()
        alertWindow.rootViewController?.present(vc, animated: false, completion: nil)
        toast.animatingViewBottomConstraint.constant = _statusBarHeight//28 * _widthRatio
        var f = CGRect.zero
        f = UIScreen.main.bounds
        f.size.height = _statusBarHeight//28 * _widthRatio
        f.origin = CGPoint(x: 0, y: 0)
        toast.frame = f
        toast.layoutIfNeeded()
        toast.animateIn(duration: 0.2, delay: 0.2, completion: { () -> () in
        })
        return toast
    }
    
    // This will show alert message on status bar.
    class func showStatusMessage(message: String, yCord: CGFloat = 64, inView view: UIView? = nil, withColor color: UIColor = UIColor.swdRedColor()) -> ValidationToast {
        let toast = UINib(nibName: "ValidationToast", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ValidationToast
//        let strHeight = message.heightWithConstrainedWidth(width: _screenSize.width - 20, font: UIFont.systemFont(ofSize: 13 * _widthRatio)) + (10 * _widthRatio)
        let strHeight = message.heightWithConstrainedWidth(width: _screenSize.width - 20, font: UIFont.systemFont(ofSize: 14 * _widthRatio)) + (10 * _widthRatio)
        toast.layoutIfNeeded()
        toast.animatingViewBottomConstraint.constant = strHeight//28 * _widthRatio
        toast.setToastMessage(message: message)
        toast.animatingView.backgroundColor = color
        var f = CGRect.zero
        if let vw = view {
            vw.addSubview(toast)
            f = vw.frame
        } else {
            _appDelegator.window?.addSubview(toast)
            f = UIScreen.main.bounds
        }
        f.size.height = strHeight
        f.origin = CGPoint(x: 0, y: yCord)
        toast.frame = f
        toast.animateIn(duration: 0.2, delay: 0.2, completion: { () -> () in
            toast.animateOutWith(height: strHeight,duration: 0.2, delay: 1.5, completion: { () -> () in
                toast.removeFromSuperview()
            })
        })
        return toast
    }
    
    class func showBarMessage(message: String, inView view: UIView, withColor color: UIColor = UIColor.swdRedColor()) -> ValidationToast {
        let toast = UINib(nibName: "ValidationToastBar", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ValidationToast
        toast.animatingViewBottomConstraint.constant = 44
        toast.layoutIfNeeded()
        toast.setToastMessage(message: message)
        toast.animatingView.backgroundColor = color
        view.addSubview(toast)
        var f = view.frame
        f.size.height = 64
        f.origin = CGPoint.zero
        toast.frame = f
        toast.animateIn(duration: 0.2, delay: 0.2, completion: { () -> () in
            toast.animateOut(duration: 0.2, delay: 1.5, completion: { () -> () in
                toast.removeFromSuperview()
            })
        })
        return toast
    }
    
    // MARK: - Toast Functions
    private func setToastMessage(message: String) {
        let font = UIFont.systemFont(ofSize: 14 * _widthRatio)
        let color = UIColor.white
        let mutableString = NSMutableAttributedString(string: message)
        let range = NSMakeRange(0, message.count)
        mutableString.addAttribute(NSAttributedStringKey.font, value: font, range: range)
        mutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
        messageLabel.attributedText = mutableString
    }
    
    func animateIn(duration: TimeInterval, delay: TimeInterval, completion: (() -> ())?) {
        animatingViewBottomConstraint.constant = 0
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            self.layoutIfNeeded()
            }) { (completed) -> Void in
                completion?()
        }
    }
    
    func animateOut(duration: TimeInterval, delay: TimeInterval, completion: (() -> ())?) {
        animatingViewBottomConstraint.constant = 44
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            self.layoutIfNeeded()
            }) { (completed) -> Void in
                completion?()
        }
    }
    
    func animateOutWith(height: CGFloat, duration: TimeInterval, delay: TimeInterval, completion: (() -> ())?) {
        animatingViewBottomConstraint.constant = height
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            self.layoutIfNeeded()
        }) { (completed) -> Void in
            completion?()
        }
    }
}
