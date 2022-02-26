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
        
        let version = WhatsNew.Version(major: 3, minor: 3, patch: 0)
        let whatsNew = WhatsNew(
            // The Version
            version: version,
            // The Title
            title: "近期更新",
            // The features you want to showcase
            items: [
                WhatsNew.Item(
                    title: "新增按区间导出日记",
                    subtitle: "",
                    image: nil
                ),
                WhatsNew.Item(
                    title: "新增纯文本导出选项",
                    subtitle: "",
                    image: nil
                ),
                WhatsNew.Item(
                    title: "新增农历",
                    subtitle: "设置->显示农历",
                    image: nil
                )
            ]
        )
        arr.append(whatsNew)
        
        return arr
    }
    
    
    static func getWhatsNewViewController()->WhatsNewViewController?{
        //MARK:-1:WhatsNew items
        let currentWhatsNew = whatsNewsFactory().get()
        
        //MARK:-2:custom configuration
        // Initialize default Configuration
        var configuration = WhatsNewViewController.Configuration()
        configuration.apply(animation: .slideDown)
        configuration.completionButton = WhatsNewViewController.CompletionButton(
            title:"知道了"
        )
//        configuration.detailButton = WhatsNewViewController.DetailButton(
//            title: "好评鼓励👏",
//            action:.custom(action: { _ in
//                if let url = URL(string: "itms-apps://itunes.apple.com/app/id1564045149?action=write-review"){
//                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                }
//            })
//        )
        configuration.detailButton = WhatsNewViewController.DetailButton(
            title: "✨了解aDiary Pro✨",
            action:.custom(action: { _ in
                let iapVC = IAPViewController()
                UIApplication.getTopViewController()?.present(iapVC, animated: true, completion: nil)
            })
        )
        // And many more configuration properties...
        
        //MARK:-3:versionStore
        let versionStore:WhatsNewVersionStore = KeyValueWhatsNewVersionStore()
//        let versionStore:WhatsNewVersionStore = InMemoryWhatsNewVersionStore()
        
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
        
        if versionStore.has(version: WhatsNew.Version(major: 3, minor: 3, patch: 0))
        {
            // 如果展示过3.3的欢迎页，则不需要再展示
            return nil
        }
        
        
        return viewController
    }
}
