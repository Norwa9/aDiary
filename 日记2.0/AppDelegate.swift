//
//  AppDelegate.swift
//  日记2.0
//
//  Created by 罗威 on 2021/1/30.
//

import UIKit
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //读取引导文案到今日
//        LoadIntroText()
        
        //注册静默通知，以监听iCloud数据库的变化
//        UIApplication.shared.registerForRemoteNotifications()
        
        //配置realm
        self.configureRealm()
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("接收到远程通知！")
//        DiaryStore.shared.processSubscriptionNotification(with: userInfo)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

//MARK:-配置realm数据库
extension AppDelegate{
    ///配置数据库，用于数据库的迭代更新
    func configureRealm(){
        let schemaVersion: UInt64 = 0
        LWRealmManager.schemaVersion = schemaVersion
        let config = Realm.Configuration(schemaVersion: schemaVersion, migrationBlock: { migration, oldSchemaVersion in
            //oldSchemaVersion从0开始
            if (oldSchemaVersion < schemaVersion) {
                //在这里更新数据库的schema
                //如果只是增加、删除model的属性，则realm会自动完成schema的更新。
            }
        })
        Realm.Configuration.defaultConfiguration = config
        Realm.asyncOpen { result in
            do{
                _ = try result.get()
                /* Realm 成功打开，迁移已在后台线程中完成 */
                print("Realm 数据库配置成功")
            }catch let error{
                /* 处理打开 Realm 时所发生的错误 */
                print("Realm 数据库配置失败：\(error.localizedDescription)")
            }
        }
    }
}
