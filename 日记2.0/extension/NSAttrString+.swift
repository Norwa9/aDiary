//
//  NSAttrString_Extension.swift
//  日记2.0
//
//  Created by 罗威 on 2021/4/12.
//

import Foundation
import UIKit

extension NSAttributedString{
    /*
     todayVC.swift
     settingViewController.swift
     */
    //处理从本地读取的富文本
    //功能1：设置图片附件的显示大小，添加用户偏好的文本属性
    //功能2：将富文本清洗成collection view cell显示的纯文本
    func processAttrString(textView:UITextView,returnCleanText:Bool = false,fillWithEmptyImage:Bool = false) -> NSMutableAttributedString {
        let bounds = textView.bounds
        let container = textView.textContainer
        
        let cleanText = NSMutableAttributedString(attributedString: self)
        let mutableText = NSMutableAttributedString(attributedString: self)
        
        //1、施加用户自定义格式
        let attrText = mutableText.addUserDefaultAttributes()
        
        //2、遍历所有的图片。调整图片，让图片显示正确的大小
        
        attrText.enumerateAttribute(.attachment, in: NSRange(location: 0, length: attrText.length), options: [], using: { [] (object, range, pointer) in
            let location = range.location
            print("存储图片:.attachment range:\(range)")
            guard let value = attrText.attribute(.image, at: location, effectiveRange: nil) as? Int,value == 1 else{return}
            
            print("存储图片,.image range :\(range)")
            
            if let attachment = object as? NSTextAttachment, let img = attachment.image(forBounds: bounds, textContainer: container, characterIndex: location){
                //获取cleanText
                cleanText.replaceCharacters(in: range, with: "P")//为了正则表达式匹配，将图片替换成"P"。
                
                //设置富文本中的图片：设置大小&设置居中
                let aspect = img.size.width / img.size.height
                let pedding:CGFloat = 15
                let newWidth = (textView.frame.width - 2 * pedding) / userDefaultManager.imageScalingFactor
                let newHeight = (newWidth / aspect)
                
                
                //重新设置居中展示
                let para = NSMutableParagraphStyle()
                para.alignment = .center
                attrText.addAttribute(.paragraphStyle, value: para, range: range)
                
                //当填充空白图
                if fillWithEmptyImage{
                    attachment.image = UIImage.emptyImage(with: CGSize(width: newWidth, height:newHeight))
                    attachment.bounds = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
                    return
                }
                
                //设置展示大小
                attachment.bounds = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
                
                return
            }
        })
        
        //3、返回处理后的结果
        if returnCleanText{
            return cleanText
        }else{
            return attrText
        }
        
    }
    
    ///读取富文本，并为图片附件设置正确的大小、方向
    ///textViewScreenshot
    ///loadTextViewContent(with:)
    func processAttrString(bounds:CGRect,container:NSTextContainer)->NSMutableAttributedString{
        let mutableText = NSMutableAttributedString(attributedString: self)
        
        //1、施加用户自定义格式
        let attrText = mutableText.addUserDefaultAttributes()
        
        //2、、调整图片，让图片显示正确的大小
        print("读取的attrText:\(attrText)")
        attrText.enumerateAttribute(.attachment, in: NSRange(location: 0, length: attrText.length), options: [], using: { [] (object, range, pointer) in
            print("读取图片:.attachment range:\(range)")
            let location = range.location
            guard let value = attrText.attribute(.image, at: location, effectiveRange: nil) as? Int,value == 1 else{return}
            
            print("读取图片:.image range:\(range)")
            
            if let attachment = object as? NSTextAttachment, let img = attachment.image(forBounds: bounds, textContainer: container, characterIndex: location){
                //设置富文本中的图片：设置大小&设置居中
                let aspect = img.size.width / img.size.height
                let pedding:CGFloat = 15
                let newWidth = (bounds.width - 2 * pedding) / userDefaultManager.imageScalingFactor
                let newHeight = (newWidth / aspect)
                
                //重新设置居中展示
                let para = NSMutableParagraphStyle()
                para.alignment = .center
                attrText.addAttribute(.paragraphStyle, value: para, range: range)
                
                //设置展示大小
                attachment.bounds = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
                
                return
            }
        })
//        attrText.enumerateAttribute(NSAttributedString.Key.attachment, in: NSRange(location: 0, length: attrText.length), options: [], using: { [] (object, range, pointer) in
//            if let attachment = object as? NSTextAttachment,let img = attachment.image(forBounds: attachment.bounds, textContainer: nil, characterIndex: range.location){
//                //设置富文本中的图片：设置大小&设置居中
//                let aspect = img.size.width / img.size.height
//                let pedding:CGFloat = 15
//                let newWidth = (bounds.width - 2 * pedding) / userDefaultManager.imageScalingFactor
//                let newHeight = (newWidth / aspect)
//                
//                //重新设置居中展示
//                let para = NSMutableParagraphStyle()
//                para.alignment = .center
//                attrText.addAttribute(.paragraphStyle, value: para, range: range)
//                
//                //设置展示大小
//                attachment.bounds = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
//                
//                return
//                
//            }
//            })
        //3、返回处理后的结果
        return attrText
    }
    
    ///将用户的编辑器属性施加于attrString上
    func addUserDefaultAttributes(lineSpacing:CGFloat = userDefaultManager.lineSpacing) -> NSMutableAttributedString{
        let paraStyle = NSMutableParagraphStyle()
//        paraStyle.alignment = .left
        paraStyle.lineSpacing = lineSpacing
        let attributes: [NSAttributedString.Key:Any] = [
            .font:userDefaultManager.font,
            .paragraphStyle : paraStyle
        ]
        let mutableAttr = NSMutableAttributedString(attributedString: self)
        mutableAttr.addAttributes(attributes, range: NSRange(location: 0, length: mutableAttr.length))
        return mutableAttr
    }
    
    func data()->Data?{
        return try? self.data(from: NSMakeRange(0, self.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd,.characterEncoding:String.Encoding.utf16])
    }
}


extension NSAttributedString {
    ///段落内是否有.todo这类型的属性
    public func hasTodoAttribute() -> Bool {
        var found = false
        enumerateAttribute(.todo, in: NSRange(0..<length), options: .init()) { _, _, stop in
            found = true
            stop.pointee = true
        }
        return found
    }
}



