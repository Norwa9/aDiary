//
//  NSAttrString_Extension.swift
//  日记2.0
//
//  Created by 罗威 on 2021/4/12.
//

import Foundation
import UIKit

extension NSAttributedString{
    //将用户的编辑器属性施加于attrString上
    //返回NSMutableAttributedString
    func addUserDefaultAttributes(fontName:String = userDefaultManager.fontName,fontSize:CGFloat = userDefaultManager.fontSize,lineSpacing:CGFloat = userDefaultManager.lineSpacing) -> NSMutableAttributedString{
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = .left
        paraStyle.lineSpacing = lineSpacing
        let attributes: [NSAttributedString.Key:Any] = [
            .font:UIFont(name: fontName, size: CGFloat(fontSize))!,
            .paragraphStyle : paraStyle
        ]
        let mutableAttr = NSMutableAttributedString(attributedString: self)
        mutableAttr.addAttributes(attributes, range: NSRange(location: 0, length: mutableAttr.length))
        return mutableAttr
    }
}
