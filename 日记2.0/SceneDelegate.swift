//
//  SceneDelegate.swift
//  日记2.0
//
//  Created by 罗威 on 2021/1/30.
//

import UIKit
import WidgetKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var isLocked:Bool = false
    
    //高斯模糊图层实例
    let visualEffectView:UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.alpha = 1
        return visualEffectView
    }()
    //提示框
    var ac:UIAlertController!
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        print("openURLContexts")
        if URLContexts.count > 0{
            guard let topVC = UIApplication.getTopViewController() as? monthVC else{
                return
            }
            let url = URLContexts.first!.url.absoluteString//yyyy-MM-d
            let dateCN = UrlToDateCN(pageDateUrl: url)//yyyy年MM月d日-x
            if let diary = LWRealmManager.shared.queryFor(dateCN: dateCN).first{
                topVC.presentEditorVC(withViewModel: diary)
            }
            
        }
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        print("已进入前台")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        print("将要进入后台")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        print("将要进入前台")
        /*
         解锁->iCloud账户可用性检查->扫描，上传离线时修改的数据->获取服务器的变化
         */
        self.authApp(then: {
            //TODO:检查账户的可用性，如果账户由不可用->可用，需要为其配置环境
            //DiaryStore.shared.uploadLocalDataNotUploadedYet()
            //DiaryStore.shared.fetchRemoteChange()
        })
        
        
    }
    

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        print("已经进入后台")
        // 1. 锁定App
        self.lockApp()
        
        // 2. 保存内容
        UIApplication.getTextVC()?.save()
        
        
        // 刷新小组件内容
        if #available(iOS 14.0, *) {
            todoDataProvider.shared.setData()
            RoamDataProvider.shared.setRoamData()
            WidgetCenter.shared.reloadTimelines(ofKind: WidgetKindKeys.todoWidget)
            WidgetCenter.shared.reloadTimelines(ofKind: WidgetKindKeys.RoamWidget)
        }
    }


}


