//
//  AttributedString+.swift
//  subViewTextView_demo
//
//  Created by yy on 2021/8/25.
//

import Foundation
import UIKit

public extension NSTextAttachment {

    convenience init(image: UIImage, size: CGSize? = nil) {
        self.init(data: nil, ofType: nil)

        self.image = image
        if let size = size {
            self.bounds = CGRect(origin: .zero, size: size)
        }
    }

}

public extension NSAttributedString {

    func insertingAttachment(_ attachment: NSTextAttachment, at index: Int, with paragraphStyle: NSParagraphStyle? = nil) -> NSAttributedString {
        let copy = self.mutableCopy() as! NSMutableAttributedString
        copy.insertAttachment(attachment, at: index, with: paragraphStyle)

        return copy.copy() as! NSAttributedString
    }
    
    func replacingAttchment(_ attachment: NSTextAttachment, attchmentAt index: Int, with paragraphStyle: NSParagraphStyle? = nil) -> NSAttributedString {
        let copy = self.mutableCopy() as! NSMutableAttributedString
        copy.replaceAttchment(attachment, attchmentAt: index, with: paragraphStyle)

        return copy.copy() as! NSAttributedString
    }

    func addingAttributes(_ attributes: [NSAttributedString.Key : Any]) -> NSAttributedString {
        let copy = self.mutableCopy() as! NSMutableAttributedString
        copy.addAttributes(attributes)

        return copy.copy() as! NSAttributedString
    }

}

public extension NSMutableAttributedString {

    func insertAttachment(_ attachment: NSTextAttachment, at index: Int, with paragraphStyle: NSParagraphStyle? = nil) {
        let plainAttachmentString = NSAttributedString(attachment: attachment)

        if let paragraphStyle = paragraphStyle {
            let attachmentString = plainAttachmentString
                .addingAttributes([
                    .paragraphStyle : paragraphStyle,
                    .font : userDefaultManager.font,
                    .foregroundColor : UIColor.label
                ])
            let separatorString = NSAttributedString(string: .paragraphSeparator)

            // Surround the attachment string with paragraph separators, so that the paragraph style is only applied to it
            let insertion = NSMutableAttributedString()
            //insertion.append(separatorString)
            insertion.append(attachmentString)
            //insertion.append(separatorString)

            self.insert(insertion, at: index)
        } else {
            self.insert(plainAttachmentString, at: index)
        }
    }
    
    func replaceAttchment(_ attachment: NSTextAttachment, attchmentAt index: Int, with paragraphStyle: NSParagraphStyle? = nil) {
        let plainAttachmentString = NSAttributedString(attachment: attachment)

        if let paragraphStyle = paragraphStyle {
            let attachmentString = plainAttachmentString
                .addingAttributes([
                    .paragraphStyle : paragraphStyle,
                    .font : userDefaultManager.font,
                    .foregroundColor : UIColor.label
                ])
            let insertion = NSMutableAttributedString()
            insertion.append(attachmentString)

            let range = NSRange(location: index, length: insertion.length)
            print("range:\(range),upperBound:\(range.upperBound),attributedStiring.length:\(self.length)")
            if range.upperBound > self.length{
                // 防止out of bounds溢出
                // TODO: 将超出的长度用空格来填补，然后再replaceCharacters
                indicatorViewManager.shared.start(type: .warning)
                let text =  "\(range.upperBound)>self.length(\(self.length))"
                indicatorViewManager.shared.stop(withText: text)
                return
            }
            self.replaceCharacters(in: range, with: insertion)
        } else {
            let range = NSRange(location: index, length: 1)
            if range.upperBound > self.length{
                return
            }
            self.replaceCharacters(in: range, with: plainAttachmentString)
        }
    }

    func addAttributes(_ attributes: [NSAttributedString.Key : Any]) {
        self.addAttributes(attributes, range: NSRange(location: 0, length: self.length))
    }

}

public extension String {

    static let paragraphSeparator = "\u{2029}"
    
}
