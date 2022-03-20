//
//  UIColor+DarkMode.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/6.
//

import Foundation
import UIKit

///自定义的monthCell动态颜色
let monthCellDynamicColor = UIColor.init { (uiTraitCollection) -> UIColor in
    if uiTraitCollection.userInterfaceStyle == .dark{
        return .secondarySystemBackground
    }else{
        return .systemBackground
    }
}

///自定义的月份按钮容器视图的动态颜色
let monthBtnStackViewDynamicColor = monthCellDynamicColor

///自定义设置模块的容器视图的动态颜色
let settingContainerDynamicColor = monthCellDynamicColor

///日历cell的背景色
let calendarCellBackgroudDynamicColor = UIColor.init { (t) -> UIColor in
    if t.userInterfaceStyle == .dark{
        return .tertiarySystemBackground
    }else{
        return #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
    }
}

///日历cell的事件点颜色
let eventDotDynamicColor = UIColor.init { (t) -> UIColor in
    if t.userInterfaceStyle == .dark{
        return .gray
    }else{
        return .black
    }
}

let fontPickerButtonDynamicColor = UIColor.init { (t) -> UIColor in
    if t.userInterfaceStyle == .dark{
        return UIColor.colorWithHex(hexColor: 0x3D3E41)
    }else{
        return UIColor.colorWithHex(hexColor: 0xEEEFEF)
    }
}

/// soundView的动态色
let soundViewDynamicColor = UIColor.init { (t) -> UIColor in
    if t.userInterfaceStyle == .dark{
        return UIColor.systemGray6
    }else{
        return UIColor.systemGray6.withAlphaComponent(0.5)
    }
}

