
import UIKit

open class DismissInteractiveTransition: UIPercentDrivenInteractiveTransition {
    
    open var interactionInProgress: Bool = false
    
    open weak var transition: TransitionController!
    open weak var animationController: DismissAnimationController!
    
    open var initialPanPoint = CGPoint.zero
    
    fileprivate(set) var transitionContext: UIViewControllerContextTransitioning!
    
    open override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        super.startInteractiveTransition(transitionContext)
    }
    
    // MARK: Pan Gesture
    open func handlePanGesture(_ panGestureRecognizer: UIPanGestureRecognizer) {
        
        if panGestureRecognizer.state == .began {
            
            interactionInProgress = true
            initialPanPoint = panGestureRecognizer.location(in: panGestureRecognizer.view)
            
            //trigger?
            switch transition.type {
            case .presenting:
                transition.presentedVC.dismiss(animated: true, completion: nil)
            case .pushing:
                transition.presentedVC.navigationController!.popViewController(animated: true)
            }
            return
        }
        
        // Get Progress
        let range = Float(UIScreen.main.bounds.size.width)
        let location: CGPoint = panGestureRecognizer.location(in: panGestureRecognizer.view)
        let distance: Float = sqrt(powf(Float(initialPanPoint.x - location.x), 2.0) + powf(Float(initialPanPoint.y - location.y), 2.0))
        let progress = CGFloat(fminf(fmaxf((distance / range), 0.0), 1.0))
        
        // Get Translation
        let translation: CGPoint = panGestureRecognizer.translation(in: panGestureRecognizer.view)
        
        switch panGestureRecognizer.state {
        case .changed:
            update(progress)
            
            animationController.destinationTransitionView.alpha = 1.0
            animationController.initialTransitionView.alpha = 0.0
            
            // Affine Transform
            let scaleFactor: Float = 300
            let scale: CGFloat = CGFloat(fmaxf((scaleFactor - distance) / scaleFactor, 0.5))
            var transform = CGAffineTransform.identity
            transform = transform.scaledBy(x: scale, y: scale)
            transform = transform.translatedBy(x: translation.x/scale, y: translation.y/scale)
            
            animationController.destinationTransitionView.transform = transform
            animationController.initialTransitionView.transform = transform
            
        case .cancelled:
            interactionInProgress = false
            transitionContext.cancelInteractiveTransition()
        case .ended:
            interactionInProgress = false
            panGestureRecognizer.setTranslation(CGPoint.zero, in: panGestureRecognizer.view)
            
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
                                
                                self.animationController.destinationTransitionView.frame = self.animationController.destinationFrame
                                
                                self.animationController.initialTransitionView.frame = self.animationController.destinationFrame
                                
                }, completion: { _ in
                    
                    self.animationController.destinationTransitionView.removeFromSuperview()
                    self.animationController.initialTransitionView.removeFromSuperview()
                    
                    self.animationController.destinationView.isHidden = false
                    self.animationController.initialView.isHidden = false
                    //                    self.transitionController.presentingViewController.view.removeFromSuperview()
                    
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
                                
                                self.animationController.destinationTransitionView.alpha = 0.0
                                self.animationController.initialTransitionView.alpha = 1.0
                                
                                self.animationController.destinationTransitionView.frame = self.animationController.initialFrame
                                self.animationController.initialTransitionView.frame = self.animationController.initialFrame
                                
                }, completion: { _ in
                    
                    if self.transition.type == .pushing {
                        
                        self.animationController.destinationTransitionView.removeFromSuperview()
                        self.animationController.initialTransitionView.removeFromSuperview()
                        
                        self.animationController.initialView.isHidden = false
                        self.animationController.destinationView.isHidden = false
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
