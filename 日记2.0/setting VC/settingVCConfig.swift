//
//  settingVCConfig.swift
//  日记2.0
//
//  Created by 罗威 on 2021/12/18.
//

import Foundation
import UIKit

class settingVCConfig{
    static func buttonAttributedTitle(title:String,color:UIColor = .label) -> NSAttributedString{
        let attributes:[NSAttributedString.Key : Any] = [
            .font : UIFont.systemFont(ofSize: 18, weight: .medium),
            .foregroundColor : color,
        ]
        let attrString = NSAttributedString(string: title, attributes: attributes)
        return attrString
    }
    
}
