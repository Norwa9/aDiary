//
//  LWTextAligment.swift
//  subViewTextView_demo
//
//  Created by yy on 2021/8/25.
//

import Foundation
import UIKit

enum LWTextAligmentStyle:Int,Codable {
    case left = 0
    case center = 1
    case right = 2
}
var imageCenterParagraphStyle:NSMutableParagraphStyle  = {
    let paragraphStyle = NSMutableParagraphStyle()
    // Make paragraph styles for attachments
    paragraphStyle.alignment = .center
    paragraphStyle.paragraphSpacing = userDefaultManager.lineSpacing
    paragraphStyle.paragraphSpacingBefore = userDefaultManager.lineSpacing
    return paragraphStyle
}()

var imageLeftParagraphStyle:NSMutableParagraphStyle  = {
    let paragraphStyle = NSMutableParagraphStyle()
    // Make paragraph styles for attachments
    paragraphStyle.alignment = .left
    paragraphStyle.paragraphSpacing = userDefaultManager.lineSpacing
    paragraphStyle.paragraphSpacingBefore = userDefaultManager.lineSpacing
    return paragraphStyle
}()

var imageRightParagraphStyle:NSMutableParagraphStyle  = {
    let paragraphStyle = NSMutableParagraphStyle()
    // Make paragraph styles for attachments
    paragraphStyle.alignment = .right
    paragraphStyle.paragraphSpacing = userDefaultManager.lineSpacing
    paragraphStyle.paragraphSpacingBefore = userDefaultManager.lineSpacing
    return paragraphStyle
}()


var textCenterParagraphStyle:NSMutableParagraphStyle  = {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = userDefaultManager.lineSpacing
    paragraphStyle.alignment = .center
    return paragraphStyle
}()

var textLeftParagraphStyle:NSMutableParagraphStyle  = {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = userDefaultManager.lineSpacing
    paragraphStyle.alignment = .left
    return paragraphStyle
}()

var textRightParagraphStyle:NSMutableParagraphStyle  = {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = userDefaultManager.lineSpacing
    paragraphStyle.alignment = .right
    return paragraphStyle
}()
