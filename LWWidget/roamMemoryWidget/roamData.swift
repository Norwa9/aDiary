//
//  roamData.swift
//  LWWidgetExtension
//
//  Created by 罗威 on 2022/2/7.
//

import Foundation

struct RoamData:Codable{
    let date : String
    let content: String
    let tags:[String]
    let emojis:[String]
    let imageData: Data?
}

struct RoamDataLoader {
    static func load(completion: @escaping (Result<[RoamData], Error>) -> Void){
        guard let defaults = UserDefaults.init(suiteName: "group.luowei.prefix.aDiary.content") else{
            print("Failed to init defaults ")
            // 使用之前先给extension的target添加app groups 的capability
            // 且suiteName必须是group id
            return
        }
        
        let error = NSError(domain: "widget", code: 0, userInfo: nil   )
        
        if let savedRoamDataArray = defaults.object(forKey: WidgetKindKeys.RoamWidget) as? Data {
            let jsonDecoder = JSONDecoder()
            do {
               let roamDataArray = try jsonDecoder.decode([RoamData].self, from: savedRoamDataArray)
                completion(.success(roamDataArray))
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
