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
                    title: "适配深色模式主题",
                    subtitle: "系统开启深色模式后将自动切换",
                    image: UIImage(named: "moon")
                )
            ]
        )
        arr.append(whatsNew210)
        
        //MARK:-2.2
        let version220 = WhatsNew.Version(major: 2, minor: 2, patch: 0)
        let whatsNew220 = WhatsNew(
            // The Version
            version: version220,
            // The Title
            title: "新特性",
            // The features you want to showcase
            items: [
                WhatsNew.Item(
                    title: "可使用第三方应用提供的字体",
                    subtitle: "例如在iFont安装的字体",
                    image: UIImage(named: "font")
                ),
                WhatsNew.Item(
                    title: "适配深色模式主题",
                    subtitle: "系统开启深色模式后将自动切换",
                    image: UIImage(named: "moon")
                )
            ]
        )
        arr.append(whatsNew220)
        
        //MARK:-2.3
        let version230 = WhatsNew.Version(major: 2, minor: 3, patch: 0)
        let whatsNew230 = WhatsNew(
            // The Version
            version: version230,
            // The Title
            title: "新特性",
            // The features you want to showcase
            items: [
                WhatsNew.Item(
                    title: "适配iPad",
                    subtitle: "欢迎前往下载体验",
                    image: UIImage(named: "ipad")
                ),
                WhatsNew.Item(
                    title: "可使用第三方应用提供的字体",
                    subtitle: "例如在iFont安装的字体",
                    image: UIImage(named: "font")
                ),
                WhatsNew.Item(
                    title: "适配深色模式主题",
                    subtitle: "系统开启深色模式后将自动切换",
                    image: UIImage(named: "moon")
                )
            ]
        )
        arr.append(whatsNew230)
        
        //MARK:-2.4
        let version240 = WhatsNew.Version(major: 2, minor: 4, patch: 0)
        let whatsNew240 = WhatsNew(
            // The Version
            version: version240,
            // The Title
            title: "新特性",
            // The features you want to showcase
            items: [
                WhatsNew.Item(
                    title: "添加显示模式开关",
                    subtitle: "自动，浅色，深色",
                    image: UIImage(named: "segment")
                ),
                WhatsNew.Item(
                    title: "添加iCloud功能开关",
                    subtitle: "开启，关闭",
                    image: UIImage(named: "iCloud")
                ),
                WhatsNew.Item(
                    title: "添加每日提醒开关",
                    subtitle: "以及设置提醒的时间",
                    image: UIImage(named: "remind")
                ),
                WhatsNew.Item(
                    title: "修复了一些Bug",
                    subtitle: "",
                    image: UIImage(named: "bug")
                )
                
            ]
        )
        arr.append(whatsNew240)
        
        
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
