
import UIKit

public final class PresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    public weak var transition: TransitionController!
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transition.config.transitionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromObj = transitionContext.fromVC as? View2ViewTransitionPresenting else { return }
        guard let toObj = transitionContext.toVC as? View2ViewTransitionPresented,
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
        let initialSnapshotView = initialView.snapshotImageView()
        let destinationSnapshotView = destinationView.snapshotImageView()
        
        //2.Hide Transisioning Views
        initialView.isHidden = true
        destinationView.isHidden = true
        
        //3.Add toVC View (PresentedVC)
        let toViewControllerView: UIView = toVC.view
        toViewControllerView.alpha = CGFloat.leastNormalMagnitude
        containerView.addSubview(toViewControllerView)
        
        //4.Add initial Snapshot (presentingVC)
        initialSnapshotView.frame = initialFrame
        containerView.addSubview(initialSnapshotView)
        
        //5.Add destination Snapshot (presentedVC)
        destinationSnapshotView.frame = initialFrame
        containerView.addSubview(destinationSnapshotView)
        destinationSnapshotView.alpha = 0.0
        
        //6. Animation
        let duration = transitionDuration(using: transitionContext)
        let config = transition.config
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       usingSpringWithDamping: config.finishDamping,
                       initialSpringVelocity: config.finishInitialVelocity,
                       options: config.finishAnimations,
                       animations: {
            
            initialSnapshotView.frame = destinationFrame
            initialSnapshotView.alpha = 0.0
            destinationSnapshotView.frame = destinationFrame
            destinationSnapshotView.alpha = 1.0
            toViewControllerView.alpha = 1.0
            
        }, completion: { _ in
                
            initialSnapshotView.removeFromSuperview()
            destinationSnapshotView.removeFromSuperview()
                
            initialView.isHidden = false
            destinationView.isHidden = false
                
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
