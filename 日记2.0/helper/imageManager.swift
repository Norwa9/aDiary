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
        //在后台线程访问了diary将会导致崩溃，必须在创建该变量的线程之外使用该变量
        //解决办法，创建临时变量
        let rtfd = diary.rtfd
        let imageAttrTuples = diary.imageAttributesTuples
        let photoHeight = layoutParasManager.shared.albumViewItemHeight
        DispatchQueue.global(qos: .default).async {[self] in
            //获取富文本attributedString
            guard let aString = LoadRTFD(rtfd: rtfd) else{return}
            var images:[UIImage] = []
            for imageTuple in imageAttrTuples{
                let location = imageTuple.0
                //print("imageTuple location :\(location)")
                if location < aString.length, let attachment = aString.attribute(.attachment, at: location, effectiveRange: nil) as? NSTextAttachment,let img = attachment.image(forBounds: attachment.bounds, textContainer: nil, characterIndex: location){
                    let ratio = img.size.height / photoHeight
                    let size = CGSize(width: img.size.width / ratio, height: photoHeight)
                    let compressedImage = img.compressPic(toSize: size)
                    images.append(compressedImage)
                }
            }
            DispatchQueue.main.async {
                callback(images,self.diary)
            }
        }
    }
    
    
}
