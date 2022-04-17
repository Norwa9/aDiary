//
//  LWColorConstants.swift
//  日记2.0
//
//  Created by 罗威 on 2022/4/9.
//

import Foundation
import UIKit


class LWColorConstatnsManager{
    // 标签
//    UIColor.colorWithHex(hexColor: 0xCCCCCC)
//    .systemGray3
    static let tagBGColor:UIColor = .black.withAlphaComponent(0.6)
    static let tagTextColor:UIColor = .white
    
    
    // 阴影
    static let LWShodowColor:UIColor = UIColor.colorWithHex(hexColor: 0x9AAACF)
    
    // 背景白色/黑色
    static let LWSoftBGColor:UIColor = .systemBackground
//    static let LWSoftBGColor:UIColor = UIColor.init { (t) -> UIColor in
//        if t.userInterfaceStyle == .dark{
//            return UIColor.colorWithHex(hexColor: 0x1A1920)
//        }else{
//            return UIColor.colorWithHex(hexColor: 0xFCFAFF)
//        }
//    }
    
    

    
}
