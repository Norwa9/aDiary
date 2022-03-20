//
//  diaryInfo+Sound.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/19.
//

import Foundation
import UIKit


//MARK:-getter属性
extension diaryInfo{
    ///从json字符串里解析出LWSoundModel数组
    var lwSoundModels:[LWSoundModel]{
        get{
            // decode
            let jsonString = soundModelsJSON
            if let models = NSArray.yy_modelArray(with: LWSoundModel.self, json:jsonString ) as? [LWSoundModel]{
//                print("json转models，得到\(models.count)个model")
//                for model in models {
//                    print(model.createdDate)
//                }
                return models
            }else{
                return []
            }
        }
        set{
            // encode
            let jsonEncoder = JSONEncoder()
            if let modelsData = try? jsonEncoder.encode(newValue) {
                soundModelsJSON = String(data: modelsData, encoding: String.Encoding.utf8)!
            } else {
                print("Failed to Encode models")
                soundModelsJSON = ""
            }
        }
    }
}
