

import UIKit

/// Protocol for Presenting View Controller
public protocol View2ViewTransitionPresenting {
    
    /// Return initial transition view frame in window.
    func initialFrame(_ userInfo: [String: AnyObject]?, isPresenting: Bool) -> CGRect
    
    /// Return initial transition view.
    func initialView(_ userInfo: [String: AnyObject]?, isPresenting: Bool) -> UIView
    
    /// Prepare initial transition view (optional).
    func prepareInitialView(_ userInfo: [String: AnyObject]?, isPresenting: Bool) -> Void
}

extension View2ViewTransitionPresenting {
    func prepareInitialView(_ userInfo: [String: AnyObject]?, isPresenting: Bool) -> Void {
        
    }
}

/// Protocol for Presented View Controller
public protocol View2ViewTransitionPresented {
    
    /// Return destination transition view frame in window.
    func destinationFrame(_ userInfo: [String: AnyObject]?, isPresenting: Bool) -> CGRect
    
    /// Return destination transition view.
    func destinationView(_ userInfo: [String: AnyObject]?, isPresenting: Bool) -> UIView
    
    /// Prepare destination transition view (optional).
    func prepareDestinationView(_ userInfo: [String: AnyObject]?, isPresenting: Bool) -> Void
}

extension View2ViewTransitionPresented {
    func prepareDestinationView(_ userInfo: [String: AnyObject]?, isPresenting: Bool) -> Void {
        
    }
}
