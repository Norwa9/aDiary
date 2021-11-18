//
//  AppDelegate.swift
//  日记2.0
//
//  Created by 罗威 on 2021/1/30.
//

import UIKit
import RealmSwift
import StoreKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        //1.数据库
        configDatabase()

        //2.注册iCloud静默通知
        UIApplication.shared.registerForRemoteNotifications()
        
        //3.IAP
        /**
         IAP应用内购买交易事务队列
         Unfinished transactions stay in the payment queue. StoreKit calls the app’s persistent observer’s paymentQueue(_:updatedTransactions:) every time upon launching or resuming from the background until the app finishes these transactions.
         */
        SKPaymentQueue.default().add(LWIAPHelper.shared)
        
        //4.Widget
        LWWidgetProvider.shared.setRoamData()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let url = url.absoluteString
        print("url:\(url)")
        
        let topVC = UIApplication.getTopViewController()
        if topVC as? todayVC != nil{
            return false
        }
        
        let monthVC = UIApplication.getMonthVC()
        let res = LWRealmManager.shared.queryFor(dateCN: url)
        if !res.isEmpty{
            monthVC.presentEditorVC(withViewModel: res.first!)
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        DiaryStore.shared.processSubscriptionNotification(with: userInfo)
        completionHandler(.newData)//must
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

    func applicationWillTerminate(_ application: UIApplication) {
        //在App结束时移除交易监听
        SKPaymentQueue.default().remove(LWIAPHelper.shared)
    }
}

//MARK:-配置数据库
extension AppDelegate{
    private func configDatabase(){
        //配置realm
        self.configureRealm()
        
        //1.初始化realm:读取本地数据库，填充数据源
        _ = LWRealmManager.shared
        
        //2.初始化DiaryStore,云同步开始工作
        let store = DiaryStore.shared
        store.startEngine()
    }
    
    ///配置数据库，用于数据库的迭代更新
    private func configureRealm(){
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
