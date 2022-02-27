//
//  todoData.swift
//  日记2.0
//
//  Created by 罗威 on 2022/2/16.
//

import Foundation


struct todoData:Codable,Identifiable{
    let id : String
    let state : Int
    let content: String
    let dateBelongs : String
    let remindDate:Date
    let needRemind:Bool
}

struct TodoDataLoader {
    static func load(completion: @escaping (Result<[todoData], Error>) -> Void){
        guard let defaults = UserDefaults.init(suiteName: "group.luowei.prefix.aDiary.content") else{
            print("Failed to init defaults ")
            // 使用之前先给extension的target添加app groups 的capability
            // 且suiteName必须是group id
            return
        }
        
        let error = NSError(domain: "widget", code: 0, userInfo: nil   )
        if let savedData = defaults.object(forKey: WidgetKindKeys.todoWidget) as? Data {
            let jsonDecoder = JSONDecoder()
            do {
               let todoDataArray = try jsonDecoder.decode([todoData].self, from: savedData)
                completion(.success(todoDataArray))
            } catch {
                completion(.failure(error))
                print("Failed to decode json")
            }
        }else{
            completion(.failure(error))
            print("Failed to load userDefaults")
        }
        
    }
}

