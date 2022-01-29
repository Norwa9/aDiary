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
    
    enum notificationCategories:String {
        case dailyRemind // 每日提醒
        case todo // 待办
    }
    typealias callBack = () -> Void
    
    //MARK: - 接口相关
    
    ///开启每日通知功能
    /// 先检查通知功能是否开启，如果第一次用App，则向用户索取通知权限
    public func checkNotificationAuthorization(
        requestRejectedAction:@escaping callBack, // 如果第一次索取时失败
        requestGrantedAction:@escaping callBack // 如果第一次索取时成功
    ){
        center.getNotificationSettings { setting in
            switch setting.authorizationStatus{
                case .notDetermined: // 第一次使用App，索取权限
                    self.requestAuthorization(
                        requestGrantedAction: requestGrantedAction,
                        requestRejectedAction: requestRejectedAction
                    )
                case .authorized: // 已获得通知权限，配置
                    self.registerCategories()
                    requestGrantedAction()
                case .denied: // 已被拒绝过，重新申请开启权限
                    // 步骤1.失败后的UI更新
                    // 步骤2. 没有通知权限，需要引导用户重新开启aDiary通知权限
                    requestRejectedAction()
                    DispatchQueue.main.async{
                        self.presentGuideAction()
                    }
                    
                default:
                    break
            }
        }
        
    }
    
    ///向用户索取通知权限
    private func requestAuthorization(
        requestGrantedAction:@escaping callBack,
        requestRejectedAction:@escaping callBack
    ){
        center.requestAuthorization(options: [.alert,.badge,.sound]) { granted, error in
            if granted{
                self.registerCategories()
                requestGrantedAction()
            }else if let error = error{
                print("索要通知权限错误，错误信息：\(error.localizedDescription)")
            }else{ // 索取被拒绝
                requestRejectedAction()
            }
        }
    }
    
    /// 用户已关闭通知权限，引导用户去设置中重新打开
    private func presentGuideAction(){
        // 弹出警告框
        let alertController = UIAlertController(title: "消息推送权限已被关闭",
                                    message: "想要App发送提醒。点击“设置”，开启通知。",
                                    preferredStyle: .alert)
         
        let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler:nil)
         
        let settingsAction = UIAlertAction(title:"设置", style: .default, handler: {
            (action) -> Void in
            let url = URL(string: UIApplication.openSettingsURLString)
            if let url = url, UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:],
                                              completionHandler: {
                                                (success) in
                    })
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        })
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        let topVC = UIApplication.getTopViewController()
        topVC?.present(alertController, animated: true, completion: nil)
    }
    
    /// 定义可接收的通知的类型
    private func registerCategories(){
        center.delegate = self
        
        //按钮1：写日记
        let writeAction = UNNotificationAction(identifier: "writeAction", title: "开始写日记", options: .foreground)
        let dailyRemindCategory = UNNotificationCategory(
            identifier: notificationCategories.dailyRemind.rawValue,
            actions: [writeAction],
            intentIdentifiers: [], options: []
        )
        
        //按钮2：todo
        let lookUpAction = UNNotificationAction(identifier: "lookUpAction", title: "查看", options: .foreground)
        let doneAction = UNNotificationAction(identifier: "doneAction", title: "完成", options: .foreground)
        let todoCategory = UNNotificationCategory(
            identifier: notificationCategories.todo.rawValue,
            actions: [lookUpAction,doneAction],
            intentIdentifiers: [], options: []
        )
        
        center.setNotificationCategories([dailyRemindCategory,todoCategory])
    }
    
   
    /// API:注册通知
    public func registerNotification(from infoDict:NSDictionary){
        // 0 每日日记
        // 1 待办提醒
        
        self.addNotificationRequest(from: infoDict)
    }
    
    /// API:注销通知
    public func unregisterNotification(uuids:[String]){
        // 0 每日日记
        // 1 待办提醒
        center.removeDeliveredNotifications(withIdentifiers: uuids)
        center.removePendingNotificationRequests(withIdentifiers: uuids)
        // UIApplication.shared.applicationIconBadgeNumber = 0
        print("注销通知成功,uuid:\(uuids)")
    }
    
    private func addNotificationRequest(from dict:NSDictionary){
        let content = UNMutableNotificationContent()
        guard let title = dict["title"] as? String,
              let body = dict["body"] as? String,
              let userInfo = dict["userInfo"] as? [AnyHashable : Any],
              let sound = dict["sound"] as? String,
              let categoryIdentifier = dict["categoryIdentifier"] as? String,
              let dateComponents = dict["dateComponents"] as? DateComponents,
              let repeats = dict["repeats"] as? Bool,
              let uuid = dict["uuid"] as? String
        else{return}
        
        content.title = title
        content.body = body
        content.categoryIdentifier = categoryIdentifier
        content.userInfo = userInfo
        content.sound = .default
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 61, repeats: true)//测试，请退出APP到后台测试，在App内部不会显示通知！！
        
        // 添加该通知请求之前，先把旧有的该通知删除
        center.removeDeliveredNotifications(withIdentifiers: [uuid])
        center.removePendingNotificationRequests(withIdentifiers: [uuid])
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
        let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)
        
        // 挂起一个通知request，当系统时间到达request的trigger时，系统将会deliver这个request
        center.add(request, withCompletionHandler: nil) // Schedules a local notification for delivery.
        print("添加通知成功，内容：\(title),时间：\(dateComponents)，uuid：\(uuid)")
    }
    
    // MARK: 每日通知
    static func generateDailyRemindInfoDict()->NSDictionary{
        let dict = NSMutableDictionary()
        dict["title"] = "每日记录提醒"
        dict["body"] = "记录一下今天发生了什么吧~"
        var userInfo:[AnyHashable : Any] = [:]
        dict["userInfo"] = userInfo
        dict["sound"] = "default"
        dict["categoryIdentifier"] = notificationCategories.dailyRemind.rawValue
        
        var dateComponents = DateComponents()
        dateComponents.hour = userDefaultManager.dailyRemindAtHour
        dateComponents.minute = userDefaultManager.dailyRemindAtMinute
        dict["dateComponents"] = dateComponents
        
        dict["repeats"] = true
        dict["uuid"] = userDefaultManager.TodoNotificationCategoryName
        
        return dict
    }
    
    static func generateTodoInfoDict(model:LWTodoModel)->NSDictionary{
        let dict = NSMutableDictionary()
        dict["title"] = "提醒：" + model.content
        dict["body"] = model.note
        var userInfo:[AnyHashable : Any] = [:]
        dict["userInfo"] = userInfo
        dict["sound"] = "default"
        dict["categoryIdentifier"] = notificationCategories.todo.rawValue
        
        let remindDate = model.remindDate
        var dateComponents = DateComponents()
        dateComponents.hour = getDateComponent(for: remindDate, for: .hour)
        dateComponents.minute = getDateComponent(for: remindDate, for: .mintue)
        dict["dateComponents"] = dateComponents
        
        dict["repeats"] = false
        dict["uuid"] = model.uuid
        
        return dict
    }
    
    
    
    

    ///配置通知的内容
    private func configureNotifications(){
        let content = UNMutableNotificationContent()
        //1.title
        let title = "每日记录提醒"
        content.title = title
        
        //2.body
        content.body = "记录一下今天发生了什么吧~"
        content.targetContentIdentifier
        //3.
        content.categoryIdentifier = notificationCategories.dailyRemind.rawValue
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
        
        
        // 挂起一个通知request，当系统时间到达request的trigger时，系统将会deliver这个request
        center.add(request, withCompletionHandler: nil) // Schedules a local notification for delivery.
        
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
            case notificationCategories.dailyRemind.rawValue:
                print("notifActions.writtingRemind")
            default:
                break
            }
        }
        
        
        completionHandler()//必须在最后调用这个闭包
    }
    
    
}

// MARK: 待办通知相关
extension LWNotificationHelper{
    
}
