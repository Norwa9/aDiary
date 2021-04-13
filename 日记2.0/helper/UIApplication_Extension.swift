//
//  UIApplication_Extension.swift
//  日记2.0
//
//  Created by 罗威 on 2021/3/20.
//

import Foundation
import UIKit
extension UIApplication{
    static func getTodayVC() -> todayVC{
        let Container = UIApplication.shared.windows[0].rootViewController as! pageViewContainer
        let customPageViewController = Container.pageViewController
        return customPageViewController.viewControllerList[0] as! todayVC
    }
    
    static func getMonthVC() -> monthVC {
        let Container = UIApplication.shared.windows[0].rootViewController as! pageViewContainer
        let customPageViewController = Container.pageViewController
        return customPageViewController.viewControllerList[1] as! monthVC
    }
    
    static func getPageViewContainer() -> pageViewContainer{
        let Container = UIApplication.shared.windows[0].rootViewController as! pageViewContainer
        return Container
    }
    
    static func getcustomPageViewController() -> customPageViewController {
        let Container = UIApplication.shared.windows[0].rootViewController as! pageViewContainer
        return  Container.pageViewController
    }
    
    static func getTopbarView()->topbarView {
        let Container = UIApplication.shared.windows[0].rootViewController as! pageViewContainer
        return Container.topBar
    }
}
