
import UIKit

public extension UIView {
    public func snapshotImage() -> UIImage? {
        let size = CGSize(width: floor(self.frame.size.width), height: floor(self.frame.size.height))
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
        }
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshot
    }
    
    public func snapshotImageView() -> UIImageView {
        let imageView = UIImageView(image: self.snapshotImage())
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }
}
