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
    func extractImages()-> [UIImage] {
        //获取富文本attributedString
        guard let date_string = diary.date else{return []}
        guard let aString = self.loadAttributedString(date_string: date_string) else{return []}
        
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
        //标记这篇日记有图片
        
        return images
    }
    
    
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
    
    //如果diary的containsImage属性为nil（即未初始化），
    //则调用该函数手动更新，检查、更新该日记是否有图片
    func checkifcontainsImage()->Bool{
        guard let date_string = diary.date else {
            return false
        }
        var attrString:NSAttributedString?
        var containsImage:Bool!
        if let dir = FileManager.default.urls (for: .documentDirectory, in: .userDomainMask) .first {
            let path_file_name = dir.appendingPathComponent (date_string)
            do{
                attrString = try NSAttributedString(
                    url: path_file_name,
                    options: [.documentType:NSAttributedString.DocumentType.rtfd,
                              .characterEncoding:String.Encoding.utf8],
                    documentAttributes: nil)
                
            }catch{
                //
            }
        }
        guard let aString = attrString else{return false}
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
