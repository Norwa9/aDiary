//
//  NSMutableAttributedString+.swift
//  日记2.0
//
//  Created by 罗威 on 2021/7/15.
//

import Foundation
import UIKit

//MARK:-NSMutableAttributedString + todo
extension NSMutableAttributedString{
    @discardableResult func addCheckAttribute(range:NSRange) ->Self{
        self.addAttribute(.strikethroughStyle, value: 1, range: range)
        self.addAttribute(.foregroundColor, value: UIColor.systemGray, range: range)
        return self
    }
    
    @discardableResult func addUncheckAttribute(range:NSRange)->Self{
        self.removeAttribute(.strikethroughStyle, range: range)
        self.addAttribute(.foregroundColor, value: UIColor.label, range: range)
        return self
    }
}
