//
//  LWDiaryStore.swift
//  日记2.0
//
//  Created by 罗威 on 2021/7/6.
//

import Foundation
import Combine
import CloudKit
import os.log
import RealmSwift

/*
 日记存储器
 SyncEngine提供封装的服务，存储器则使用这些服务
 */
public final class DiaryStore: ObservableObject {
    static let shared:DiaryStore = DiaryStore()
    private let localDB = LWRealmManager.shared.localDatabase

    private let log = OSLog(subsystem: SyncConstants.subsystemName, category: String(describing: DiaryStore.self))

    private let fileManager = FileManager()

    private let queue = DispatchQueue(label: "DiaryStore")

    private let container: CKContainer
    private let defaults: UserDefaults
    private var syncEngine: LWSyncEngine?
    
    private init(){
        self.container = CKContainer(identifier: SyncConstants.containerIdentifier)
        
        self.defaults = UserDefaults.standard
        
        let initialDB = LWRealmManager.shared.localDatabase
        self.syncEngine = LWSyncEngine.init(defaults: self.defaults, initialDiaries: initialDB.toArray())
        
        self.syncEngine?.didUpdateModels = { [weak self] diaries in
            self?.updateAfterSync(diaries)
        }

        self.syncEngine?.didDeleteModels = { [weak self] identifiers in
            for id in identifiers{
                let predicate = NSPredicate(format: "id == %@", id)
                LWRealmManager.shared.delete(predicate: predicate)
            }
        }
    }
    
    ///本地数据库plist的url
    private var storeURL:URL{
        let baseURL: URL
        if let dir = FileManager.default.urls (for: .documentDirectory, in: .userDomainMask) .first {
            baseURL = dir
        }else{
            os_log("无法获取用户文件目录URL", log: self.log, type: .fault)
            baseURL = fileManager.temporaryDirectory
        }

        let url = baseURL.appendingPathComponent (DefaultsKeys.DiaryDictPlistKey)

        if !fileManager.fileExists(atPath: url.path) {
            os_log("创建本地数据库(plist文件):%@", log: self.log, type: .debug, url.path)

            if !fileManager.createFile(atPath: url.path, contents: nil, attributes: nil) {
                os_log("创建本地数据库失败:%@", log: self.log, type: .fault, url.path)
            }
        }

        return url
    }
    
    private func updateAfterSync(_ diaries:[diaryInfo]){
        os_log("将云端获取的数据应用到本地数据库...", log: log, type: .debug)
  
        diaries.forEach { updatedDiary in
            //修改的记录同步到本地数据库
            //如果是修改，自动更新，如果是增加，则本地数据库自动新增一个记录
            LWRealmManager.shared.add(updatedDiary)
        }
    }
    
    ///提交添加或修改到云端
    func addOrUpdate(_ diary:diaryInfo) {
        //在textFormatter中已经实现了更新本地数据库的逻辑
        
        //提交更新到云端
        syncEngine?.upload(diary)
        
        
    }
    
    ///提交删除到云端
    ///同时更新本地数据库
    public func delete(with id: String) {
        guard let diary = self.diary(with: id) else {
            os_log("diary not found with id %@ for deletion.", log: self.log, type: .error, id)
            return
        }

        syncEngine?.delete(diary)
        
        //TODO:-保存到本地数据库
    }
    
    func diary(with id: String) -> diaryInfo? {
        return LWRealmManager.shared.localDatabase.filter("id == %@",id).first
    }
    
    public func processSubscriptionNotification(with userInfo: [AnyHashable : Any]) {
        syncEngine?.processSubscriptionNotification(with: userInfo)
    }
}
