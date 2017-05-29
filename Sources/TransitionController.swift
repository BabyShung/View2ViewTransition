
import UIKit

public enum TransitionControllerType {
    case presenting
    case pushing
}

public final class TransitionController: NSObject {
    
    public var userInfo: [String: AnyObject]? = nil
    
    fileprivate(set) var presentingVC: UIViewController!
    fileprivate(set) var presentedVC: UIViewController!
    
    fileprivate(set) var type: TransitionControllerType = .presenting
    
    //present controller
    public lazy var presentAnimationController: PresentAnimationController = {
        let controller = PresentAnimationController()
        controller.transitionController = self //self is the delegate
        return controller
    }()
    
    //dismiss controller
    public lazy var dismissAnimationController: DismissAnimationController = {
        let controller = DismissAnimationController()
        controller.transitionController = self  //self is the delegate
        return controller
    }()
    
    //dismiss interative
    public lazy var dismissInteractiveTransition: DismissInteractiveTransition = {
        let interactiveTransition = DismissInteractiveTransition()
        interactiveTransition.transitionController = self  //self is the delegate
        
        interactiveTransition.animationController = self.dismissAnimationController
        return interactiveTransition
    }()
}

extension TransitionController {
    /// Present
    public func present<T: View2ViewTransitionPresented, U: View2ViewTransitionPresenting>(vc presentedViewController: T, from presentingViewController: U, completion: (() -> Void)?) where T: UIViewController, U: UIViewController {
        
        //setup
        let pan = UIPanGestureRecognizer(target: dismissInteractiveTransition,
                                         action: #selector(dismissInteractiveTransition.handlePanGesture(_:)))
        presentedViewController.view.addGestureRecognizer(pan)
        self.presentingVC = presentingViewController
        self.presentedVC = presentedViewController
        
        self.type = .presenting
        
        // Present
        presentingViewController.present(presentedViewController, animated: true, completion: completion)
    }
    
    /// Push
    public func push<T: View2ViewTransitionPresented, U: View2ViewTransitionPresenting>(vc presentedViewController: T, from presentingViewController: U)
        where T: UIViewController, U: UIViewController {
            
            guard let navigationController = presentingViewController.navigationController else {
                fatalError("No navigation controller")
            }
            
            //setup
            let pan = UIPanGestureRecognizer(target: dismissInteractiveTransition, action: #selector(dismissInteractiveTransition.handlePanGesture(_:)))
            presentedViewController.view.addGestureRecognizer(pan)
            self.presentingVC = presentingViewController
            self.presentedVC = presentedViewController
            
            self.type = .pushing
            
            // Push
            navigationController.pushViewController(presentedViewController, animated: true)
    }
}

extension TransitionController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentAnimationController
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissAnimationController
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return dismissInteractiveTransition.interactionInProgress ? dismissInteractiveTransition : nil
    }
}

extension TransitionController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController,
                                     animationControllerFor operation: UINavigationControllerOperation,
                                     from fromVC: UIViewController,
                                     to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            return presentAnimationController
        case .pop:
            return dismissAnimationController
        default:
            return nil
        }
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if animationController === dismissAnimationController &&
            dismissInteractiveTransition.interactionInProgress {
            return dismissInteractiveTransition
        }
        return nil
    }
}
