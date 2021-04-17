//
//  SceneDelegate.swift
//  日记2.0
//
//  Created by 罗威 on 2021/1/30.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    //高斯模糊图层
    let visualEffectView:UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = UIScreen.main.bounds
        visualEffectView.alpha = 1
        return visualEffectView
    }()
    var ac:UIAlertController!

    var appFirstLaunch = true//是否为app第一次启动
    
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
        //app第一次启动时，要先把内容模糊，再认证
        guard appFirstLaunch && (userDefaultManager.useBiometrics || userDefaultManager.usePassword) else {
            return
        }
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.addSubview(self.visualEffectView)
        appFirstLaunch = false
        print("sceneDidBecomeActive")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        print("sceneWillResignActive")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        print("sceneWillEnterForeground authApp")
        //保证是先锁定屏幕内容，后弹出验证
        //否者验证提示框位于高斯模糊层之下
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.authApp()
        }
        
    }
    

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        print("sceneDidEnterBackground")
        self.lockApp()
        
    }


}


