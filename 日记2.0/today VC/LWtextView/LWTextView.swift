//
//  LWTextView.swift
//  日记2.0
//
//  Created by yy on 2021/7/20.
//

import UIKit
import MobileCoreServices

class LWTextView: UITextView {
    ///从storeboard读取
    required init?(coder: NSCoder) {
        if #available(iOS 13.2, *) {
            super.init(coder: coder)
        }
        else {
            super.init(frame: .zero, textContainer: nil)
        }
    }
    
    override func copy(_ sender: Any?) {
        let attributedString = NSMutableAttributedString(attributedString: self.textStorage.attributedSubstring(from: self.selectedRange)).unLoadCheckboxes()
        
        if self.textStorage.length >= self.selectedRange.upperBound {
            if let rtfd = try? attributedString.data(from: NSMakeRange(0, attributedString.length), documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType:NSAttributedString.DocumentType.rtfd]) {

                UIPasteboard.general.setItems([
                    [kUTTypePlainText as String: attributedString.string],
                    ["UIPasteboard.attributed.text": rtfd],
                    [kUTTypeFlatRTFD as String: rtfd]
                ])

                return
            }
        }
        
        super.copy(sender)
    }
    
    override func cut(_ sender: Any?) {
        let attributedString = NSMutableAttributedString(attributedString: self.textStorage.attributedSubstring(from: self.selectedRange)).unLoadCheckboxes()

        if self.textStorage.length >= self.selectedRange.upperBound {
            if let rtfd = try? attributedString.data(
                from: NSMakeRange(0, attributedString.length),
                documentAttributes: [
                    NSAttributedString.DocumentAttributeKey.documentType:
                        NSAttributedString.DocumentType.rtfd
                ]
            ) {
                UIPasteboard.general.setData(rtfd, forPasteboardType: "UIPasteboard.attributed.text"
                )
                print("cut")
                if let textRange = getTextRange() {
                    self.replace(textRange, withText: "")
                }

                return
            }

            let item = [kUTTypeUTF8PlainText as String : attributedString.string as Any]
            UIPasteboard.general.items = [item]
        }
        
        super.cut(sender)
    }
    
    override func paste(_ sender: Any?) {
        for item in UIPasteboard.general.items {
            if let rtfd = item["UIPasteboard.attributed.text"] as? Data {
                if let attributedString = try? NSAttributedString(data: rtfd, options: [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.rtfd], documentAttributes: nil) {

                    let attributedString = NSMutableAttributedString(attributedString: attributedString)
                    attributedString.loadCheckboxes()
                    
                    
                    let pasteAStringRange = NSRange(location: 0, length: attributedString.length)
                    attributedString.enumerateAttribute(.attachment, in: pasteAStringRange, options: [], using: { [] (object, range, pointer) in
                        let location = range.location
                        //如果扫描到todo，就跳过
                        if let _ = attributedString.attribute(.todo, at: location, effectiveRange: nil) as? Int {
                            return
                        }else{
                            if let attchment = object as? NSTextAttachment,let image = attchment.image(forBounds: self.bounds, textContainer: self.textContainer, characterIndex: location){
                                print("paste")
                                //1.重新添加attribute
                                attributedString.addAttribute(.image, value: 1, range: NSRange(location: location, length: 1))

                                //2.调整图片bounds
                                let aspect = image.size.width / image.size.height
                                let pedding:CGFloat = 15
                                let newWidth = (bounds.width - 2 * pedding) / userDefaultManager.imageScalingFactor
                                let newHeight = (newWidth / aspect)
                                let para = NSMutableParagraphStyle()
                                para.alignment = .center
                                attributedString.addAttribute(.paragraphStyle, value: para, range: NSRange(location: location, length: 1))
                                attchment.bounds = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
                            }
                        }

                    })
                    
                    
                    let newRange = NSRange(location: selectedRange.location, length: attributedString.length)
                    if let selTextRange = selectedTextRange, let undoManager = undoManager {
                        undoManager.beginUndoGrouping()
                        
                        self.replace(selTextRange, withText: attributedString.string)
                        self.textStorage.replaceCharacters(in: newRange, with: attributedString)
                        undoManager.endUndoGrouping()
                    }

                    self.layoutManager.invalidateDisplay(forCharacterRange: NSRange(location: 0, length: self.textStorage.length))
                    
                    return
                }
            }
        }
        
        super.paste(sender)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return true
        }

        return super.canPerformAction(action, withSender: sender)
    }

}
