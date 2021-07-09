//
//  LWRealmManager.swift
//  日记2.0
//
//  Created by yy on 2021/7/9.
//

import Foundation
import RealmSwift

class LWRealManager{
    ///数据库版本号
    static var schemaVersion:UInt64 = 0
    
    ///唯一的操作对象
    static let LWRealm = realm()
    
    /// 获取数据库操作的 Realm
    private static func realm() -> Realm {
        
        // 获取数据库文件路径
        let fileURL = URL(string: NSHomeDirectory() + "/Documents/aDiary.realm")
        print(fileURL)
        // 在 APPdelegate 中需要配置版本号时，这里也需要配置版本号
        let config = Realm.Configuration(fileURL: fileURL, schemaVersion: schemaVersion)
        
        return try! Realm(configuration: config)
    }
}
