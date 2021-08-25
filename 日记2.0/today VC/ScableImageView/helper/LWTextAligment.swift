//
//  LWTextAligment.swift
//  subViewTextView_demo
//
//  Created by yy on 2021/8/25.
//

import Foundation
import UIKit

enum LWTextAligmentStyle:Int,Codable {
    case center 
    case left
    case right
}
var centerParagraphStyle:NSMutableParagraphStyle  = {
    let paragraphStyle = NSMutableParagraphStyle()
    // Make paragraph styles for attachments
    paragraphStyle.alignment = .center
    paragraphStyle.paragraphSpacing = 10
    paragraphStyle.paragraphSpacingBefore = 10
    return paragraphStyle
}()

var leftParagraphStyle:NSMutableParagraphStyle  = {
    let paragraphStyle = NSMutableParagraphStyle()
    // Make paragraph styles for attachments
    paragraphStyle.alignment = .left
    paragraphStyle.paragraphSpacing = 10
    paragraphStyle.paragraphSpacingBefore = 10
    return paragraphStyle
}()

var rightParagraphStyle:NSMutableParagraphStyle  = {
    let paragraphStyle = NSMutableParagraphStyle()
    // Make paragraph styles for attachments
    paragraphStyle.alignment = .right
    paragraphStyle.paragraphSpacing = 10
    paragraphStyle.paragraphSpacingBefore = 10
    return paragraphStyle
}()
