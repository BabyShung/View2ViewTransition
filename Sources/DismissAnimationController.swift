
import UIKit

public final class DismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    public weak var transitionController: TransitionController!
    public var config: TransitionConfig = TransitionConfig()
    
    //Will be used in interactive controller
    fileprivate(set) var initialView: UIView!
    fileprivate(set) var destinationView: UIView!
    fileprivate(set) var initialFrame: CGRect!
    fileprivate(set) var destinationFrame: CGRect!
    fileprivate(set) var initialTransitionView: UIView!
    fileprivate(set) var destinationTransitionView: UIView!

    // MARK: Transition
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return config.transitionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromObj = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? View2ViewTransitionPresented,
            let fromVC = fromObj as? UIViewController else { return }
        guard let toObj = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? View2ViewTransitionPresenting,
            let toVC = toObj as? UIViewController else { return }
        
        let containerView = transitionContext.containerView
        let isPresenting = false
        
        /*
         Steps:
         1.get views/frames from protocol
         2.get initial/destination snapshot and hide both
         3.add subview fromVC.view
         4.set destination snapshot frame and add as subview(will fade in)
         5.set initial snapshot frame and add as subview(will fade out)
         6.animate
         */
        
        //1.Protocol - destination (PresentedVC)
        fromObj.prepareDestinationView(transitionController.userInfo, isPresenting: isPresenting)
        destinationView = fromObj.destinationView(transitionController.userInfo, isPresenting: isPresenting)
        destinationFrame = fromObj.destinationFrame(transitionController.userInfo, isPresenting: isPresenting)
        
        //1.Protocol - initial (PresentingVC)
        toObj.prepareInitialView(transitionController.userInfo, isPresenting: isPresenting)
        initialView = toObj.initialView(transitionController.userInfo, isPresenting: isPresenting)
        initialFrame = toObj.initialFrame(transitionController.userInfo, isPresenting: isPresenting)
        
        //2.Create Snapshot from Destination View
        initialTransitionView = initialView.snapshotImageView()
        destinationTransitionView = destinationView.snapshotImageView()
                
        //2.Hide Transisioning Views
        initialView.isHidden = true
        destinationView.isHidden = true
        
        //3.Add fromVC View (PresentedVC)
        let fromViewControllerView: UIView = fromVC.view
        containerView.addSubview(fromViewControllerView)
        
        // This condition is to prevent getting white screen at dismissing when multiple view controller are presented.
        let toViewControllerView: UIView = toVC.view
        let isNeedToControlToViewController = toViewControllerView.superview == nil
        if isNeedToControlToViewController {
            containerView.addSubview(toViewControllerView)
            containerView.sendSubview(toBack: toViewControllerView)
        }
        
        //4.Add destination Snapshot (presentedVC)
        destinationTransitionView.frame = destinationFrame
        containerView.addSubview(destinationTransitionView)
        
        //5.Add initial Snapshot (presentingVC)
        initialTransitionView.frame = destinationFrame
        containerView.addSubview(initialTransitionView)
        initialTransitionView.alpha = 0.0
        
        //6.Animation
        let duration = transitionDuration(using: transitionContext)
        
        if transitionContext.isInteractive {
            UIView.animate(withDuration: duration,
                           delay: 0.0,
                           usingSpringWithDamping: config.usingSpringWithDampingCancelling,
                           initialSpringVelocity: config.initialSpringVelocityCancelling,
                           options: config.animationOptionsCancelling,
                           animations: {
                            
                fromViewControllerView.alpha = CGFloat.leastNormalMagnitude
                            
            }, completion: nil)
        } else {
            UIView.animate(withDuration: duration,
                           delay: 0.0,
                           usingSpringWithDamping: config.usingSpringWithDamping,
                           initialSpringVelocity: config.initialSpringVelocity,
                           options: config.animationOptions,
                           animations: {
                
                self.destinationTransitionView.frame = self.initialFrame
                self.initialTransitionView.frame = self.initialFrame
                self.initialTransitionView.alpha = 1.0
                fromViewControllerView.alpha = CGFloat.leastNormalMagnitude
                
            }, completion: { _ in
                    
                self.destinationTransitionView.removeFromSuperview()
                self.initialTransitionView.removeFromSuperview()
                
                if isNeedToControlToViewController &&
                    self.transitionController.type == .presenting {
                    toViewControllerView.removeFromSuperview()
                }
                
                self.initialView.isHidden = false
                self.destinationView.isHidden = false
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}
