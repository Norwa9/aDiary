//
//  LWRealmManager.swift
//  日记2.0
//
//  Created by yy on 2021/7/9.
//

import Foundation
import RealmSwift

class LWRealmManager{
    static let shared = LWRealmManager()
    
    ///数据库版本号
    static var schemaVersion:UInt64 = 0
    
    ///唯一的操作对象
    private let realm = getRealm()
    
    /// 获取数据库操作的 Realm
    private static func getRealm() -> Realm {
        
        // 获取数据库文件路径
        let fileURL = URL(string: NSHomeDirectory() + "/Documents/aDiary.realm")
        print("realm url:\(fileURL?.absoluteString)")
        // 在 APPdelegate 中需要配置版本号时，这里也需要配置版本号
        let config = Realm.Configuration(fileURL: fileURL, schemaVersion: schemaVersion)
        
        return try! Realm(configuration: config)
    }
    
    lazy var localDatabase:Results<diaryInfo> = {
       return realm.objects(diaryInfo.self)
    }()
    
    //MARK:-增删查改
    typealias updateBlock = ()->(Void)
    func add(_ diary:diaryInfo){
        do{
            try realm.write(){
                //如果diary已经添加到realm被realm所管理，这个diary不能在write事务block之外修改！
                realm.add(diary,update: .modified)
            }
        }catch let error{
            print("[新增]Realm数据库操作错误：\(error.localizedDescription)")
        }
    }
    
    func update(updateBlock:updateBlock){
        do{
            try realm.write(){
                //如果diary已经添加到realm被realm所管理，这个diary不能在write事务block之外修改！
                updateBlock()
            }
        }catch let error{
            print("[更新]Realm数据库操作错误：\(error.localizedDescription)")
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

//MARK:-LWRealmManager+DiaryInfo
extension LWRealmManager{
    ///更新所有日记的tag
    func updateTagForAll(){
        
    }
}
