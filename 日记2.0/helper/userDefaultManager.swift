//
//  userDefaultManager.swift
//  日记2.0
//
//  Created by 罗威 on 2021/3/27.
//

import Foundation
import UIKit

class userDefaultManager{
    public static var shared:UserDefaults? = UserDefaults(suiteName: "user.default")
    
    ///默认字体大小
    static let DefaultFontSize:CGFloat = 16.0
    static let defaultEditorLineSpacing:CGFloat = 5
    
    private struct constants {
        static let hasInitialized = "hasInitialized"
        static let imageSizeStyle = "imageSizeStyle"
        static let fontNameKey = "fontName"
        static let fontSizeKey = "fontSize"
        static let useBiometricsKey = "biometrics"
        static let usePasswordKey = "usePassword"
        static let appPasswordKey = "password"
        static let lineSpacingKey = "lineSpacing"
        static let textInset = "textInset"
        static let layoutType = "layoutType"
        static let requestReviewTimes = "requestReviewTimes"
        static let dailyRemindEnable = "dailyRemindEnable"
        static let dailyRemindTime = "dailyRemindTime"
        static let dailyRemindAtHour = "dailyRemindAtHour"
        static let dailyRemindAtMinute = "dailyRemindAtMinute"
        static let iCloudEnable = "iCloudEnable"
        static let appearanceMode = "appearanceMode"
        static let deleteBufferIDs = "deleteBufferIDs"
        static let autoCreate = "autoCreate"
        static let imageUploadQueue = "imageUploadQueue"
        static let imageDeleteQueue = "imageDeleteQueue"
        static let hasUpdated32 = "updated32"
        
        
        
        
    }
    
    //MARK: -字体
    static var fontName:String?{
        get{
            if let returnFontName = shared?.object(forKey: constants.fontNameKey) as? String{
                //检查字体是否真实存在
                if let _ = UIFont(name: returnFontName, size: self.fontSize){
                    return returnFontName
                }else{
                    return nil
                }
            }else{
                return nil
            }
        }
        set{
            shared?.setValue(newValue, forKey: constants.fontNameKey)
        }
    }
    
    static var font:UIFont{
        get{
            if let font = self.fontName{
                return UIFont(name: font, size: self.fontSize)!
            }else{
                //自定义字体被移除，重置fontName
                self.fontName = nil
                return UIFont.systemFont(ofSize: self.fontSize, weight: .regular)
            }
        }
    }
    
    
    static func customFont(withSize size:CGFloat) -> UIFont{
        if let font = self.fontName{
            return UIFont(name: font, size: size)!
        }else{
            //自定义字体被移除，重置fontName
            self.fontName = nil
            return UIFont.systemFont(ofSize: size, weight: .regular)
        }
    }
    
    static var fontSize:CGFloat{
        get{
            if let returnFontSize = shared?.object(forKey: constants.fontSizeKey) as? CGFloat{
                return returnFontSize
            }else{
                return self.DefaultFontSize
            }
        }
        set{
            shared?.setValue(newValue, forKey: constants.fontSizeKey)
        }
    }
    
    static var monthCellDateLabelFont:UIFont{
//        get{
//            if let name = self.fontName{
//                return UIFont(name: name, size: 20)!
//            }else{
//                return UIFont(name: "DIN Alternate", size: 20)!
//            }
//        }
        get{
            return UIFont(name: "DIN Alternate", size: 20)!
        }
    }
    
    static var monthCellTitleFont:UIFont{
//        get{
//            if let name = self.fontName{
//                return UIFont(name: name, size: 17)!
//            }else{
//                return UIFont(name: "DIN Alternate", size: 17)!
//            }
//        }
        get{
            return UIFont(name: "DIN Alternate", size: 17)!
        }
    }
    
    static var monthCellContentFont:UIFont{
//        get{
//            if let name = self.fontName{
//                return UIFont(name: name, size: 14)!
//            }else{
//                return UIFont(name: "DIN Alternate", size: 14)!
//            }
//        }
        get{
            return UIFont(name: "DIN Alternate", size: 14)!
        }
    }
    
    static var todoListFont:UIFont{
//        get{
//            if let name = self.fontName{
//                return UIFont(name: name, size: 15)!
//            }else{
//                return UIFont(name: "DIN Alternate", size: 15)!
//            }
//        }
        get{
            return UIFont(name: "DIN Alternate", size: 15)!
        }
    }
    
    ///字体行间距
    static var lineSpacing: CGFloat {
        get {
            if let result = shared?.object(forKey: constants.lineSpacingKey) as? CGFloat {
                return result
            }
            
            return defaultEditorLineSpacing
        }
        set {
            shared?.set(newValue, forKey: constants.lineSpacingKey)
        }
    }
    
    // 页内边距
    static var textInset: CGFloat {
        get {
            if let result = shared?.object(forKey: constants.textInset) as? CGFloat {
                return result
            }
            
            return 2.0 // 默认页内边距
        }
        set {
            shared?.set(newValue, forKey: constants.textInset)
        }
    }
    
    //MARK: -密码
    static var useBiometrics:Bool{
        get{
            if let returnBiometrics = shared?.object(forKey: constants.useBiometricsKey) as? Bool{
                return returnBiometrics
            }else{
                return false
            }
        }
        set{
            shared?.setValue(newValue, forKey: constants.useBiometricsKey)
        }
    }
    
    static var usePassword:Bool{
        get{
            if let returnUsePassword = shared?.object(forKey: constants.usePasswordKey) as? Bool{
                return returnUsePassword
            }else{
                return false
            }
        }
        set{
            shared?.setValue(newValue, forKey: constants.usePasswordKey)
        }
    }
    
