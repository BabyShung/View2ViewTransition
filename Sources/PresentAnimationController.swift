
import UIKit

public final class PresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    public weak var transition: TransitionController!
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transition.config.transitionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromObj = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? View2ViewTransitionPresenting else { return }
        guard let toObj = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? View2ViewTransitionPresented,
            let toVC = toObj as? UIViewController else { return }
        
        let containerView = transitionContext.containerView

        let userInfo = transition.userInfo
        let isPresenting = true
        
        /*
         Steps:
         1.get views/frames from protocol
         2.get initial/destination snapshot and hide both
         3.add subview toVC.view (white bg)
         4.set initial snapshot frame and add as subview(will fade out)
         5.set destination snapshot frame and add as subview(will fade in)
         6.animate
         */
        
        //1.Protocol presenting
        fromObj.prepareInitialView(userInfo, isPresenting: isPresenting)
        let initialView = fromObj.initialView(userInfo, isPresenting: isPresenting)
        let initialFrame = fromObj.initialFrame(userInfo, isPresenting: isPresenting)
        
        //1.Protocol presented
        toObj.prepareDestinationView(userInfo, isPresenting: isPresenting)
        let destinationView = toObj.destinationView(userInfo, isPresenting: isPresenting)
        let destinationFrame = toObj.destinationFrame(userInfo, isPresenting: isPresenting)
        
        //2.Snapshot views
        let initialTransitionView = initialView.snapshotImageView()
        let destinationTransitionView = destinationView.snapshotImageView()
        
        //2.Hide Transisioning Views
        initialView.isHidden = true
        destinationView.isHidden = true
        
        //3.Add toVC View (PresentedVC)
        let toViewControllerView: UIView = toVC.view
        toViewControllerView.alpha = CGFloat.leastNormalMagnitude
        containerView.addSubview(toViewControllerView)
        
        //4.Add initial Snapshot (presentingVC)
        initialTransitionView.frame = initialFrame
        containerView.addSubview(initialTransitionView)
        
        //5.Add destination Snapshot (presentedVC)
        destinationTransitionView.frame = initialFrame
        containerView.addSubview(destinationTransitionView)
        destinationTransitionView.alpha = 0.0
        
        //6. Animation
        let duration = transitionDuration(using: transitionContext)
        let config = transition.config
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       usingSpringWithDamping: config.finishDamping,
                       initialSpringVelocity: config.finishInitialVelocity,
                       options: config.finishAnimations,
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
