//
//  UIColor_Extension.swift
//  日记2.0
//
//  Created by 罗威 on 2021/3/21.
//

import Foundation
import UIKit
///主题绿色：#029B5A
func APP_GREEN_COLOR() -> UIColor{
    return #colorLiteral(red: 0.007843137255, green: 0.6078431373, blue: 0.3529411765, alpha: 1)
}

func APP_GRAY_COLOR() -> UIColor{
    return UIColor.colorWithHex(hexColor: 0xF7F5F2)
}


extension UIColor{
    ///十六进制表示颜色
    static func colorWithHex(hexColor:Int64)->UIColor{
        let red = ((CGFloat)((hexColor & 0xFF0000) >> 16))/255.0;
        let green = ((CGFloat)((hexColor & 0xFF00) >> 8))/255.0;
        let blue = ((CGFloat)(hexColor & 0xFF))/255.0;

        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}
