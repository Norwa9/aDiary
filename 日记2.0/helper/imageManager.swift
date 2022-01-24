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
        let models = diary.scalableImageModels
        
        // print("diary.date:\(diary.date),models.count:\(models.count)")
        var images:[UIImage] = []
        for model in models {
            let uuid = model.uuid
            // print("读取日记插图：\(uuid)")
            // print("uuid:\(uuid)")
            if let img = ImageTool.shared.loadImage(uuid: uuid){
                images.append(img.resizeToFitCell())
            }else{
                print("loadImage faild")
            }
        }
        // print("extractImages num:\(images.count)")
        callback(images,self.diary)
    }
}
