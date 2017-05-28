
import UIKit

public extension UIView {
    
    public func snapshotImage() -> UIImage? {
        
        let size: CGSize = CGSize(width: floor(self.frame.size.width), height: floor(self.frame.size.height))
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        
        if let context: CGContext = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
        }
        let snapshot: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return snapshot
    }
}
