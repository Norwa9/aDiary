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
        NSAttributedString, // attrText
        containImage:Bool, // containsImage
        [LWTodoModel], // todoModels
        [ScalableImageModel], // imageModels
        [LWSoundModel]
    ){
        let attrText = NSMutableAttributedString(attributedString: self)
        let attrTextForContent = NSMutableAttributedString(attributedString: self)
        var containsImage:Bool = false
        // images
        let oldImgModels = diary.scalableImageModels
        var newImgModels = [ScalableImageModel]()
        
        // todo
        let oldTodoModels = diary.lwTodoModels
        var newTodoModels = [LWTodoModel]()
        
        // sound
        let oldSoundModels = diary.lwSoundModels
        var newSoundModels = [LWSoundModel]()
        
        
        attrText.enumerateAttribute(.attachment, in: NSRange(location: 0, length: attrText.length), options: [], using: { [] (object, range, pointer) in
            let location = range.location
            
            //1. 持久化image信息
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
                let palceHolderRange = NSRange(location: location, length: 1)
                attrText.replaceCharacters(in: palceHolderRange, with: "P")
                
                print("range:\(range),palceHolderRange:\(palceHolderRange)")
                attrTextForContent.replaceCharacters(in: range, with: " ")
                
                // return
            }else if let subViewAttchemnt = object as? SubviewTextAttachment,
                     let view = subViewAttchemnt.view as? LWTodoView{
                // 2. 持久化todo信息
                let viewModel = view.viewModel
                print("遍历到位置\(location)有一个todo model,内容:\(viewModel.content)")
                viewModel.location = location // 更新viewModel的location为保存时刻的location
                let model = viewModel.generateModel()
                newTodoModels.append(model)
                let palceHolderRange = NSRange(location: location, length: 1)
                attrText.replaceCharacters(in: palceHolderRange, with: "T")
                
                attrTextForContent.replaceCharacters(in: range, with: " ")
            }else if let subViewAttchemnt = object as? SubviewTextAttachment,
                     let view = subViewAttchemnt.view as? LWSoundView{
                // 3. 持久化sound信息
                let viewModel = view.viewModel
                print("遍历到位置\(location)有一个sound model,内容:\(viewModel.uuid)")
                viewModel.location = location // 更新viewModel的location为保存时刻的location
                let model = viewModel.generateModel()
                newSoundModels.append(model)
                let palceHolderRange = NSRange(location: location, length: 1)
                attrText.replaceCharacters(in: palceHolderRange, with: "S")
                
                attrTextForContent.replaceCharacters(in: range, with: " ")
            }
        })

        // 3. 处理image的删除：编辑日记时，图片只增不减，因此保存日记时，可以统一地处理图片的删除
        let delImageUUIDs = arraySub(a1: oldImgModels, a2: newImgModels)
        ImageTool.shared.deleteImages(uuidsToDel: delImageUUIDs)
        
        // 4. 处理todo通知的注销：比对删除掉的todo的uuid，注销它们的通知
        //    todo的注册发生在TodoSettingViewController，因为用户可能在不修改日记的情况下就给todo设置时间
        //    因此保存日记时才处理todo的注册是不妥的。
        self.unregisterRemovedTodo(oldTodoModels: oldTodoModels, newTodoModels: newTodoModels)
        
        // 5. 处理Sound的删除
        let delSoundUUIDs = arraySub(a1: oldSoundModels, a2: newSoundModels)
        LWSoundHelper.shared.deleteSounds(uuidsToDel: delSoundUUIDs)
 
        let cleanText = attrTextForContent.string
        
        return (
                cleanText,
                attrText,
                containsImage,
                newTodoModels,
                newImgModels,
                newSoundModels
                )
    }
    
    /// 计算两个数组之差：a1-a2
    /// 旧数组-新数组 = 需要删除的元素
    /// 新数组-旧数组 = 需要新增的元素
    private func arraySub(a1:[ScalableImageModel],a2:[ScalableImageModel]) -> [String]{
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
    
    private func arraySub(a1:[LWSoundModel],a2:[LWSoundModel]) -> [String]{
        let uuids2:[String] = a2.map { model in
            return model.uuid
        }
        var res = [LWSoundModel]()
        for model in a1{
            if !uuids2.contains(model.uuid){
                res.append(model)
            }
        }
        return res.map { m in
            m.uuid
        }
    }
    
    private func unregisterRemovedTodo(oldTodoModels:[LWTodoModel],newTodoModels:[LWTodoModel]){
        let old = oldTodoModels.map { todoModel in
            return todoModel.uuid
        }
        let new = newTodoModels.map { todoModel in
            return todoModel.uuid
        }
        let deletedUUIDs = Set(old).subtracting(Set(new))
        LWNotificationHelper.shared.unregisterNotification(uuids: Array(deletedUUIDs))
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



