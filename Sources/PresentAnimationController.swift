
import UIKit

public final class PresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    public weak var transitionController: TransitionController!
    
    public var transitionDuration: TimeInterval = 0.5
    public var usingSpringWithDamping: CGFloat = 2.3
    public var initialSpringVelocity: CGFloat = 0.0
    public var animationOptions: UIViewAnimationOptions = [.curveEaseInOut, .allowUserInteraction]
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? View2ViewTransitionPresenting , fromVC is UIViewController else { return }
        guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? View2ViewTransitionPresented , toVC is UIViewController else { return }
        
        let containerView = transitionContext.containerView

        let userInfo = transitionController.userInfo
        let isPresenting = true
        
        //protocol presenting
        fromVC.prepareInitialView(userInfo, isPresenting: isPresenting)
        let initialView = fromVC.initialView(userInfo, isPresenting: isPresenting)
        let initialFrame = fromVC.initialFrame(userInfo, isPresenting: isPresenting)
        
        //protocol presented
        toVC.prepareDestinationView(userInfo, isPresenting: isPresenting)
        let destinationView = toVC.destinationView(userInfo, isPresenting: isPresenting)
        let destinationFrame = toVC.destinationFrame(userInfo, isPresenting: isPresenting)
        
        //s
        let initialTransitionView = UIImageView(image: initialView.snapshotImage())
        initialTransitionView.clipsToBounds = true
        initialTransitionView.contentMode = .scaleAspectFill
        
        let destinationTransitionView = UIImageView(image: destinationView.snapshotImage())
        destinationTransitionView.clipsToBounds = true
        destinationTransitionView.contentMode = .scaleAspectFill
        
        // Hide Transisioning Views
        initialView.isHidden = true
        destinationView.isHidden = true
        
        // Add ToViewController's View
        let toViewControllerView: UIView = (toVC as! UIViewController).view
        toViewControllerView.alpha = CGFloat.leastNormalMagnitude
        containerView.addSubview(toViewControllerView)
        
        // Add Snapshot
        initialTransitionView.frame = initialFrame
        containerView.addSubview(initialTransitionView)
        
        destinationTransitionView.frame = initialFrame
        containerView.addSubview(destinationTransitionView)
        destinationTransitionView.alpha = 0.0
        
        // Animation
        let duration: TimeInterval = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: self.usingSpringWithDamping, initialSpringVelocity: self.initialSpringVelocity, options: self.animationOptions, animations: {
            
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
