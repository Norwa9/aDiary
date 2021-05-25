//
//  privacyManager.swift
//  日记2.0
//
//  Created by 罗威 on 2021/4/15.
//

import Foundation
import UIKit
import LocalAuthentication
//MARK:-进入后台添加高斯模糊，恢复前台解锁后移除高斯模糊
extension SceneDelegate{
    func lockApp(){
        //如果用户正在正在输入提示框时进入后台。此时再进入app，再次进入验证弹出第二个提示框。
        //所以当用户正在输入密码却进入后台时，将dismiss之前展示的提示框。
        guard userDefaultManager.useBiometrics || userDefaultManager.usePassword  else{
            return
        }
        if ac != nil{
            ac.dismiss(animated: true, completion: nil)
        }
        self.visualEffectView.alpha = 1
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.addSubview(self.visualEffectView)
    }
    
    func authApp(){
        //是否启用加密
        guard userDefaultManager.useBiometrics || userDefaultManager.usePassword  else{
            return
        }
        
        //开始认真之前先加上模糊
        self.visualEffectView.alpha = 1
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.addSubview(self.visualEffectView)
        
        //如果设置了生物识别
        if userDefaultManager.useBiometrics{
            let context = LAContext()
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
                let reason = "需要认证你的身份"
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason){
                    [weak self] success, authenticationError in
                    
                    DispatchQueue.main.async {
                        if success {
                            //成功
                            self?.unlock()
                        }else{
                            //失败
                            if let error = authenticationError{
                                //认证失败的原因有很多
                                //如果解锁过程中app进入后台，authenticationError的错误描述即为UI canceled by system.
                                //此时如果再次打开app，会同时发生两次认证，一次是生物认证，一次是密码验证
                                //为了解决这个问题，当判断authenticationError结果为cancled by system时，直接return，表示不对该错误进行处理。
                                if error.localizedDescription == "UI canceled by system."{
                                    return
                                }
                            }
                            //其他情况的验证失败，例如用户点了取消，例如人脸不匹配等，
                            //此时跳出提示框，请求输入密码。
                            self?.passwordPrompt()
                        }
                        
                    }
                }
            }else{
                //不能使用生物识别
                self.failAlert(title: "设备不支持生物识别", message: "使用App密码登录", okActionTitle: "输入App密码")
            }
        //如果仅设置密码
        }else if userDefaultManager.usePassword{
            //提示用户输入密码
            self.passwordPrompt()
        }
        
    }
    
    //解锁
    func unlock(){
        UIView.animate(withDuration: 0.5) {
            self.visualEffectView.alpha = 0
        } completion: { (finished) in
            if finished{
                self.visualEffectView.removeFromSuperview()
            }
        }
    }
    
    //提示输入密码
    func passwordPrompt(message:String = "请输入App密码"){
        ac = UIAlertController(title: "使用密码解锁App", message: message, preferredStyle: .alert)
        ac.view.setupShadow()
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "提交", style: .default){[weak self] _ in
            guard let inputPassword = self?.ac.textFields?[0].text else {return}

            if inputPassword == userDefaultManager.password{
                //密码配对成功
                self?.unlock()
            }else{
                self?.ac.view.shake()
                self?.passwordPrompt(message: "密码输入不正确")
            }
        })
        //获取最顶层的ViewController，由它来负责展示ac
        if let topVC = UIApplication.getTopViewController(){
            topVC.present(ac, animated: true)
        }
    }
    
    //不支持生物识别时，调用这个提醒用户。
    func failAlert(title: String, message: String, okActionTitle: String){
        ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okActionTitle, style: .default){[weak self] _ in
            //提示输入密码
            self?.passwordPrompt()
        }
        ac.addAction(okAction)
        //获取最顶层的ViewController，由它来负责展示ac
        if let topVC = UIApplication.getTopViewController(){
            topVC.present(ac, animated: true)
        }
    }
}
