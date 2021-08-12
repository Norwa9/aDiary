//
//  UIApplication_Extension.swift
//  日记2.0
//
//  Created by 罗威 on 2021/3/20.
//

import Foundation
import UIKit
extension UIApplication{
    static func getTodayVC() ->todayVC?{
        let vc = UIApplication.getTopViewController()
        if let todayVC = vc as? todayVC{
            return todayVC
        }else if let tagsView = vc as? tagsViewController{
            return tagsView.presentingViewController as? todayVC
        }else{
            print("无法获取todayVC")
            return nil
        }
    }
    
    static func getMonthVC() -> monthVC {
        return UIApplication.shared.windows[0].rootViewController as! monthVC
    }
    
    //返回最上层的ViewController
    class func getTopViewController(base: UIViewController? = UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
    
    static func getTopWindow() -> UIWindow{
        return UIApplication.shared.windows.filter {$0.isKeyWindow}.first!
    }
}
