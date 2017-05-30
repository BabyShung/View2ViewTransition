
import UIKit

public final class DismissAnimationController: NSObject {
    
    public weak var transition: TransitionController!
    
    //Will be used in interactive controller
    fileprivate(set) var initialView: UIView!
    fileprivate(set) var destinationView: UIView!
    
    fileprivate(set) var initialFrame: CGRect!
    fileprivate(set) var destinationFrame: CGRect!
    
    fileprivate(set) var initialSnapshotView: UIView!
    fileprivate(set) var destinationSnapshotView: UIView!
}

extension DismissAnimationController: UIViewControllerAnimatedTransitioning {
    // MARK: Transition
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transition.config.transitionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromObj = transitionContext.fromVC as? View2ViewTransitionPresented,
            let fromVC = fromObj as? UIViewController else { return }
        guard let toObj = transitionContext.toVC as? View2ViewTransitionPresenting,
            let toVC = toObj as? UIViewController else { return }
        
        let containerView = transitionContext.containerView
        let isPresenting = false
        
        /*
         Steps:
         1.get views/frames from protocol
         2.get initial/destination snapshot and hide both
         3.add subview fromVC.view
         4.set destination snapshot frame and add as subview(will fade in)
         4.set initial snapshot frame and add as subview(will fade out)
         5.animate
         */
        
        //1.Protocol - destination (PresentedVC)
        fromObj.prepareDestinationView(transition.userInfo, isPresenting: isPresenting)
        destinationView = fromObj.destinationView(transition.userInfo, isPresenting: isPresenting)
        destinationFrame = fromObj.destinationFrame(transition.userInfo, isPresenting: isPresenting)
        
        //1.Protocol - initial (PresentingVC)
        toObj.prepareInitialView(transition.userInfo, isPresenting: isPresenting)
        initialView = toObj.initialView(transition.userInfo, isPresenting: isPresenting)
        initialFrame = toObj.initialFrame(transition.userInfo, isPresenting: isPresenting)
        
        //2.Create Snapshot from Destination View
        initialSnapshotView = initialView.snapshotImageView()
        destinationSnapshotView = destinationView.snapshotImageView()
        
        //2.Hide Transisioning Views
        showTransitionViews(false)
        
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
        
        //4.Add destination Snapshot (presentedVC) and initial Snapshot (presentingVC)
        setSnapshotViewsFrame(destinationFrame)
        
        containerView.addSubview(destinationSnapshotView)
        containerView.addSubview(initialSnapshotView)
        
        initialSnapshotView.alpha = 0.0
        
        //5.Animation
        let duration = transitionDuration(using: transitionContext)
        let config = transition.config
        if transitionContext.isInteractive {
            
            UIView.animate(withDuration: duration,
                           delay: 0.0,
                           usingSpringWithDamping: config.cancelDamping,
                           initialSpringVelocity: config.cancelInitialVelocity,
                           options: config.cancelAnimations,
                           animations: {
                            
                            fromViewControllerView.alpha = 0.2
                            
            }, completion: nil)
        } else {
            UIView.animate(withDuration: duration,
                           delay: 0.0,
                           usingSpringWithDamping: config.finishDamping,
                           initialSpringVelocity: 0,
                           options: config.finishAnimations,
                           animations: {
                            
                            self.setSnapshotViewsFrame(self.initialFrame)
                            
                            self.initialSnapshotView.alpha = 1.0
                            fromViewControllerView.alpha = CGFloat.leastNormalMagnitude
                            
            }, completion: { _ in
                
                self.removeSnapshotViews()

                if isNeedToControlToViewController &&
                    self.transition.type == .presenting {
                    toViewControllerView.removeFromSuperview()
                }
                
                self.showTransitionViews(true)
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}

extension DismissAnimationController {
    public func removeSnapshotViews() {
        initialSnapshotView?.removeFromSuperview()
        destinationSnapshotView?.removeFromSuperview()
    }
    
    public func showTransitionViews(_ show: Bool) {
        initialView.isHidden = !show
        destinationView.isHidden = !show
    }
    
    public func setSnapshotViewsFrame(_ frame: CGRect) {
        destinationSnapshotView.frame = frame
        initialSnapshotView.frame = frame
    }
}
