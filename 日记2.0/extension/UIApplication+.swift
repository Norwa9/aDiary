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
            print("getTodayVC 无法获取todayVC")
            return nil
        }
    }
    
    /// 如果在编辑页，可以获取到当前的日记
    static func getCurDiaryModel() ->diaryInfo?{
        let todayVC = UIApplication.getTodayVC()
        return todayVC?.subpagesView.currentModel
    }
    
    static func getMonthVC() -> monthVC? {
        if let monthVC = UIApplication.shared.windows.first?.rootViewController as? monthVC{
            return monthVC
        }else{
            print("getMonthVC 失败")
            return nil
        }
    }
    
    //返回最上层的ViewController
    class func getTopViewController(base: UIViewController? = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
    
    static func getTopWindow() -> UIWindow?{
        return UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow } as? UIWindow
    }
}
