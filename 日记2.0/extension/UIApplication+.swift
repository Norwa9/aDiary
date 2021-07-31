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
        if let vc = UIApplication.getTopViewController() as? todayVC{
            return vc
        }else{
            print("无法获取todayVC")
            return nil
        }
    }
    
    static func getMonthVC() -> monthVC {
        return UIApplication.shared.windows[0].rootViewController as! monthVC
    }
    
    static func getTopbarView()-> topbarView {
        return UIApplication.getMonthVC().topbar
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
    
}
