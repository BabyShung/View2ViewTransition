
import UIKit

protocol One2OneTransitionViewsProtocol {
    func getTransitionView() -> UIView?
    func getEndContainerView() -> UIView?
    func transitionWillBegin(transitionView: UIView?,
                               container: UIView?,
                               presenting: Bool)
    func transitionDidComplete(transitionView: UIView?,
                               container: UIView?,
                               presenting: Bool)
}

class CrossDissolveAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    public weak var transitionController: TransitionController!
    
    private var presenting = false
    
    //    init?(fromDelegate: VideoTransitionViewsProtocol,
    //          toDelegate: VideoTransitionViewsProtocol, presenting: Bool) {
    //        super.init()
    //        self.fromDelegate = fromDelegate
    //        self.toDelegate = toDelegate
    //        self.presenting = presenting
    //    }
    
    var transitionDuration: TimeInterval = 0.5
    let fadeDuration = 0.13 //fade in/out duration
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else { return }
        guard let fromDelegate = fromVC as? One2OneTransitionViewsProtocol,
            let toDelegate = toVC as? One2OneTransitionViewsProtocol else { return }
        
        guard let transitionView = fromDelegate.getTransitionView(),
            let endContainer = toDelegate.getEndContainerView() else { return }
        
        let container = transitionContext.containerView
        
        //PS: we handle both present and dismiss
        let presenting = self.presenting
        let fromView = presenting ? fromVC.view : toVC.view
        let toView = presenting ? toVC.view : fromVC.view
        fromView?.alpha = 0
        toView?.alpha = 0
        container.addSubview(fromView!)
        container.addSubview(toView!)
        
        /*
         PS: UIDevice.currentDevice().orientation: this property always returns 0 unless orientation notifications have been enabled by calling
         */
        let currentOrient = UIDevice.current.orientation
        
        let presentByRotation = UI_USER_INTERFACE_IDIOM() != .pad &&
            presenting &&
            currentOrient != .unknown &&
            (currentOrient == .landscapeLeft || currentOrient == .landscapeRight)
        
        /*
         PS: special case when we dismiss from Landscape by a btn but not rotation
         We manually change frame of fromView
         */
        if !presenting {
            fromView?.frame = container.frame
        }
        
        transitionViewsUI(fromView!, toView: toView!, presenting: presenting)
        let delegate = presenting ? fromDelegate : toDelegate
        
        UIView.animate(withDuration: fadeDuration, animations: {
            container.alpha = 0
        }, completion: { [unowned self] _ in
            
            transitionView.removeFromSuperview()
            endContainer.addSubview(transitionView)
            NSLayoutConstraint.activate([
                transitionView.leadingAnchor.constraint(equalTo: endContainer.leadingAnchor),
                transitionView.trailingAnchor.constraint(equalTo: endContainer.trailingAnchor),
                transitionView.topAnchor.constraint(equalTo: endContainer.topAnchor),
                transitionView.bottomAnchor.constraint(equalTo: endContainer.bottomAnchor),
                ])
            
            if presentByRotation {
                /*
                 If we transition from ratation, we need to check if it's triggered by
                 clicking on a btn or by roatation
                 */
                if currentOrient == .landscapeLeft || currentOrient == .landscapeRight {
                    transitionView.frame = container.frame
                    toView?.frame = container.frame
                    endContainer.frame = container.frame
                }
            }
            
            /*
             PS: only the presentingVC will be notified
             */
            delegate.transitionWillBegin(transitionView: transitionView,
                                         container: container,
                                         presenting: presenting)
            
            self.transitionViewsUI(fromView!, toView: toView!, presenting: !presenting)
            
            UIView.animate(withDuration: self.fadeDuration, animations: {
                container.alpha = 1
            }, completion: { _ in
                
                /*
                 PS: only the presentingVC will be notified
                 */
                delegate.transitionDidComplete(transitionView: transitionView,
                                               container: endContainer,
                                               presenting: presenting)
                
                transitionContext.completeTransition(true)
            })
        })
    }
    
    //MARK: Helpers
    private func transitionViewsUI(_ fromView: UIView, toView: UIView, presenting: Bool) {
        fromView.alpha = presenting ? 1 : 0 //initial value
        toView.alpha = presenting ? 0 : 1 //initial value
    }
}
