//
//  settingVCConfig.swift
//  日记2.0
//
//  Created by 罗威 on 2021/12/18.
//

import Foundation
import UIKit

class settingVCConfig{
    // MARK: 设置
    /// 保存
    static func saveButtonAttributedTitle(title:String,color:UIColor = .label) -> NSAttributedString{
        let attributes:[NSAttributedString.Key : Any] = [
            .font : UIFont.systemFont(ofSize: 18, weight: .medium),
            .foregroundColor : color,
        ]
        let attrString = NSAttributedString(string: title, attributes: attributes)
        return attrString
    }
    
    // 返回
    static func cancelButtonAttributedTitle(title:String,color:UIColor = .label) -> NSAttributedString{
        let attributes:[NSAttributedString.Key : Any] = [
            .font : UIFont.systemFont(ofSize: 18, weight: .regular),
            .foregroundColor : color,
        ]
        let attrString = NSAttributedString(string: title, attributes: attributes)
        return attrString
    }
    
    // 导出pdf
    static func exportPDFButtonAttributedTitle(title:String,color:UIColor = .label) -> NSAttributedString{
        let attributes:[NSAttributedString.Key : Any] = [
            .font : UIFont.systemFont(ofSize: 18, weight: .medium),
            .foregroundColor : color,
        ]
        let attrString = NSAttributedString(string: title, attributes: attributes)
        return attrString
    }
    
    // 导出pdf
    static func reviewButtonAttributedTitle(title:String,color:UIColor = .label) -> NSAttributedString{
        let attributes:[NSAttributedString.Key : Any] = [
            .font : UIFont.systemFont(ofSize: 18, weight: .medium),
            .foregroundColor : color,
        ]
        let attrString = NSAttributedString(string: title, attributes: attributes)
        return attrString
    }
    
}
