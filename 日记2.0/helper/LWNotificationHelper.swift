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
    
    /// 通知类别
    enum LWNotificationCategories:String {
        case dailyRemind // 每日提醒
        case todo // 待办
    }
    
    /// 通知的更多操作
    enum LWNotificationActionIdentifier:String{
        case writeTodayDiary
        case loopUp
        case done
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
    func registerCategories(){
        center.delegate = self
        print("registerCategories sucessfully!")
        //按钮1：写日记
        let writeAction = UNNotificationAction(identifier: LWNotificationActionIdentifier.writeTodayDiary.rawValue, title: "开始写日记", options: .foreground)
        let dailyRemindCategory = UNNotificationCategory(
            identifier: LWNotificationCategories.dailyRemind.rawValue,
            actions: [],
            intentIdentifiers: [], options: []
        )
        
        //按钮2：todo
        let lookUpAction = UNNotificationAction(identifier: LWNotificationActionIdentifier.loopUp.rawValue, title: "查看", options: .foreground)
        let doneAction = UNNotificationAction(identifier: LWNotificationActionIdentifier.done.rawValue, title: "完成", options: .foreground)
        let todoCategory = UNNotificationCategory(
            identifier: LWNotificationCategories.todo.rawValue,
            actions: [],
            intentIdentifiers: [], options: []
        )
        
        center.setNotificationCategories([dailyRemindCategory,todoCategory])
    }
    
   
    // MARK: API:注册通知
    public func registerNotification(from infoDict:NSDictionary){
        // 0 每日日记
        // 1 待办提醒
        
        self.addNotificationRequest(from: infoDict)
    }
    
    // MARK: API:注销通知
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
        
        print("注册(\(body)前，待发送的通知有：")
        center.getPendingNotificationRequests { request in
            print("PendingRequest:\(request)")
        }
        
        // 添加该通知请求之前，先把旧有的该通知删除
        center.removeDeliveredNotifications(withIdentifiers: [uuid])
        center.removePendingNotificationRequests(withIdentifiers: [uuid])
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
        let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)
        
        // 挂起一个通知request，当系统时间到达request的trigger时，系统将会deliver这个request
        center.add(request, withCompletionHandler: nil) // Schedules a local notification for delivery.
        print("注册通知成功，内容：\(title),时间：\(dateComponents)，uuid：\(uuid)")
    }
    
    // MARK: 每日通知
    static func generateDailyRemindInfoDict()->NSDictionary{
        let dict = NSMutableDictionary()
        dict["title"] = "每日记录提醒"
        dict["body"] = "记录一下今天发生了什么吧~"
        var userInfo:[AnyHashable : Any] = [:]
        dict["userInfo"] = userInfo
        dict["sound"] = "default"
        dict["categoryIdentifier"] = LWNotificationCategories.dailyRemind.rawValue
        
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
        userInfo["dateBelongs"] = model.dateBelongs
        dict["userInfo"] = userInfo
        dict["sound"] = "default"
        dict["categoryIdentifier"] = LWNotificationCategories.todo.rawValue
        
        let remindDate = model.remindDate
        var dateComponents = DateComponents()
        dateComponents.year = getDateComponent(for: remindDate, for: .year)
        dateComponents.month = getDateComponent(for: remindDate, for: .month)
        dateComponents.hour = getDateComponent(for: remindDate, for: .hour)
        dateComponents.minute = getDateComponent(for: remindDate, for: .mintue)
        dict["dateComponents"] = dateComponents
        
        dict["repeats"] = false
        dict["uuid"] = model.uuid
        
        return dict
    }
    
}

extension LWNotificationHelper:UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("didReceive userNotification！")
        let categoryIdentifier = response.notification.request.content.categoryIdentifier
        let userInfo = response.notification.request.content.userInfo
        // 按通知分类来处理（提醒记日记或者打开todo对应的日记）
        if let category = LWNotificationCategories(rawValue: categoryIdentifier) {
            switch category {
            case .dailyRemind:
                print("响应提醒日记通知，打开App")
                break
            case .todo:
                if let dateBelongs = userInfo["dateBelongs"] as? String,
                   let diary = LWRealmManager.shared.queryFor(dateCN: dateBelongs).first
                {
                    print("todo所属的日期:\(dateBelongs)")
                    switch response.actionIdentifier {
                    case UNNotificationDefaultActionIdentifier:
                        // 默认
                        print("响应todo通知（点击或右划）的默认处理操作：打开todo所属日记")
                        UIApplication.getMonthVC()?.presentEditorVC(withViewModel: diary)
                    case LWNotificationActionIdentifier.loopUp.rawValue:
                        print("响应todo通知的查看操作：打开todo所属日记")
                        UIApplication.getMonthVC()?.presentEditorVC(withViewModel: diary)
                        break
                    case LWNotificationActionIdentifier.done.rawValue:
                        print("响应todo通知的完成操作：打开todo所属日记")
                        break
                    default:
                        break
                    }
                }
            }
            
        }
        completionHandler()//必须在最后调用这个闭包
    }
    
    
}

// MARK: 待办通知相关
extension LWNotificationHelper{
    /// 接受云端更新后，更新本地通知池
    /// 1. 有些todo取消了通知、2.有些todo添加了通知（或添加了带有通知的新的todo）、3.有些todo被删除
    public func updateLocalNotificationsAfterSync(oldDiaryID:String,newDiary:diaryInfo){
        if let oldDiary = LWRealmManager.shared.queryFor(dateCN: oldDiaryID).first{
            let oldTodoModels = oldDiary.lwTodoModels
            let newTodoModels = newDiary.lwTodoModels
            self.updateLocalNotifications(oldTodoModels: oldTodoModels, newTodoModels: newTodoModels)
        }
    }
    private func updateLocalNotifications(oldTodoModels:[LWTodoModel],newTodoModels:[LWTodoModel]){
        // 1.先删除日记所有todo的通知
        let oldUUIDs = oldTodoModels.map { model in
            return model.uuid
        }
        LWNotificationHelper.shared.unregisterNotification(uuids: oldUUIDs)
        
        // 2.再添加新日记所有需要通知的todo
        for newTodoModel in newTodoModels {
            if newTodoModel.needRemind{
                let dict = LWNotificationHelper.generateTodoInfoDict(model: newTodoModel)
                LWNotificationHelper.shared.registerNotification(from: dict)
            }
        }
        
        
    }
}
