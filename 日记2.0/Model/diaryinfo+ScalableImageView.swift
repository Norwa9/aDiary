//
//  diary+ScalableImageView.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/25.
//

import Foundation
import UIKit
import RealmSwift



extension diaryInfo{
    ///从json字符串里解析出ScalableImageModel数组
    var scalableImageModels:[ScalableImageModel]{
        get{
            let jsonString = mood
            if let models = NSArray.yy_modelArray(with: ScalableImageModel.self, json:jsonString ) as? [ScalableImageModel]{
                return models
            }else{
                return []
            }
        }
        set{
            let jsonEncoder = JSONEncoder()
            if let modelsData = try? jsonEncoder.encode(newValue) {
                mood = String(data: modelsData, encoding: String.Encoding.utf8)!
            } else {
                print("Failed to Encode models")
                mood = ""
            }
        }
    }
}
