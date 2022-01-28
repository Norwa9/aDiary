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
    
    //MARK: 保存
    ///保存日记：需要解析attribuedText中的image属性和todo属性
    func parseAttribuedText(diary:diaryInfo)->(
        cleanText:String, // cleanText
        containImage:Bool, // containsImage
        [LWTodoModel], // todoModels
        [ScalableImageModel], // imageModels
        NSAttributedString // attrText
    ){
        let attrText = NSMutableAttributedString(attributedString: self)
        let attrTextForContent = NSMutableAttributedString(attributedString: self)
        var containsImage:Bool = false
        let oldImgModels = diary.scalableImageModels
        var newImgModels = [ScalableImageModel]()
        var todoModels = [LWTodoModel]()
        
        attrText.enumerateAttribute(.attachment, in: NSRange(location: 0, length: attrText.length), options: [], using: { [] (object, range, pointer) in
            let location = range.location
            
            //1.image
            if let subViewAttchemnt = object as? SubviewTextAttachment,
               let view = subViewAttchemnt.view as? ScalableImageView{
                // print("遍历到\(location)处的图片model")
                containsImage = true
                
                let viewModel = view.viewModel
                viewModel.location = location // 更新viewModel的location为保存时刻的location
                let model = viewModel.generateModel()
                newImgModels.append(model)
                
                // 保存时，用默认图像占位，以表示这个location有NSTextAttachment。
                // 这是必要的，否者attrText的长度会不正常
                let attchemnt = NSTextAttachment(image: UIImage(named: "emptyImage.jpg")!)
                attrText.replaceAttchment(attchemnt, attchmentAt: location, with: imageCenterParagraphStyle)
                
                attrTextForContent.replaceCharacters(in: range, with: "P")
                
                // return
            }else if
                let subViewAttchemnt = object as? SubviewTextAttachment,
                let view = subViewAttchemnt.view as? LWTodoView{
                // print("遍历到位置\(location)有一个todo model")
                let viewModel = view.viewModel
                viewModel.location = location // 更新viewModel的location为保存时刻的location
                let model = viewModel.generateModel()
                todoModels.append(model)
                let attchemnt = NSTextAttachment(image: UIImage(named: "emptyImage.jpg")!) // 占位
                attrText.replaceAttchment(attchemnt, attchmentAt: location, with: imageCenterParagraphStyle)
                
                attrTextForContent.replaceCharacters(in: range, with: " ")
            }
        })

        // 编辑日记时，图片只增不减
        // 保存日记时，可以统一地处理图片的删除
        let delUUIDs = arraySub(a1: oldImgModels, a2: newImgModels)
        ImageTool.shared.deleteImages(uuidsToDel: delUUIDs)
 
        let cleanText = attrTextForContent.string
        
        return (
                cleanText,
                containsImage,
                todoModels,
                newImgModels,
                attrText
                )
    }
    
    /// 计算两个数组之差：a1-a2
    /// 旧数组-新数组 = 需要删除的元素
    /// 新数组-旧数组 = 需要新增的元素
    func arraySub(a1:[ScalableImageModel],a2:[ScalableImageModel]) -> [String]{
        let uuids2:[String] = a2.map { model in
            return model.uuid
        }
        var res = [ScalableImageModel]()
        for model in a1{
            if !uuids2.contains(model.uuid){
                res.append(model)
            }
        }
        return res.map { m in
            m.uuid
        }
    }
    
    
    
    
    //MARK: -恢复字体
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
                //UIColor.black替换为UIColor.label
                if let components = color.cgColor.components,components.count == 2,components[0] == 0.0,components[1] == 1.0{
                    print("color == UIColor.black,range:\(range)")
                    mutableAttr.addAttribute(.foregroundColor, value: UIColor.label, range: range)
                }
                //UIColor.white替换为UIColor.label
                if let components = color.cgColor.components,components.count == 2,components[0] == 1.0,components[1] == 1.0{
                    print("color == UIColor.black,range:\(range)")
                    mutableAttr.addAttribute(.foregroundColor, value: UIColor.label, range: range)
                }
                //sRGB的黑色替换为UIColor.label
                if let components = color.cgColor.components,components.count == 4,components[0] == 0.0,components[1] == 0.0,components[2] == 0.0,components[3] == 1.0{
                    print("color == RGB Black,range:\(range)")
                    mutableAttr.addAttribute(.foregroundColor, value: UIColor.label, range: range)
                }
                //sRGB的白色替换为UIColor.label
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

//MARK: -NSAttributedString转Data
extension NSAttributedString {
    func toRTFD()->Data?{
        let rtfd = try? self.data(from: NSMakeRange(0, self.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd,.characterEncoding:String.Encoding.utf8])
        return rtfd
    }
}


//MARK: -NSAttributedString + todo
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



