//
//  KPNavigationViewController.swift
//  SnapTag
//
//  Created by iOS Development Company on 19/04/16.
//  Copyright © 2016 iOS Development Company All rights reserved.
//

import UIKit

class KPNavigationViewController: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
    
    fileprivate let swipeInteractionController = SwipeInteractionController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weak var weakSelf: KPNavigationViewController? = self
        self.interactivePopGestureRecognizer?.delegate = weakSelf!
        self.delegate = weakSelf!
        self.isNavigationBarHidden = true
        self.navigationBar.isTranslucent = false
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool{
        if self.viewControllers.count > 1{
            return true
        }else{
            return false
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//        if viewController is VerificationVC || viewController is AccountInfoVC || viewController is SelfDescVC || viewController is HomeVC || viewController is EntryContainerVC || viewController is HomeContainerVC || viewController is HomePageViewVC{}else{
//            swipeInteractionController.wireToViewController(viewController)
//        }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // Add every non interactive view controller so controller dont go back automatically.
        if viewController is UITabBarController{
            self.interactivePopGestureRecognizer!.isEnabled = false
        }else{
            self.interactivePopGestureRecognizer!.isEnabled = true
        }
    }
    
//    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        
//        if operation == .push{
//            return Push()
//        }else if operation == .pop{
//            return Pop()
//        }else{
//            return nil
//        }
//    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return swipeInteractionController.interactionInProgress ? swipeInteractionController : nil
    }
}

class Push:NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return _vcTransitionTime
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        transitionContext.containerView.addSubview(toVC!.view)
        toVC?.view.frame = transitionContext.containerView.frame
        toVC?.view.alpha = 0.0
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            toVC?.view.alpha = 1.0
        }) { (finish) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

class Pop:NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return _vcTransitionTime
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        transitionContext.containerView.insertSubview(toVC!.view, belowSubview: fromVC!.view)
        toVC?.view.frame = transitionContext.containerView.frame
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            fromVC?.view.alpha = 0.0
        }) { (finish) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

class SwipeInteractionController: UIPercentDrivenInteractiveTransition {
    
    var interactionInProgress = false
    
    fileprivate var shouldCompleteTransition = false
    fileprivate weak var viewController: UIViewController!
    
    func wireToViewController(_ viewController: UIViewController!) {
        self.viewController = viewController
        prepareGestureRecognizerInView(viewController.view)
    }
    
    fileprivate func prepareGestureRecognizerInView(_ view: UIView) {
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        gesture.edges = UIRectEdge.left
        view.addGestureRecognizer(gesture)
    }
    
    @objc func handleGesture(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
        var progress = (translation.x / 200)
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
        switch gestureRecognizer.state {
        case .began:
            interactionInProgress = true
            _ = viewController.navigationController?.popViewController(animated: true)
        case .changed:
            shouldCompleteTransition = progress > 0.5
            update(progress)
        case .cancelled:
            interactionInProgress = false
            cancel()
        case .ended:
            interactionInProgress = false
            if !shouldCompleteTransition {
                cancel()
            } else {
                finish()
            }
        default:
            print("Unsupported")
        }
    }
}

