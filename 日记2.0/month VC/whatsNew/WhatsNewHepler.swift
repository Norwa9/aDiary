//
//  WhatsNewHepler.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/8.
//

import Foundation
import WhatsNewKit

class WhatsNewHelper{
    ///每次更新前，只要创建对应版本号的whatsNew结构体，就可以对不同版本的用户显示不同的更新提示！
    static func whatsNewsFactory()->[WhatsNew]{
        var arr:[WhatsNew] = []
        //MARK:-2.1.0
        let version210 = WhatsNew.Version(major: 2, minor: 1, patch: 0)
        let whatsNew210 = WhatsNew(
            // The Version
            version: version210,
            // The Title
            title: "新特性",
            // The features you want to showcase
            items: [
                WhatsNew.Item(
                    title: "适配深色模式",
                    subtitle: "aDiary可以跟随系统的外观模式了",
                    image: UIImage(named: "darkmode")
                )
            ]
        )
        arr.append(whatsNew210)
        
        //MARK:-2.1.1
        let version211 = WhatsNew.Version(major: 2, minor: 1, patch: 1)
        let whatsNew211 = WhatsNew(
            // The Version
            version: version211,
            // The Title
            title: "新特性",
            // The features you want to showcase
            items: [
                WhatsNew.Item(
                    title: "项目除虫",
                    subtitle: "修复了一些明显的bug",
                    image: UIImage(named: "bug")
                ),
                WhatsNew.Item(
                    title: "适配深色模式",
                    subtitle: "aDiary可以跟随系统的外观模式了",
                    image: UIImage(named: "darkmode")
                )
            ]
        )
        arr.append(whatsNew211)
        
        
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
        configuration.detailButton = WhatsNewViewController.DetailButton(
            title: "好评鼓励👏",
            action:.custom(action: { _ in
                if let url = URL(string: "itms-apps://itunes.apple.com/app/id1564045149?action=write-review"){
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
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
        
        return viewController
    }
}
