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
    
    static let DefaultFontSize:CGFloat = 20
    
    private struct constants {
        static let fontNameKey = "fontName"
        static let fontSizeKey = "fontSize"
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
}
