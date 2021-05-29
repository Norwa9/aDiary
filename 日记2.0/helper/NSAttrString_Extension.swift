//
//  NSAttrString_Extension.swift
//  日记2.0
//
//  Created by 罗威 on 2021/4/12.
//

import Foundation
import UIKit

extension NSAttributedString{
    //处理从本地读取的富文本
    //功能1：设置图片附件的显示大小，添加用户偏好的文本属性
    //功能2：将富文本清洗成collection view cell显示的纯文本
    func processAttrString(textView:UITextView,returnCleanText:Bool = false,fillWithEmptyImage:Bool = false) -> NSMutableAttributedString {
        let cleanText = NSMutableAttributedString(attributedString: self)
        let mutableText = NSMutableAttributedString(attributedString: self)
        
        //1、施加用户自定义格式
        let attrText = mutableText.addUserDefaultAttributes()
        
        let bounds = textView.bounds
        //2、、调整图片，让图片显示正确的大小
        attrText.enumerateAttribute(NSAttributedString.Key.attachment, in: NSRange(location: 0, length: attrText.length), options: [], using: { [] (object, range, pointer) in
//            let textViewAsAny: Any = textView
            if let attachment = object as? NSTextAttachment, let img = attachment.image(forBounds: bounds, textContainer: textView.textContainer, characterIndex: range.location){
                //获取cleanText
                cleanText.replaceCharacters(in: range, with: "P")//为了正则表达式匹配，将图片替换成"P"。
                
                //设置富文本中的图片：设置大小&设置居中
                let aspect = img.size.width / img.size.height
                let pedding:CGFloat = 10
                let newWidth = (textView.frame.width - pedding) / userDefaultManager.imageScalingFactor
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
    
    /*
     exportManager.swift
     */
    //重载版本，内部不使用textView
    func processAttrString(textViewbouds:CGRect,textContainer:NSTextContainer,returnCleanText:Bool = false,fillWithEmptyImage:Bool = false) -> NSMutableAttributedString {
        let cleanText = NSMutableAttributedString(attributedString: self)
        let mutableText = NSMutableAttributedString(attributedString: self)
        
        //1、施加用户自定义格式
        let attrText = mutableText.addUserDefaultAttributes()
        
        let bounds = textViewbouds
        //2、、调整图片，让图片显示正确的大小
        attrText.enumerateAttribute(NSAttributedString.Key.attachment, in: NSRange(location: 0, length: attrText.length), options: [], using: { [] (object, range, pointer) in
            if let attachment = object as? NSTextAttachment, let img = attachment.image(forBounds: bounds, textContainer: textContainer, characterIndex: range.location){
                //获取cleanText
                cleanText.replaceCharacters(in: range, with: "P")//为了正则表达式匹配，将图片替换成"P"。
                
                //设置富文本中的图片：设置大小&设置居中
                let aspect = img.size.width / img.size.height
                let pedding:CGFloat = 10
                let newWidth = (bounds.width - pedding) / userDefaultManager.imageScalingFactor
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
    
    func processAttrString(bounds:CGRect)->NSMutableAttributedString{
        let mutableText = NSMutableAttributedString(attributedString: self)
        
        //1、施加用户自定义格式
        let attrText = mutableText.addUserDefaultAttributes()
        
        //2、、调整图片，让图片显示正确的大小
        attrText.enumerateAttribute(NSAttributedString.Key.attachment, in: NSRange(location: 0, length: attrText.length), options: [], using: { [] (object, range, pointer) in
            if let attachment = object as? NSTextAttachment,let img = attachment.image(forBounds: attachment.bounds, textContainer: nil, characterIndex: range.location){
                //设置富文本中的图片：设置大小&设置居中
                let aspect = img.size.width / img.size.height
                let pedding:CGFloat = 10
                let newWidth = (bounds.width - pedding) / userDefaultManager.imageScalingFactor
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
        //3、返回处理后的结果
        return attrText
    }
    
    //将用户的编辑器属性施加于attrString上
    //返回NSMutableAttributedString
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
    
    static func textViewPlaceholder()->NSAttributedString{
        let paraStyle = NSMutableParagraphStyle()
//        paraStyle.alignment = .left
        paraStyle.lineSpacing = userDefaultManager.lineSpacing
        let attributes:[NSAttributedString.Key:Any] = [
            .font:userDefaultManager.font,
            .paragraphStyle : paraStyle,
            .foregroundColor : UIColor.lightGray,
        ]
        let placeHolder = "标题.."
        return NSAttributedString(string: placeHolder, attributes: attributes)
    }
}

//MARK:-根据日期信息将富文本存储到文件目录
func saveAttributedString(date_string:String,aString:NSAttributedString?) {
    //1、保存attributedString
    do {
        let file = try aString?.fileWrapper (
            from: NSMakeRange(0, aString!.length),
            documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd
                                 ,.characterEncoding:String.Encoding.utf8])
        
        if let dir = FileManager.default.urls (for: .documentDirectory, in: .userDomainMask) .first {
            let path_file_name = dir.appendingPathComponent (date_string)
            do {
                try file!.write (to: path_file_name, options: .atomic, originalContentsURL: nil)
            } catch {
                // Error handling
            }
        }
    } catch {
        //Error handling
    }
    
    //2、标记保存的日记中是否含有照片
    guard let aString = aString else{return}
//    DispatchQueue.global(qos: .default).async {
        DataContainerSingleton.sharedDataContainer.diaryDict[date_string]?.containsImage = false
        aString.enumerateAttribute(NSAttributedString.Key.attachment, in: NSRange(location: 0, length: aString.length), options: [], using: { [] (object, range, pointer) in
            if let attachment = object as? NSTextAttachment{
                //如果存在照片
                if let img = attachment.image(forBounds: attachment.bounds, textContainer: nil, characterIndex: range.location){
                    DataContainerSingleton.sharedDataContainer.diaryDict[date_string]?.containsImage = true
                    return
                }
            }
        }
        )
//    }
    
}

//MARK:-根据日期string读取从文件目录富文本
func loadAttributedString(date_string:String) -> NSAttributedString?{
    if let dir = FileManager.default.urls (for: .documentDirectory, in: .userDomainMask) .first {
        let path_file_name = dir.appendingPathComponent (date_string)
        do{
            let aString = try NSAttributedString(
                url: path_file_name,
                options: [.documentType:NSAttributedString.DocumentType.rtfd,
                          .characterEncoding:String.Encoding.utf8],
                documentAttributes: nil)
            return aString
        }catch{
            //
        }
    }
    return nil
}


func leftTypingAttributes() -> [NSAttributedString.Key:Any]{
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .left
    paragraphStyle.lineSpacing = userDefaultManager.lineSpacing
    let typingAttributes:[NSAttributedString.Key:Any] = [
        .paragraphStyle: paragraphStyle,
        .font:userDefaultManager.font
    ]
    return typingAttributes
}
