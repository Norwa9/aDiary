//
//  LWRealmManager.swift
//  日记2.0
//
//  Created by yy on 2021/7/9.
//

import Foundation
import RealmSwift

class LWRealmManager{
    static let realmManager = LWRealmManager()
    
    ///数据库版本号
    static var schemaVersion:UInt64 = 0
    
    ///唯一的操作对象
    private let realm = realm()
    
    /// 获取数据库操作的 Realm
    private static func realm() -> Realm {
        
        // 获取数据库文件路径
        let fileURL = URL(string: NSHomeDirectory() + "/Documents/aDiary.realm")
        print(fileURL)
        // 在 APPdelegate 中需要配置版本号时，这里也需要配置版本号
        let config = Realm.Configuration(fileURL: fileURL, schemaVersion: schemaVersion)
        
        return try! Realm(configuration: config)
    }
    
    //MARK:-增删查改
    func addOrUpdate(_ diary:diaryInfo){
        do{
            try realm.write(){
                //如果存在更新发生变动的属性，如果不存在则新建一个记录。
                //前提是要设置主键
                realm.add(diary,update: .modified)
            }
        }catch let error{
            print("[添加或更新]Realm数据库操作错误：\(error.localizedDescription)")
        }
    }
    
    func delete(_ diary:diaryInfo){
        do{
            try realm.write(){
                realm.delete(diary)
            }
        }catch let error{
            print("[删除]Realm数据库操作错误：\(error.localizedDescription)")
        }
    }
    
    func query(predicate:NSPredicate)->Results<diaryInfo>{
        let res = realm.objects(diaryInfo.self).filter(predicate)
        return res
    }
}
