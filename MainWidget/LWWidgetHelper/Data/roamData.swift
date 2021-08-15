//
//  roamData.swift
//  日记2.0
//
//  Created by yy on 2021/8/13.
//

import Foundation

struct RoamData{
    let content: String
}

struct RoamDataLoader {
    static func load(completion: @escaping (Result<RoamData, Error>) -> Void){
        let userDefault = UserDefaults.init(suiteName: "group.luowei.prefix.aDiary.content")
        if let content = userDefault?.object(forKey: "roam") as? String{
            let roamData = RoamData(content: content)
            completion(.success(roamData))
        }else{
            let error = NSError(domain: "widget", code: 0, userInfo: nil   )
            completion(.failure(error))
        }
    }
}
