
import UIKit

public final class DismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    public weak var transitionController: TransitionController!
    
    public var transitionDuration: TimeInterval = 0.5
    public var usingSpringWithDamping: CGFloat = 3.3
    public var initialSpringVelocity: CGFloat = 0.0
    public var animationOptions: UIViewAnimationOptions = [.curveEaseInOut, .allowUserInteraction]
    
    public var usingSpringWithDampingCancelling: CGFloat = 0.3
    public var initialSpringVelocityCancelling: CGFloat = 0.0
    public var animationOptionsCancelling: UIViewAnimationOptions = [.curveEaseInOut, .allowUserInteraction]

    fileprivate(set) var initialView: UIView!
    fileprivate(set) var destinationView: UIView!
    
    fileprivate(set) var initialFrame: CGRect!
    fileprivate(set) var destinationFrame: CGRect!
    
    fileprivate(set) var initialTransitionView: UIView!
    fileprivate(set) var destinationTransitionView: UIView!

    // MARK: Transition
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.transitionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        // Get ViewControllers and Container View
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? View2ViewTransitionPresented , fromVC is UIViewController else {
            fatalError("No valid presenting view controller")
        }
        guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? View2ViewTransitionPresenting , toVC is UIViewController else {
            fatalError("No valid presented view controller")
        }
        
        let containerView = transitionContext.containerView
        
        fromVC.prepareDestinationView(self.transitionController.userInfo, isPresenting: false)
        self.destinationView = fromVC.destinationView(self.transitionController.userInfo, isPresenting: false)
        self.destinationFrame = fromVC.destinationFrame(self.transitionController.userInfo, isPresenting: false)
        
        toVC.prepareInitialView(self.transitionController.userInfo, isPresenting: false)
        self.initialView = toVC.initialView(self.transitionController.userInfo, isPresenting: false)
        self.initialFrame = toVC.initialFrame(self.transitionController.userInfo, isPresenting: false)
        
        // Create Snapshot from Destination View
        self.destinationTransitionView = UIImageView(image: destinationView.snapshotImage())
        self.destinationTransitionView.clipsToBounds = true
        self.destinationTransitionView.contentMode = .scaleAspectFill
        
        self.initialTransitionView = UIImageView(image: initialView.snapshotImage())
        self.initialTransitionView.clipsToBounds = true
        self.initialTransitionView.contentMode = .scaleAspectFill
                
        // Hide Transisioning Views
        initialView.isHidden = true
        destinationView.isHidden = true
        
        // Add To,FromViewController's View
        let toViewControllerView: UIView = (toVC as! UIViewController).view
        let fromViewControllerView: UIView = (fromVC as! UIViewController).view
        containerView.addSubview(fromViewControllerView)
        
        // This condition is to prevent getting white screen at dismissing when multiple view controller are presented.
        let isNeedToControlToViewController: Bool = toViewControllerView.superview == nil
        if isNeedToControlToViewController {
            containerView.addSubview(toViewControllerView)
            containerView.sendSubview(toBack: toViewControllerView)
        }
        
        // Add Snapshot
        self.destinationTransitionView.frame = destinationFrame
        containerView.addSubview(self.destinationTransitionView)
        
        self.initialTransitionView.frame = destinationFrame
        containerView.addSubview(self.initialTransitionView)
        self.initialTransitionView.alpha = 0.0
        
        // Animation
        let duration: TimeInterval = transitionDuration(using: transitionContext)
        
        if transitionContext.isInteractive {
            
            UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: self.usingSpringWithDampingCancelling, initialSpringVelocity: self.initialSpringVelocityCancelling, options: self.animationOptionsCancelling, animations: {
                fromViewControllerView.alpha = CGFloat.leastNormalMagnitude
            }, completion: nil)
            
        } else {
        
            UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: self.usingSpringWithDamping, initialSpringVelocity: self.initialSpringVelocity, options: self.animationOptions, animations: {
                
                self.destinationTransitionView.frame = self.initialFrame
                self.initialTransitionView.frame = self.initialFrame
                self.initialTransitionView.alpha = 1.0
                fromViewControllerView.alpha = CGFloat.leastNormalMagnitude
                
            }, completion: { _ in
                    
                self.destinationTransitionView.removeFromSuperview()
                self.initialTransitionView.removeFromSuperview()
                
                if isNeedToControlToViewController && self.transitionController.type == .presenting {
                    toViewControllerView.removeFromSuperview()
                }
                
                self.initialView.isHidden = false
                self.destinationView.isHidden = false
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}
