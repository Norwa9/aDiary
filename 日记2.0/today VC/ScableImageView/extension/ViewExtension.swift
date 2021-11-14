//
//  ViewExtension.swift
//  BSText
//
//  Created by BlueSky on 2018/10/21.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit

extension UIView {
    
    /**
     Shortcut to set the view.layer's shadow
     
     @param color  Shadow Color
     @param offset Shadow offset
     @param radius Shadow radius
     */
    @objc func setLayerShadow(_ color: UIColor?, offset: CGSize, radius: CGFloat) {
        if let aColor = color?.cgColor {
            layer.shadowColor = aColor
        }
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = 1
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    /**
     Remove all subviews.
     
     @warning Never call this method inside your view's drawRect: method.
     */
    @objc func removeAllSubviews() {
        //[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        while subviews.count > 0 {
            subviews.last?.removeFromSuperview()
        }
    }
    
    /**
     Returns the view's view controller (may be nil).
     */
    @objc var viewController: UIViewController? {
        var view: UIView? = self
        while view != nil {
            let nextResponder = view?.next
            if (nextResponder is UIViewController) {
                return nextResponder as? UIViewController
            }
            view = view?.superview
        }
        return nil
    }
    
    ///< Shortcut for frame.origin.x.
    @objc var left: CGFloat {
        set {
            var frame: CGRect = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
        get {
            return frame.origin.x
        }
    }
    
    ///< Shortcut for frame.origin.y
    @objc var top: CGFloat {
        set {
            var frame: CGRect = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
        get {
            return frame.origin.y
        }
    }
    
    ///< Shortcut for frame.origin.x + frame.size.width
    @objc var right: CGFloat {
        set {
            var frame: CGRect = self.frame
            frame.origin.x = newValue - frame.size.width
            self.frame = frame
        }
        get {
            return frame.origin.x + frame.size.width
        }
    }
    
    ///< Shortcut for frame.origin.y + frame.size.height
    @objc var bottom: CGFloat {
        set {
            var frame: CGRect = self.frame
            frame.origin.y = newValue - frame.size.height
            self.frame = frame
        }
        get {
            return frame.origin.y + frame.size.height
        }
    }
    
    ///< Shortcut for frame.size.width.
    @objc var width: CGFloat {
        set {
            var frame: CGRect = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
        get {
            return frame.size.width
        }
    }
    
    ///< Shortcut for frame.size.height.
    @objc var height: CGFloat {
        set {
            var frame: CGRect = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
        get {
            return frame.size.height
        }
    }
    
    ///< Shortcut for center.x
    @objc var centerX: CGFloat {
        set {
            center = CGPoint(x: newValue, y: center.y)
        }
        get {
            return center.x
        }
    }
    
    ///< Shortcut for center.y
    @objc var centerY: CGFloat {
        set {
            center = CGPoint(x: center.x, y: newValue)
        }
        get {
            return center.y
        }
    }
    
    ///< Shortcut for frame.origin.
    @objc var origin: CGPoint {
        set {
            var frame: CGRect = self.frame
            frame.origin = newValue
            self.frame = frame
        }
        get {
            return frame.origin
        }
    }
    
    ///< Shortcut for frame.size.
    @objc var size: CGSize {
        set {
            var frame: CGRect = self.frame
            frame.size = newValue
            self.frame = frame
        }
        get {
            return frame.size
        }
    }
}

class Screen: NSObject {
    
    /// Screen Height With Portrait
    @objc static let height = globalConstantsManager.shared.kScreenHeight
    /// Screen Width With Portrait
    @objc static let width = globalConstantsManager.shared.kScreenWidth
    /// Screen Size With Portrait
    @objc static let size = CGSize(width: width, height: height)
}

