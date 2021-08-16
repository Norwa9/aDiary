//
//  roamData.swift
//  日记2.0
//
//  Created by yy on 2021/8/13.
//

import Foundation

struct WidgetKindKeys {
    static let RoamWidget = "RoamWidget"
}

struct RoamData:Codable{
    let date : String
    let content: String
}

struct RoamDataLoader {
    static func load(completion: @escaping (Result<RoamData, Error>) -> Void){
        let defaults = UserDefaults.init(suiteName: "group.luowei.prefix.aDiary.content")!
        let error = NSError(domain: "widget", code: 0, userInfo: nil   )
        
        if let savedRoamData = defaults.object(forKey: WidgetKindKeys.RoamWidget) as? Data {
            let jsonDecoder = JSONDecoder()
            do {
               let roamData = try jsonDecoder.decode(RoamData.self, from: savedRoamData)
                completion(.success(roamData))
            } catch {
                completion(.failure(error))
                print("Failed to decode roamData")
            }
        }else{
            completion(.failure(error))
            print("Failed to load savedRoamData")
        }
    }
}
