//
//  NSAttrString_Extension.swift
//  日记2.0
//
//  Created by 罗威 on 2021/4/12.
//

import Foundation
import UIKit
import SubviewAttachingTextView

extension NSAttributedString{
    
    //MARK:解析
    ///存储时解析attribuedText中的image属性和todo属性
    /*返回值：
     (imageAttrTuples, todoAttrTuples, incompletedTodos, completedTodos, allTodos, cleanText, containsImage)
     */
    func parseAttribuedText()->([(Int,Int)],[(Int,Int)],cleanText:String,containImage:Bool,[String],[String],[String],[ScalableImageModel],NSAttributedString){
        let attrText = NSMutableAttributedString(attributedString: self)
        var attrTextForContent = NSMutableAttributedString(attributedString: self)
        var containsImage:Bool = false
        var imageAttrTuples = [(Int,Int)]()
        var scalableImageModels = [ScalableImageModel]()
        var todoAttrTuples = [(Int,Int)]()
        var incompletedTodos = [String]()
        var completedTodos = [String]()
        var allTodos = [String]()
        
        attrText.enumerateAttribute(.attachment, in: NSRange(location: 0, length: attrText.length), options: [], using: { [] (object, range, pointer) in
            let location = range.location
            
            //1.image
            if let subViewAttchemnt = object as? SubviewTextAttachment,let view = subViewAttchemnt.view as? ScalableImageView{
                //print("扫描到subViewAttchemnt，下标:\(location)")
                let viewModel = view.viewModel
                viewModel.location = location//更新viewModel的location为保存时刻的location
                let model = viewModel.generateModel()
                scalableImageModels.append(model)
                //print("添加model:\(scalableImageModels.count)")
                
                //3.将view重新替换成imageAttchmen
                //bounds也要设置好来，否者重新塞入属性文本后，image的方向不对.
                let attchemnt = NSTextAttachment(image: viewModel.image ?? #imageLiteral(resourceName: "imageplaceholder"),size: viewModel.bounds.size)
                attrText.replaceAttchment(attchemnt, attchmentAt: location,with: imageCenterParagraphStyle)
                
                attrTextForContent.replaceCharacters(in: range, with: "P")
                
                containsImage = true
                
                imageAttrTuples.append((location,1))
                
                return
            }
            
            
            
            //2.todo
            if let todoAttrValue = attrText.attribute(.todo, at: location, effectiveRange: nil) as? Int{
                let checked = (todoAttrValue == 1)
                let lineRange = attrText.mutableString.paragraphRange(for: range)
                let todo = attrText.attributedSubstring(from: lineRange).string
                if(checked){
                    completedTodos.append(todo)
                }else{
                    incompletedTodos.append(todo)
                }
                allTodos.append(todo)
                
                //print("存储时扫描到todo:\(range),\(checked)")
                todoAttrTuples.append((location,todoAttrValue))
            }
        })
        
        //print("attrText的长度:\(attrText.length)")
        //print("imageAttrTuples:\(imageAttrTuples)")
        
        //print("存储images:\(imageAttrTuples)")
        //print("存储todos:\(todoAttrTuples)")
        let cleanText =  attrTextForContent.string
        return (imageAttrTuples, todoAttrTuples, cleanText, containsImage, incompletedTodos, completedTodos, allTodos,scalableImageModels,attrText)
        
    }
    
    
    
    //MARK:-恢复字体
    ///重新选取字体后，需要将旧有的[粗体]和[斜体]重新赋给新字体
    func restoreFontStyle() -> NSMutableAttributedString{
        let mutableAttr = NSMutableAttributedString(attributedString: self)
        let allRange = NSRange(location: 0, length: mutableAttr.length)
        //1.恢复字体
        mutableAttr.enumerateAttribute(.font, in: allRange, options: []) { (objcet, range, stop) in
            if let prevFont = objcet as? UIFont{
                let newFont = prevFont.copyFontTraitsToNewSelectedFont()
                mutableAttr.addAttribute(.font, value: newFont, range: range)
            }
        }
        
        //2.查找black色字体并替换成label色以适配深色模式
        mutableAttr.enumerateAttribute(.foregroundColor, in: allRange, options: []) { (object, range, stop) in
            if let color = object as? UIColor{
//                print("color.cgColor:\(color.cgColor)")
//                print("color.cgColor.colorSpace:\(color.cgColor.colorSpace)")
                print("color.cgColor.components:\(color.cgColor.components),range:\(range)")
//                print("forgroudcolor:\(color.description), range:\(range)")
                //黑色替换为label色
                if let components = color.cgColor.components,components.count == 2,components[0] == 0.0,components[1] == 1.0{
                    print("color == UIColor.black,range:\(range)")
                    mutableAttr.addAttribute(.foregroundColor, value: UIColor.label, range: range)
                }
                //白色替换为label色
                if let components = color.cgColor.components,components.count == 2,components[0] == 1.0,components[1] == 1.0{
                    print("color == UIColor.black,range:\(range)")
                    mutableAttr.addAttribute(.foregroundColor, value: UIColor.label, range: range)
                }
                //sRGB的黑色
                if let components = color.cgColor.components,components.count == 4,components[0] == 0.0,components[1] == 0.0,components[2] == 0.0,components[3] == 1.0{
                    print("color == RGB Black,range:\(range)")
                    mutableAttr.addAttribute(.foregroundColor, value: UIColor.label, range: range)
                }
                if let components = color.cgColor.components,components.count == 4,components[0] == 1.0,components[1] == 1.0,components[2] == 1.0,components[3] == 1.0{
                    print("color == RGB White,range:\(range)")
                    mutableAttr.addAttribute(.foregroundColor, value: UIColor.label, range: range)
                }
            }
        }
        
        //3.恢复行间距
        mutableAttr.enumerateAttribute(.paragraphStyle, in: allRange, options: []) { (object, range, stop) in
            if let paraStyle = object as? NSParagraphStyle{
                let newParaSyle = NSMutableParagraphStyle()
                newParaSyle.alignment = paraStyle.alignment
                newParaSyle.lineSpacing = userDefaultManager.lineSpacing
                mutableAttr.addAttribute(.paragraphStyle, value: newParaSyle, range: range)
            }
        }
        
        return mutableAttr
    }
    
    
}

//MARK:-NSAttributedString转Data
extension NSAttributedString {
    func toRTFD()->Data?{
        let rtfd = try? self.data(from: NSMakeRange(0, self.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd,.characterEncoding:String.Encoding.utf8])
        return rtfd
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



