//
//  diaryInfo+Todo.swift
//  日记2.0
//
//  Created by yy on 2021/7/21.
//

import Foundation
import UIKit

//MARK:-dairyInfo + todo
enum todoType:Int{
    case unchecked = 0//已完成
    case checked = 1//未完成
    case all = 2//全部
}

//MARK:-getter属性
extension diaryInfo{
    var todos:[String]{
        get {
          return realmTodos.map { $0.stringValue }
        }
        set {
            realmTodos.removeAll()
            realmTodos.append(objectsIn: newValue.map({ RealmString(value: [$0]) }))
        }
    }
    
    ///从json字符串里解析出ScalableImageModel数组
    var lwTodoModels:[LWTodoModel]{
        get{
            let jsonString = todoModelsJSON
            if let models = NSArray.yy_modelArray(with: LWTodoModel.self, json:jsonString ) as? [LWTodoModel]{
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
            let jsonEncoder = JSONEncoder()
            if let modelsData = try? jsonEncoder.encode(newValue) {
                todoModelsJSON = String(data: modelsData, encoding: String.Encoding.utf8)!
                // print("todoModelsJSON:\(todoModelsJSON)")
            } else {
                print("Failed to Encode models")
                todoModelsJSON = ""
            }
        }
    }
}