    static var password:String{
        get{
            if let returnPassword = shared?.object(forKey: constants.appPasswordKey) as? String{
                return returnPassword
            }else{
                return "123456"
            }
        }
        set{
            shared?.setValue(newValue, forKey: constants.appPasswordKey)
        }
    }
    
    
    
    //MARK: -图片
    static var imageSizeStyle:Int{
        get {
            if let style = shared?.object(forKey: constants.imageSizeStyle) as? Int {
                return style
            }
            //0:大，1:中，2:小
            return 0
        }
        set {
            shared?.set(newValue, forKey: constants.imageSizeStyle)
        }
    }
    
    static var imageScalingFactor:CGFloat{
        get{
            return CGFloat(imageSizeStyle + 1)
        }
    }
    
    //MARK: -初始化
    static var hasInitialized:Bool{
        get{
            if let initlized = shared?.object(forKey: constants.hasInitialized) as? Bool {
                return initlized
            }else{
                return false
            }
        }
        set{
            shared?.set(newValue, forKey: constants.hasInitialized)
        }
    }
    
    //MARK: -首页布局
    /*
     list = 1 // 列表
     waterFall = 2 //瀑布流
     */
    static var layoutType:Int{
        get{
            if let type = shared?.object(forKey: constants.layoutType) as? Int {
                return type
            }else{
                return 2//默认展示1列，即列表视图
            }
        }
        set{
            shared?.set(newValue, forKey: constants.layoutType)
        }
    }
    
    //MARK: -store kit
    ///打分的请求次数
    static var requestReviewTimes:Int{
        get{
            if let times = shared?.object(forKey: constants.requestReviewTimes) as? Int {
                return times
            }else{
                return 0
            }
        }
        set{
            shared?.set(newValue, forKey: constants.requestReviewTimes)
        }
    }
    
    //MARK: -每日提醒
    static var dailyRemindEnable:Bool{
        get{
            if let enable = shared?.object(forKey: constants.dailyRemindEnable) as? Bool {
                return enable
            }else{
                return false
            }
        }
        set{
            shared?.set(newValue, forKey: constants.dailyRemindEnable)
        }
    }
    
    ///每日提醒时间（私有）
    static var dailyRemindTimeString:String{
        get{
            if let time = shared?.object(forKey: constants.dailyRemindTime) as? String {
                return time
            }else{
                return "22:00"//默认在晚上10点
            }
        }
        set{
            shared?.set(newValue, forKey: constants.dailyRemindTime)
        }
    }
    ///每日提醒时间
    static var dailyRemindTimeDate:Date{
        get{
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let date = formatter.date(from: dailyRemindTimeString)!
            return date
        }
        set{
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let string = formatter.string(from: newValue)
            dailyRemindTimeString = string
        }
    }
    
    ///每日提醒时间：时
    static var dailyRemindAtHour:Int{
        get{
            let formatter = DateFormatter()
            formatter.dateFormat = "HH"
            let hour = formatter.string(from: dailyRemindTimeDate)
            return Int(hour)!
        }
    }
    
    ///每日提醒时间：分
    static var dailyRemindAtMinute:Int{
        get{
            let formatter = DateFormatter()
            formatter.dateFormat = "mm"
            let minute = formatter.string(from: dailyRemindTimeDate)
            return Int(minute)!
        }
    }
    
    //MARK: -iCloud
    static var iCloudEnable:Bool{
        get{
            if let enable = shared?.object(forKey: constants.iCloudEnable) as? Bool {
                return enable
            }else{
                return true
            }
        }
        set{
            shared?.set(newValue, forKey: constants.iCloudEnable)
        }
    }
    
    static var deleteBufferIDs:[String]{
        get{
            if let ids = shared?.object(forKey: constants.deleteBufferIDs) as? [String] {
                return ids
            }else{
                return []
            }
        }
        set{
            shared?.set(newValue, forKey: constants.deleteBufferIDs)
        }
    }
    
    /// 图片待上传队列
    static var imageUploadQueue:[String]{
        get{
            if let uuids = shared?.object(forKey: constants.imageUploadQueue) as? [String] {
                return uuids
            }else{
                return []
            }
        }
        set{
            shared?.set(newValue, forKey: constants.imageUploadQueue)
        }
    }
    
    /// 图片待删除队列
    static var imageDeleteQueue:[String]{
        get{
            if let uuids = shared?.object(forKey: constants.imageDeleteQueue) as? [String] {
                return uuids
            }else{
                return []
            }
        }
        set{
            shared?.set(newValue, forKey: constants.imageDeleteQueue)
        }
    }
    
    //MARK: -外观模式（深色）
    static var appearanceMode:Int{
        get{
            if let mode = shared?.object(forKey: constants.appearanceMode) as? Int {
                return mode
            }else{
                return 0
            }
        }
        set{
            shared?.set(newValue, forKey: constants.appearanceMode)
        }
    }
    
    //自动创建日记
    static var autoCreate:Bool{
        get{
            if let mode = shared?.object(forKey: constants.autoCreate) as? Bool {
                return mode
            }else{
                return true
            }
        }
        set{
            shared?.set(newValue, forKey: constants.autoCreate)
        }
    }
    
    //MARK: 版本更新
    
    //是否已经更新3.2的数据库版本
    static var hasUpdated32:Bool{
        get{
            if let state = shared?.object(forKey: constants.hasUpdated32) as? Bool {
                return state
            }else{
                return false
            }
        }
        set{
            shared?.set(newValue, forKey: constants.hasUpdated32)
        }
    }
}



