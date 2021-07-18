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

    private let queue = DispatchQueue(label: "DiaryStore")

    private let container: CKContainer
    private let defaults: UserDefaults
    private var syncEngine: LWSyncEngine?
    
    //MARK:-init
    private init(){
        self.container = CKContainer(identifier: SyncConstants.containerIdentifier)
        
        self.defaults = UserDefaults.standard
        
        let initialDB = LWRealmManager.shared.localDatabase
        self.syncEngine = LWSyncEngine.init(defaults: self.defaults, initialDiaries: initialDB.toArray())
        
        self.syncEngine?.didUpdateModels = { [weak self] models in
            self?.updateAfterSync(models)
        }

        self.syncEngine?.didDeleteModels = { [weak self] identifiers in
            self?.updateAfterDelete(identifiers)
        }
    }
    
    //MARK:-helper
    ///提交添加或修改到云端
    func addOrUpdate(_ diary:diaryInfo) {
        //在textFormatter中已经实现了更新本地数据库的逻辑
        //展示菊花转
        indicatorViewManager.shared.start(style: .banner)
        //提交更新到云端
        syncEngine?.upload(diary)
    }
    
    ///提交删除到云端
    ///同时更新本地数据库
    public func delete(with id: String) {
        guard let diary = self.diaryWithID(id) else {
            os_log("diary not found with id %@ for deletion.", log: self.log, type: .error, id)
            return
        }
        indicatorViewManager.shared.start(style: .banner)
        //云端删除+本地删除
        syncEngine?.delete(diary)
    }

    ///处理CloudKit发来的更新通知
    public func processSubscriptionNotification(with userInfo: [AnyHashable : Any]) {
        syncEngine?.processSubscriptionNotification(with: userInfo)
    }
    
    ///手动扫描离线修改的数据，然后上传
    public func uploadLocalDataNotUploadedYet(){
        //展示菊花转
        indicatorViewManager.shared.start()
        syncEngine?.uploadLocalDataNotUploadedYet()
    }
    
    ///主动拉取云端变动
    public func fetchRemoteChange(){
        //展示菊花转
        indicatorViewManager.shared.start()
        syncEngine?.fetchRemoteChanges()
    }
    
    ///将获取的云端变动保存到本地，以及更新UI
    private func updateAfterSync(_ diaries:[diaryInfo]){
        if diaries.isEmpty{
            //云端没有更新
            indicatorViewManager.shared.stop()
            return
        }
        os_log("将云端获取的改变（新增/修改）到本地数据库...", log: log, type: .debug)
        //1.将云端变动保存到本地数据库
        diaries.forEach { updatedDiary in
//            let newerModel = diaryInfo.resolveOfflineConflict(serverModel: updatedDiary)
            LWRealmManager.shared.add(updatedDiary)
        }
        //2.
        dataManager.shared.updateAllTagsAfterSync()
        
        
        os_log("云端更新已应用到本地数据库!", log: log, type: .debug)
        DispatchQueue.main.async {
            //2.更新UI
            indicatorViewManager.shared.stop()
            UIApplication.getMonthVC().reloadMonthVC()
            UIApplication.getTodayVC().reloadTodayVC()
            
        }
        
    }
    
    private func updateAfterDelete(_ ids:[String]){
        if ids.isEmpty{
            //云端没有删除
            indicatorViewManager.shared.stop()
            return
        }
        
        //1.删除
        for id in ids{
            let predicate = NSPredicate(format: "id == %@", id)
            LWRealmManager.shared.delete(predicate: predicate)
        }
        
        os_log("云端的删除已应用到本地数据库!", log: log, type: .debug)
        //2.更新UI
        DispatchQueue.main.async {
            indicatorViewManager.shared.stop()
            UIApplication.getMonthVC().reloadMonthVC()
            UIApplication.getTodayVC().reloadTodayVC()
            
        }
    }
}

//MARK:-helper
extension DiaryStore{
    func diaryWithID(_ id:String) -> diaryInfo? {
        return LWRealmManager.shared.localDatabase.filter("id == %@",id).first
    }
}
