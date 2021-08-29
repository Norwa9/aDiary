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
                attrText.replaceAttchment(attchemnt, attchmentAt: location,with: centerParagraphStyle)
                
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
    
    
    
    //MARK:-应用用户的编辑器设定
    ///将用户的编辑器属性施加于attrString上
    func addUserDefaultAttributes(lineSpacing:CGFloat = userDefaultManager.lineSpacing) -> NSMutableAttributedString{
        let paraStyle = NSMutableParagraphStyle()
//        paraStyle.alignment = .left
        paraStyle.lineSpacing = lineSpacing
        let attributes: [NSAttributedString.Key:Any] = [
            .font:userDefaultManager.font,
            .paragraphStyle : paraStyle,
            .foregroundColor : UIColor.label,
        ]
        let mutableAttr = NSMutableAttributedString(attributedString: self)
        mutableAttr.addAttributes(attributes, range: NSRange(location: 0, length: mutableAttr.length))
        return mutableAttr
    }
    
    
}

//MARK:-NSAttributedString转Data
extension NSAttributedString {
    func toRTFD()->Data?{
        let rtfd = try? self.data(from: NSMakeRange(0, self.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd,.characterEncoding:String.Encoding.utf8])
        rtfd?.printSize()
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



