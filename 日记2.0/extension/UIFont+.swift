//
//  UIFont_Extension.swift
//  日记2.0
//
//  Created by 罗威 on 2021/4/12.
//

import Foundation
import UIKit

class appDefaultFonts {
    //topbar年份字体
    static var dateLable1Font:UIFont = UIFont.init(name: "DIN Alternate", size: 24)!
    //topbar月份字体
    static var dateLable2Font:UIFont = UIFont.init(name: "DIN Alternate", size: 18)!
}

extension UIFont{
    //日历cell中日期的字体
    static func appCalendarCellTitleFont(fontName:String = "DIN Alternate",fontSize:CGFloat = 20)->UIFont{
        return UIFont.init(name: fontName, size: fontSize)!
    }
    
    //切换月份的字体
    static func appMonthButtonFont(fontName:String = "DIN Alternate",fontSize:CGFloat = 15)->UIFont{
        return UIFont.init(name: fontName, size: fontSize)!
    }
}
