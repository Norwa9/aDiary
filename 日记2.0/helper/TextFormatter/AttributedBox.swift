//
//  AttributedBox.swift
//  日记2.0
//
//  Created by 罗威 on 2021/7/15.
//

import Foundation
import UIKit

class AttributedBox {
    ///返回[√]复选框
    public static func getChecked() -> NSMutableAttributedString? {
        let checkboxText = getCleanChecked()
        checkboxText.append(NSAttributedString(string: " "))
        
        checkboxText.addAttribute(.foregroundColor, value: UIColor.label, range: NSRange(0..<2))
        checkboxText.addAttribute(.font, value: userDefaultManager.font, range: NSRange(0..<2))
        
        return checkboxText
    }

    ///返回[x]复选框
    public static func getUnChecked() -> NSMutableAttributedString? {
        let checkboxText = getCleanUnchecked()
        checkboxText.append(NSAttributedString(string: " "))
        
        checkboxText.addAttribute(.foregroundColor, value: UIColor.label, range: NSRange(0..<2))
        checkboxText.addAttribute(.font, value: userDefaultManager.font, range: NSRange(0..<2))
        
        return checkboxText
    }

    private static func getCleanUnchecked() -> NSMutableAttributedString {
        let font = userDefaultManager.font
        let size = font.pointSize + font.pointSize / 2
        let attachment = NSTextAttachment()

        let image = getImage(name: "checkbox_empty")
        attachment.image = image

        attachment.bounds = CGRect(x: CGFloat(0), y: (font.capHeight - size) / 2, width: size, height: size)

        let checkboxText = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))

        //0代表没有勾选
        checkboxText.addAttribute(.todo, value: 0, range: NSRange(0..<1))

        if #available(OSX 10.13, iOS 10.0, *) {
        } else {
            let offset = (font.capHeight - size) / 2
            checkboxText.addAttribute(.baselineOffset, value: offset, range: NSRange(0..<1))
        }

        let parStyle = NSMutableParagraphStyle()
        parStyle.lineSpacing = CGFloat(userDefaultManager.lineSpacing)
        checkboxText.addAttribute(.paragraphStyle, value: parStyle, range: NSRange(0..<1))

        return checkboxText
    }

    private static func getCleanChecked() -> NSMutableAttributedString {
        let font = userDefaultManager.font
        let size = font.pointSize + font.pointSize / 2
        let attachment = NSTextAttachment()

        let image = getImage(name: "checkbox")
        attachment.image = image

        attachment.bounds = CGRect(x: CGFloat(0), y: (font.capHeight - size) / 2, width: size, height: size)

        let checkboxText = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))

        //1代表勾选
        checkboxText.addAttribute(.todo, value: 1, range: NSRange(0..<1))

        if #available(OSX 10.13, iOS 10.0, *) {
        } else {
            let offset = (font.capHeight - size) / 2
            checkboxText.addAttribute(.baselineOffset, value: offset, range: NSRange(0..<1))
        }

        let parStyle = NSMutableParagraphStyle()
        parStyle.lineSpacing = CGFloat(userDefaultManager.lineSpacing)
        checkboxText.addAttribute(.paragraphStyle, value: parStyle, range: NSRange(0..<1))

        return checkboxText
    }

    public static func getImage(name: String) -> UIImage {
        return UIImage(named: "\(name).png")!
    }
}
