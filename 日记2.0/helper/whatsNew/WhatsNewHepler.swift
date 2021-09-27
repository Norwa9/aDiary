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
        //MARK:-2.7.1
        let version271 = WhatsNew.Version(major: 2, minor: 7, patch: 1)
        let whatsNew271 = WhatsNew(
            // The Version
            version: version271,
            // The Title
            title: "2.7.1新特性",
            // The features you want to showcase
            items: [
                WhatsNew.Item(
                    title: "修复深色模式的适配bug",
                    subtitle: "",
                    image: UIImage(named: "bug")
                ),
            ]
        )
        arr.append(whatsNew271)
        //MARK:-2.8
        let version280 = WhatsNew.Version(major: 2, minor: 8, patch: 0)
        let whatsNew280 = WhatsNew(
            // The Version
            version: version280,
            // The Title
            title: "2.8.0",
            // The features you want to showcase
            items: [
                WhatsNew.Item(
                    title: "适配IOS 15",
                    subtitle: "",
                    image: UIImage(named: "update")
                ),
                WhatsNew.Item(
                    title: "添加自动创建日记开关",
                    subtitle: "",
                    image: UIImage(named: "switch")
                ),
            ]
        )
        arr.append(whatsNew280)
        
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
