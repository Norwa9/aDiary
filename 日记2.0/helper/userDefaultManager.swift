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
    static let DefaultFontSize:CGFloat = 18.0
    static let defaultEditorLineSpacing:CGFloat = 3
    
    private struct constants {
        static let hasInitialized = "hasInitialized"
        static let imageSizeStyle = "imageSizeStyle"
        static let fontNameKey = "fontName"
        static let fontSizeKey = "fontSize"
        static let useBiometricsKey = "biometrics"
        static let usePasswordKey = "usePassword"
        static let appPasswordKey = "password"
        static let lineSpacingKey = "lineSpacing"
        static let layoutType = "layoutType"
        static let requestReviewTimes = "requestReviewTimes"
        static let userInsatlledFontNames = "userInsatlledFontNames"
    }
    
    
    static var fontName:String?{
        get{
            if let returnFontName = shared?.object(forKey: constants.fontNameKey) as? String{
                return returnFontName
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
            if let userFontName = self.fontName{
                return UIFont(name: userFontName, size: self.fontSize)!
            }else{
                return UIFont.systemFont(ofSize: self.fontSize, weight: .regular)
            }
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
    
    /*
     list = 1 // 列表
     waterFall = 2 //瀑布流
     */
    static var layoutType:Int{
        get{
            if let type = shared?.object(forKey: constants.layoutType) as? Int {
                return type
            }else{
                return 1//默认展示1列，即列表视图
            }
        }
        set{
            shared?.set(newValue, forKey: constants.layoutType)
        }
    }
    
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
    
    static var userInsatlledFontNames:[String]{
        get{
            if let names = shared?.object(forKey: constants.userInsatlledFontNames) as? [String] {
                return names
            }else{
                return []
            }
        }
        set{
            shared?.set(newValue, forKey: constants.userInsatlledFontNames)
        }
    }
    
    
}



