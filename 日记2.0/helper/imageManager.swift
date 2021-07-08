//
//  imageManager.swift
//  日记2.0
//
//  Created by 罗威 on 2021/4/23.
//

import Foundation
import UIKit

class imageManager{
    var diary:diaryInfo
    
    init(diary:diaryInfo) {
        self.diary = diary
    }
    
    
    
    //读取日记的所有插图
    func extractImages(callback: @escaping (_ images:[UIImage],_ diary:diaryInfo)->()) {
        DispatchQueue.global(qos: .default).async {[self] in
            //获取富文本attributedString
            guard let aString = diary.attributedString else{return}
            var images:[UIImage] = []
            aString.enumerateAttribute(NSAttributedString.Key.attachment, in: NSRange(location: 0, length: aString.length), options: [], using: { [] (object, range, pointer) in
                if let attachment = object as? NSTextAttachment{
                    if let img = attachment.image(forBounds: attachment.bounds, textContainer: nil, characterIndex: range.location){
                        let ratio = img.size.height / monthCell.KphotoHeight
                        let size = CGSize(width: img.size.width / ratio, height: monthCell.KphotoHeight)
                        let compressedImage = img.compressPic(toSize: size)
                        images.append(compressedImage)
                    }
                }
            }
            )
            DispatchQueue.main.async {
                callback(images,self.diary)
            }
        }
        
        //标记这篇日记有图片
        
    }
    
    //如果diary的containsImage属性为nil（即未初始化），
    //则调用该函数手动更新，检查、更新该日记是否有图片
    func checkifcontainsImage()->Bool{
        let date_string = diary.date
        
        var containsImage:Bool!
        guard let aString = diary.attributedString else{return false}
        containsImage = false
        aString.enumerateAttribute(NSAttributedString.Key.attachment, in: NSRange(location: 0, length: aString.length), options: [], using: { [] (object, range, pointer) in
            if let attachment = object as? NSTextAttachment{
                //如果存在照片
                if let _ = attachment.image(forBounds: attachment.bounds, textContainer: nil, characterIndex: range.location){
                    containsImage = true
                    return
                }
            }
        }
        )
        DataContainerSingleton.sharedDataContainer.diaryDict[date_string]?.containsImage = containsImage
        return containsImage
    }
    
    
}
