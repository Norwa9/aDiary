//
//  LWNotificationHelper.swift
//  日记2.0
//
//  Created by yy on 2021/8/11.
//

import Foundation
import UIKit
import UserNotifications

class LWNotificationHelper:NSObject{
    static let shared = LWNotificationHelper()
    
    let center = UNUserNotificationCenter.current()
    
    enum notifActions:String {
        case writtingRemind
    }
    typealias callBack = () -> Void
    
    //MARK:-public
    
    ///开启每日通知功能
    ///先检查一下通知权限,
    ///参数1：如果用户关闭了通知权限，想要开启每日提醒功能，先要执行引导guideAction
    ///参数2：如果用户第一次使用这个开关，则请求通知权限，如果用户不给，则执行requestFailureCompletion
    public func enableDailyRemind(guideAction:@escaping callBack,requestFailureCompletion:@escaping callBack){
        center.getNotificationSettings { setting in
            switch setting.authorizationStatus{
                case .notDetermined:
                    self.requestAuthorization(requestFailureCompletion)//索取通知权限
                case .authorized:
                    self.register()//已有通知权限，配置通知功能
                case .denied:
                    guideAction()//没有通知权限，引导用户开启通知权限
                default:
                    break
            }
        }
        
    }
    
    ///关闭每日通知功能
    public func disableDailyRemind(){
        unregister()
    }
    
    
    //MARK:-private
    ///向用户索取通知权限
    private func requestAuthorization(_ requestFailureCompletion:@escaping callBack){
        center.requestAuthorization(options: [.alert,.badge,.sound]) { granted, error in
            if granted{
                print("已取得本地通知权限")
                self.register()
            }else if let error = error{
                print("索要通知权限错误，错误信息：\(error.localizedDescription)")
            }else{
                print("没有取得本地通知权限，无法开启每日提醒")
                requestFailureCompletion()
            }
        }
    }
    
    public func register(){
        userDefaultManager.dailyRemindEnable = true
        self.registerCategories()//注册对通知的后续行为
        self.configureNotifications()//配置通知的内容
    }
    
    private func unregister(){
        print("注销通知")
        userDefaultManager.dailyRemindEnable = false
        center.removeAllDeliveredNotifications()    // to remove all delivered notifications
        center.removeAllPendingNotificationRequests()   // to remove all pending notifications
        UIApplication.shared.applicationIconBadgeNumber = 0 // to clear the icon notification badge
    }
    
    ///配置通知的内容
    private func configureNotifications(){
        let content = UNMutableNotificationContent()
        //1.title
        let title = "每日记录提醒"
        content.title = title
        
        //2.body
//        content.body = ""
        
        //3.
        content.categoryIdentifier = notifActions.writtingRemind.rawValue
        content.userInfo = ["customData" : "testing"]
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = userDefaultManager.dailyRemindAtHour
        dateComponents.minute = userDefaultManager.dailyRemindAtMinute
        print("设置每日提醒：时间为\(dateComponents.hour!):\(dateComponents.minute!)")
        center.removeAllPendingNotificationRequests()
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 61, repeats: true)//测试，请退出APP到后台测试，在App内部不会显示通知！！
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        
        center.add(request, withCompletionHandler: nil)
        
    }
    
    ///配置通知的操作行为
    private func registerCategories(){
        center.delegate = self
        
        //按钮1：写日记
        let writeDiaryAction = UNNotificationAction(identifier: notifActions.writtingRemind.rawValue, title: "写日记", options: .foreground)
        
        let writtingRemindCategory = UNNotificationCategory(identifier: notifActions.writtingRemind.rawValue, actions: [writeDiaryAction], intentIdentifiers: [], options: [])
        
        center.setNotificationCategories([writtingRemindCategory])
    }
}

extension LWNotificationHelper:UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String{
            print("接收到customData:\(customData)")
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                //右滑解锁通知
                print("Default identifier")
            case notifActions.writtingRemind.rawValue:
                print("notifActions.writtingRemind")
            default:
                break
            }
        }
        
        
        completionHandler()//必须在最后调用这个闭包
    }
}
