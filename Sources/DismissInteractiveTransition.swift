
import UIKit

open class DismissInteractiveTransition: UIPercentDrivenInteractiveTransition {
    
    open var inTransition: Bool = false
    
    open weak var transition: TransitionController!
    open weak var animationController: DismissAnimationController!
    
    open var initialPoint = CGPoint.zero
    
    fileprivate(set) var transitionContext: UIViewControllerContextTransitioning!
    
    open override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        super.startInteractiveTransition(transitionContext)
    }
    
    // MARK: Pan Gesture
    open func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {
        
        if panGesture.state == .began {
            
            inTransition = true
            initialPoint = panGesture.location(in: panGesture.view)
            
            //trigger?
            switch transition.type {
            case .presenting:
                transition.presentedVC.dismiss(animated: true, completion: nil)
            case .pushing:
                transition.presentedVC.navigationController!.popViewController(animated: true)
            }
            return
        }
        
        // Progress
        let current: CGPoint = panGesture.location(in: panGesture.view)
        let range = Float(UIScreen.main.bounds.size.width)
        let distance: Float = sqrt(powf(Float(initialPoint.x - current.x), 2.0) + powf(Float(initialPoint.y - current.y), 2.0))
        let progress = CGFloat(fminf(fmaxf((distance / range), 0.0), 1.0))
        
        // Translation
        let translation: CGPoint = panGesture.translation(in: panGesture.view)
        
        switch panGesture.state {
        case .changed:
            update(progress)
            
            animationController.destinationSnapshotView.alpha = 1.0
            animationController.initialSnapshotView.alpha = 0.0
            
            // Affine Transform
            let scaleFactor: Float = 300
            let scale: CGFloat = CGFloat(fmaxf((scaleFactor - distance) / scaleFactor, 0.5))
            var transform = CGAffineTransform.identity
            transform = transform.scaledBy(x: scale, y: scale)
            transform = transform.translatedBy(x: translation.x/scale, y: translation.y/scale)
            
            animationController.destinationSnapshotView.transform = transform
            animationController.initialSnapshotView.transform = transform
            
        case .cancelled:
            inTransition = false
            transitionContext.cancelInteractiveTransition()
        case .ended:
            inTransition = false
            panGesture.setTranslation(CGPoint.zero, in: panGesture.view)
            
            let config = animationController.transition.config
            
            if progress < config.finishLeastProgress { //Cancel
                cancel()
                
                let duration = Double(self.duration) * Double(1 - progress)
                UIView.animate(withDuration: duration,
                               delay: 0.0,
                               usingSpringWithDamping: config.cancelDamping,
                               initialSpringVelocity: config.cancelInitialVelocity,
                               options: config.cancelInteractiveAnimations,
                               animations: {
                                
                                self.animationController.setSnapshotViewsFrame(self.animationController.destinationFrame)
                                
                }, completion: { _ in
                    
                    self.animationController.removeSnapshotViews()
                    self.animationController.showTransitionViews(true)
                    //self.transitionController.presentingViewController.view.removeFromSuperview()
                    
                    self.transitionContext.completeTransition(false)
                })
                
            } else {
                finish()
                transition.presentingVC.view.isUserInteractionEnabled = false
                
                let duration = config.transitionDuration
                UIView.animate(withDuration: duration,
                               delay: 0.0,
                               usingSpringWithDamping: config.finishInteractiveDamping,
                               initialSpringVelocity: config.finishInitialVelocity,
                               options: config.finishInteractiveAnimations,
                               animations: {
                                
                                self.animationController.destinationSnapshotView.alpha = 0.0
                                self.animationController.initialSnapshotView.alpha = 1.0
                                
                                //fromVC
                                self.transitionContext.fromVC?.view.alpha = 0
                                
                                self.animationController.setSnapshotViewsFrame(self.animationController.initialFrame)
                                
                }, completion: { _ in
                    
                    if self.transition.type == .pushing {
                        self.animationController.removeSnapshotViews()
                        self.animationController.showTransitionViews(true)
                    }
                    
                    self.transition.presentingVC.view.isUserInteractionEnabled = true
                    self.animationController.initialView.isHidden = false
                    self.transitionContext.completeTransition(true)
                })
            }
        default:
            break
        }
    }
}
