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
    let realm = getRealm()
    
    /// 获取数据库操作的 Realm 对象(由主线程创建)
    private static func getRealm() -> Realm {
        // 获取数据库文件路径
        let fileURL = URL(string: NSHomeDirectory() + "/Documents/aDiary.realm")
        // 在 APPdelegate 中需要配置版本号时，这里也需要配置版本号
        let config = Realm.Configuration(fileURL: fileURL, schemaVersion: schemaVersion)
        
        return try! Realm(configuration: config)
    }
    
    ///[主线程创建的Realm实例对象]中查询的所有日记的结果
    lazy var localDatabase:Results<diaryInfo> = {
       return realm.objects(diaryInfo.self)
    }()
    
    ///在调用该函数的线程中重新创建Realm实例，然后用这个实例查询
    ///Realm实例属于当前线程，其他线程不能访问。
    ///例如：Main Thread创建的实例不能再Background Thread中访问！
    static func queryAllDieryOnCurrentThread()->Results<diaryInfo>{
        let realm = getRealm()
        return realm.objects(diaryInfo.self)
    }
    
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
    
    func delete(_ diaries:[diaryInfo]){
        do{
            try realm.write(){
                realm.delete(diaries)
            }
        }catch let error{
            print("[逐个删除]Realm数据库操作错误：\(error.localizedDescription)")
        }
    }
    func delete(predicate:NSPredicate){
        let res = self.query(predicate: predicate)
        do{
            try realm.write(){
                realm.delete(res)
            }
        }catch let error{
            print("[述语批量删除]Realm数据库操作错误：\(error.localizedDescription)")
        }
    }
    
    
}

//MARK:-查询
extension LWRealmManager{
    ///查询
    func query(predicate:NSPredicate)->Results<diaryInfo>{
        let res = realm.objects(diaryInfo.self).filter(predicate)
        return res
    }
    
    ///Date()格式日期查询
    func queryFor(date:Date)->Results<diaryInfo>{
        let dateCN = DateToCNString(date: date)
        let res = self.queryFor(dateCN: dateCN)
        return res
    }
    ///年-月-日格式日期查询
    func queryFor(dateCN:String)->Results<diaryInfo>{
        let predicate = NSPredicate(format: "date = %@", dateCN)
        let res = self.query(predicate: predicate)
        return res
    }
    
    ///通过id查询日记
    func diaryWithID(_ id:String) -> diaryInfo? {
        return LWRealmManager.shared.localDatabase.filter("id == %@",id).first
    }
}

//MARK:-LWRealmManager+DiaryInfo
extension LWRealmManager{
    ///更新所有日记的tag
    func updateTagForAll(){
        
    }
}
