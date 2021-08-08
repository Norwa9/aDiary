//
//  WhatsNewHepler.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/8.
//

import Foundation
import WhatsNewKit

class WhatsNewHelper{
    static func getWhatsNewViewController()->WhatsNewViewController?{
        //MARK:-1:WhatsNew items
        let version = WhatsNew.Version.current()
        let whatsNew = WhatsNew(
            // The Version
            version: version,
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
        
        //MARK:-2:custom configuration
        // Initialize default Configuration
        var configuration = WhatsNewViewController.Configuration()
        configuration.apply(animation: .slideDown)
        configuration.completionButton = WhatsNewViewController.CompletionButton(
            title:"知道了"
        )
        // And many more configuration properties...
        
        //MARK:-3:versionStore
        let versionStore:WhatsNewVersionStore = KeyValueWhatsNewVersionStore()
        //let versionStore:WhatsNewVersionStore = InMemoryWhatsNewVersionStore()
        
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
