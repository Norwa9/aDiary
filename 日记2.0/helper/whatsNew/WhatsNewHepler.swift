//
//  WhatsNewHepler.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/8.
//

import Foundation
import WhatsNewKit
import UIKit

class WhatsNewHelper{
    ///每次更新前，只要创建对应版本号的whatsNew结构体，就可以对不同版本的用户显示不同的更新提示！
    static func whatsNewsFactory()->[WhatsNew]{
        var arr:[WhatsNew] = []
        
        let version = WhatsNew.Version(major: 3, minor: 8, patch: 1)
        let whatsNew = WhatsNew(
            // The Version
            version: version,
            // The Title
            title: "近期更新",
            // The features you want to showcase
            items: [
                WhatsNew.Item(
                    title: "新增<随机日记>小组件",
                    subtitle: "在桌面随机显示过往的日记",
                    image: UIImage(systemName: "shuffle.circle.fill")
                ),
                WhatsNew.Item(
                    title: "默认隐藏月份栏",
                    subtitle: "简化了主页面",
                    image: UIImage(systemName: "eye.slash.circle.fill")
                ),
                WhatsNew.Item(
                    title: "优化图片添加操作",
                    subtitle: "更方便地添加最近的图片",
                    image: UIImage(systemName: "hand.tap.fill")
                ),
                WhatsNew.Item(
                    title: "其他的一些小改动",
                    subtitle: "UI改进以及Bug优化",
                    image: UIImage(systemName: "checkmark.circle.fill")
                ),
                WhatsNew.Item(
                    title: "如有问题，可与开发者联系",
                    subtitle: "设置 -> 反馈",
                    image: UIImage(systemName: "bubble.left.and.bubble.right.fill")
                )
                
            ]
        )
        arr.append(whatsNew)
        
        return arr
    }
    
    
    static func getWhatsNewViewController() -> UIViewController?{
        if userDefaultManager.needShowWelcome{
            userDefaultManager.needShowWelcome = false
            return LWWelcomeViewController()
        }
        //MARK:-1:WhatsNew items
        let currentWhatsNew = whatsNewsFactory().get()
        
        //MARK:-2:custom configuration
        // Initialize default Configuration
        var configuration = WhatsNewViewController.Configuration()
        configuration.apply(animation: .slideDown)
        configuration.completionButton = WhatsNewViewController.CompletionButton(
            title:"知道了"
        )

        if userDefaultManager.purchaseEdition == .purchased{
            configuration.detailButton = WhatsNewViewController.DetailButton(
                title: "好评鼓励👏",
                action:.custom(action: { _ in
                    if let url = URL(string: "itms-apps://itunes.apple.com/app/id1564045149?action=write-review"){
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                })
            )
        }else{
            configuration.detailButton = WhatsNewViewController.DetailButton(
                title: "✨aDiary Pro 永久版仅需6元✨",
                action:.custom(action: { _ in
                    let iapVC = IAPViewController()
                    UIApplication.getTopViewController()?.present(iapVC, animated: true, completion: nil)
                })
            )
        }
        // And many more configuration properties...
        
        //MARK:-3:versionStore
        let versionStore:WhatsNewVersionStore = KeyValueWhatsNewVersionStore()
//        let versionStore:WhatsNewVersionStore = InMemoryWhatsNewVersionStore() // 测试环境
        
        guard let whatsNew = currentWhatsNew else{return nil}//无法取得（或没有定义）当前的whatsNew
        let whatsNewViewController: WhatsNewViewController? = WhatsNewViewController(
            whatsNew: whatsNew,
            configuration: configuration,
            versionStore: versionStore
        )
        
        guard let viewController = whatsNewViewController else {
            // The user has already seen the WhatsNew-Screen for the current Version of your app
            return nil
        }
        
        if versionStore.has(version: WhatsNew.Version(major: 3, minor: 8, patch: 0))
        {
            return nil
        }
        
        
        return viewController
    }
}
