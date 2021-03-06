//
//  LWTextView.swift
//  日记2.0
//
//  Created by yy on 2021/7/20.
//

import UIKit
import MobileCoreServices
import SubviewAttachingTextView

class LWTextView: SubviewAttachingTextView {
    weak var textViewController:LWTextViewController?
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.backgroundColor = .systemBackground
        self.textColor = .label
    }
    
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
        let attributedString = NSMutableAttributedString(attributedString: self.textStorage.attributedSubstring(from: self.selectedRange))
        
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
        let attributedString = NSMutableAttributedString(attributedString: self.textStorage.attributedSubstring(from: self.selectedRange))

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

//MARK: reload插件
extension LWTextView{
    /// 图片改变后，刷新textView里的图片
    func reloadScableImage(endView: ScalableImageView,shouldAddDoneView:Bool = false) {
        print("reloadScableImage")
        let newViewModel = endView.viewModel
        newViewModel.bounds = endView.frame
        newViewModel.getNewestLocation(attributedString: self.attributedText){
            print("newView.model.location : \(newViewModel.location)")
            
            let newView = ScalableImageView(viewModel: newViewModel)
            newView.delegate = self
            newView.backgroundColor = .clear
            if shouldAddDoneView{
                newView.viewModel.isEditing = true
                newView.viewModel.shouldShowDoneView = true
                newView.addDotView()
            }
            let newAttchment = SubviewTextAttachment(view: newView, size: newView.size)
            self.attributedText = self.attributedText.replacingAttchment(newAttchment, attchmentAt: newViewModel.location, with: newViewModel.paraStyle)
            self.selectedRange = NSRange(location: newViewModel.location, length: 0)
        }
    }
    
    /// todo改变后，刷新textView里的todo视图
    func reloadTodoView(endView: LWTodoView) {
        print("reloadTodoView")
        // 此时viewModel已经获取到了新的todoView bounds
        let newViewModel = endView.viewModel
        newViewModel.getNewestLocation(attributedString: self.attributedText){
            print("newtTodoView.model.location : \(newViewModel.location)")
            
            let newView = LWTodoView(viewModel: newViewModel)
            let newAttchment = SubviewTextAttachment(view: newView, size: newView.size)
            self.attributedText = self.attributedText.replacingAttchment(newAttchment, attchmentAt: newViewModel.location, with: textLeftParagraphStyle)
            self.selectedRange = NSRange(location: newViewModel.location, length: 0)
        }
    }
    
    
}

//MARK: -默认输入特性
extension LWTextView {
    ///设置默认的文字输入模式
    func setDefaultTypingAttributes(){
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = userDefaultManager.lineSpacing
        let typingAttributes:[NSAttributedString.Key:Any] = [
            .paragraphStyle: paragraphStyle,
            .font:userDefaultManager.font,
            .foregroundColor : UIColor.label
        ]
        self.typingAttributes = typingAttributes
    }
    
    ///插入图片后，重新设置居左的输入模式
    func setLeftTypingAttributes(){
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = userDefaultManager.lineSpacing
        paragraphStyle.alignment = .left
        let typingAttributes:[NSAttributedString.Key:Any] = [
            .paragraphStyle: paragraphStyle,
            .font:userDefaultManager.font,
            .foregroundColor : UIColor.label
        ]
        self.typingAttributes = typingAttributes
    }
}
