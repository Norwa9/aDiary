//
//  NSAttrString_Extension.swift
//  日记2.0
//
//  Created by 罗威 on 2021/4/12.
//

import Foundation
import UIKit

extension NSAttributedString{
    
    //MARK:解析
    ///存储时解析attribuedText中的image属性和todo属性
    func parseAttribuedText()->([(Int,Int)],[(Int,Int)],cleanText:String,containImage:Bool){
        let attrText = NSMutableAttributedString(attributedString: self)
        var containsImage:Bool = false
        var imageAttrTuples = [(Int,Int)]()
        var todoAttrTuples = [(Int,Int)]()
        
        attrText.enumerateAttribute(.attachment, in: NSRange(location: 0, length: attrText.length), options: [], using: { [] (object, range, pointer) in
            let location = range.location
            
            //1.image
            if let imageAttrValue = attrText.attribute(.image, at: location, effectiveRange: nil) as? Int{
                print("存储时扫描到imgae:\(range)")
                //1.记录
                imageAttrTuples.append((location,imageAttrValue))
                
                //2.为了正则表达式匹配，将图片替换成占位符"P"。
                attrText.replaceCharacters(in: range, with: "P")
                
                containsImage = true
            }
            
            //2.todo
            if let todoAttrValue = attrText.attribute(.todo, at: location, effectiveRange: nil) as? Int{
                let checked = (todoAttrValue == 1) ? "打钩":"没打钩"
                print("存储时扫描到todo:\(range),\(checked)")
                todoAttrTuples.append((location,todoAttrValue))
            }
        })
        
        let cleanText = attrText.string
        
        print("存储images:\(imageAttrTuples)")
        print("存储todos:\(todoAttrTuples)")
        return (imageAttrTuples,todoAttrTuples,cleanText,containsImage)
        
    }
    
    ///读取富文本，并为图片附件设置正确的大小、方向
    ///textViewScreenshot
    ///loadTextViewContent(with:)
    func processAttrString(bounds:CGRect,container:NSTextContainer,imageAttrTuples:[(Int,Int)],todoAttrTuples:[(Int,Int)])->NSMutableAttributedString{
        
        let mutableText = NSMutableAttributedString(attributedString: self)
        
        //1、施加用户自定义格式
        let attrText = mutableText.addUserDefaultAttributes()
        
        //2.恢复.image格式
        for tuple in imageAttrTuples{
            let location = tuple.0//attribute location
            let value = tuple.1//attribute value
            if let attchment = attrText.attribute(.attachment, at: location, effectiveRange: nil) as? NSTextAttachment,let image = attchment.image(forBounds: bounds, textContainer: container, characterIndex: location){
                
                print("读取时处理到到图片:\(location)")
                
                //1.重新添加attribute
                attrText.addAttribute(.image, value: value, range: NSRange(location: location, length: 1))
                
                //2.调整图片bounds
                let aspect = image.size.width / image.size.height
                let pedding:CGFloat = 15
                let newWidth = (bounds.width - 2 * pedding) / userDefaultManager.imageScalingFactor
                let newHeight = (newWidth / aspect)
                let para = NSMutableParagraphStyle()
                para.alignment = .center
                attrText.addAttribute(.paragraphStyle, value: para, range: NSRange(location: location, length: 1))
                attchment.bounds = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
            }
        }
        
        //TODO:3.恢复todo
        for tuple in todoAttrTuples{
            let location = tuple.0//attribute location
            let value = tuple.1//attribute value
            if let attachment = attrText.attribute(.attachment, at: location, effectiveRange: nil) as? NSTextAttachment{
                print("读取时处理到到todo:\(location)")
                //1.重新添加attribute
                attrText.addAttribute(.todo, value: value, range: NSRange(location: location, length: 1))
                
                //2.调整bounds大小
                let font = userDefaultManager.font
                let size = font.pointSize + font.pointSize / 2
                attachment.bounds = CGRect(x: CGFloat(0), y: (font.capHeight - size) / 2, width: size, height: size)
            }
            
        }
        
        
        
        return attrText
    }
    
    //MARK:-应用用户的编辑器设定
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
    
    
}

//MARK:-NSAttributedString转Data
extension NSAttributedString {
    func data()->Data?{
        return try? self.data(from: NSMakeRange(0, self.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd,.characterEncoding:String.Encoding.utf8])
    }
}


//MARK:-NSAttributedString + todo
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

//MARK:-add attribute
extension NSAttributedString{
    func addStrikethroughStyle()->NSMutableAttributedString{
        let mutableAttrString = NSMutableAttributedString(attributedString: self)
        let range = NSRange(location: 0, length: self.length)
        mutableAttrString.addAttribute(.strikethroughStyle, value: 1, range: range)
        return mutableAttrString
    }
    
    func removeStrikethroughStyle()->NSMutableAttributedString{
        let mutableAttrString = NSMutableAttributedString(attributedString: self)
        let range = NSRange(location: 0, length: self.length)
        mutableAttrString.removeAttribute(.strikethroughStyle, range: range)
        return mutableAttrString
    }
}


