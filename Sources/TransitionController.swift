
import UIKit

public enum TransitionControllerType {
    case presenting
    case pushing
}

public struct TransitionConfig {
    public var transitionDuration: TimeInterval = 0.4
    public var finishLeastProgress: CGFloat = 0.15
    
    public var finishDamping: CGFloat = 3.3
    public var finishInitialVelocity: CGFloat = 1.0
    public var finishAnimations: UIViewAnimationOptions = [.curveEaseInOut, .allowUserInteraction]
    
    public var finishInteractiveDamping: CGFloat = 1.5
    public var finishInteractiveAnimations: UIViewAnimationOptions = [.curveEaseOut, .allowUserInteraction]
    
    public var cancelDamping: CGFloat = 3.3
    public var cancelInitialVelocity: CGFloat = 0.0
    public var cancelAnimations: UIViewAnimationOptions = [.curveEaseInOut, .allowUserInteraction]
    
    public var cancelInteractiveAnimations: UIViewAnimationOptions = [.curveEaseOut, .allowUserInteraction]
}

public final class TransitionController: NSObject {
    
    public var userInfo: [String: AnyObject]? = nil
    public var config: TransitionConfig = TransitionConfig()
    
    fileprivate(set) var presentingVC: UIViewController!
    fileprivate(set) var presentedVC: UIViewController!
    
    fileprivate(set) var type: TransitionControllerType = .presenting
    
    //present controller
    public lazy var presentAnimationController: PresentAnimationController = {
        let controller = PresentAnimationController()
        controller.transition = self //self is the delegate
        return controller
    }()
    
    //dismiss controller
    public lazy var dismissAnimationController: DismissAnimationController = {
        let controller = DismissAnimationController()
        controller.transition = self  //self is the delegate
        return controller
    }()
    
    //dismiss interative
    public lazy var dismissInteractiveTransition: DismissInteractiveTransition = {
        let interactiveTransition = DismissInteractiveTransition()
        interactiveTransition.transition = self  //self is the delegate
        
        interactiveTransition.animationController = self.dismissAnimationController
        return interactiveTransition
    }()
}

extension TransitionController {
    /// Present
    public func present<T: View2ViewTransitionPresented, U: View2ViewTransitionPresenting>(vc presentedVC: T, from presentingVC: U, completion: (() -> Void)?) where T: UIViewController, U: UIViewController {
        
        //setup
        let pan = UIPanGestureRecognizer(target: dismissInteractiveTransition,
                                         action: #selector(dismissInteractiveTransition.handlePanGesture(_:)))
        presentedVC.view.addGestureRecognizer(pan)
        self.presentingVC = presentingVC
        self.presentedVC = presentedVC
        
        self.type = .presenting
        
        // Present
        presentingVC.present(presentedVC, animated: true, completion: completion)
    }
    
    /// Push
    public func push<T: View2ViewTransitionPresented, U: View2ViewTransitionPresenting>(vc presentedVC: T, from presentingVC: U)
        where T: UIViewController, U: UIViewController {
            
            guard let navigationController = presentingVC.navigationController else {
                fatalError("No navigation controller")
            }
            
            //setup
            let pan = UIPanGestureRecognizer(target: dismissInteractiveTransition, action: #selector(dismissInteractiveTransition.handlePanGesture(_:)))
            presentedVC.view.addGestureRecognizer(pan)
            self.presentingVC = presentingVC
            self.presentedVC = presentedVC
            
            self.type = .pushing
            
            // Push
            navigationController.pushViewController(presentedVC, animated: true)
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
