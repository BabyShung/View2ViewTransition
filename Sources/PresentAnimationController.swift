
import UIKit

public final class PresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    public weak var transitionController: TransitionController!
    public var config: TransitionConfig = TransitionConfig()
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return config.transitionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromObj = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? View2ViewTransitionPresenting else { return }
        guard let toObj = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? View2ViewTransitionPresented,
            let toVC = toObj as? UIViewController else { return }
        
        let containerView = transitionContext.containerView

        let userInfo = transitionController.userInfo
        let isPresenting = true
        
        //protocol presenting
        fromObj.prepareInitialView(userInfo, isPresenting: isPresenting)
        let initialView = fromObj.initialView(userInfo, isPresenting: isPresenting)
        let initialFrame = fromObj.initialFrame(userInfo, isPresenting: isPresenting)
        
        //protocol presented
        toObj.prepareDestinationView(userInfo, isPresenting: isPresenting)
        let destinationView = toObj.destinationView(userInfo, isPresenting: isPresenting)
        let destinationFrame = toObj.destinationFrame(userInfo, isPresenting: isPresenting)
        
        //snapshot views
        let initialTransitionView = initialView.snapshotImageView()
        let destinationTransitionView = destinationView.snapshotImageView()
        
        // Hide Transisioning Views
        initialView.isHidden = true
        destinationView.isHidden = true
        
        // Add ToViewController's View
        let toViewControllerView: UIView = toVC.view
        toViewControllerView.alpha = CGFloat.leastNormalMagnitude
        containerView.addSubview(toViewControllerView)
        
        // Add Snapshot
        initialTransitionView.frame = initialFrame
        containerView.addSubview(initialTransitionView)
        
        destinationTransitionView.frame = initialFrame
        containerView.addSubview(destinationTransitionView)
        destinationTransitionView.alpha = 0.0
        
        // Animation
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       usingSpringWithDamping: config.usingSpringWithDamping,
                       initialSpringVelocity: config.initialSpringVelocity,
                       options: config.animationOptions,
                       animations: {
            
            initialTransitionView.frame = destinationFrame
            initialTransitionView.alpha = 0.0
            destinationTransitionView.frame = destinationFrame
            destinationTransitionView.alpha = 1.0
            toViewControllerView.alpha = 1.0
            
        }, completion: { _ in
                
            initialTransitionView.removeFromSuperview()
            destinationTransitionView.removeFromSuperview()
                
            initialView.isHidden = false
            destinationView.isHidden = false
                
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
