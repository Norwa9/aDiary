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
    
    //MARK: :-init
    private init(){
        self.container = CKContainer(identifier: SyncConstants.containerIdentifier)
        
        self.defaults = UserDefaults.standard
        self.syncEngine = LWSyncEngine.init(defaults: self.defaults)
        
        ImageTool.shared.syncEngine = self.syncEngine // imageTool和DiaryStore共用一个syncEngine
    }
    //MARK: :-public
    ///开始云同步逻辑
    public func startEngine(){
        if userDefaultManager.iCloudEnable == false{
            return
        }
        self.syncEngine?.start()
    }
    
    //MARK: :-新建或修改
    func addOrUpdate(_ diary:diaryInfo) {
        //在textFormatter中已经实现了更新本地数据库的逻辑
        if userDefaultManager.iCloudEnable == false{
            return
        }
        //提交更新到云端
        syncEngine?.upload([diary.record])
    }
    
    /// 上传成功后，更新本地Model的[已上传状态]
    func setUploaded(records: [CKRecord]){
        let diaryDB = LWRealmManager.shared.localDatabase
        for r in records{
            guard let model = diaryDB.first(where: { $0.id == r.recordID.recordName }) else {
                //print("continue")
                continue
            }
            //*赋值ckData，表示该日记已经在云端有副本
            LWRealmManager.shared.update {
                model.editedButNotUploaded = false
                model.ckData = r.encodedSystemFields
            }
        }
        print("[日记]云端上传成功，标记这些日记为已上传。")
    }
    
    //MARK: :-删除
    public func delete(with id: String) {
        guard let diaryToDel = LWRealmManager.shared.queryDiaryWithID(id) else {
            os_log("diary not found with id %@ for deletion.", log: self.log, type: .error, id)
            return
        }
        // 1. 加入待删除列表
        if !userDefaultManager.deleteBufferIDs.contains(id){
            userDefaultManager.deleteBufferIDs.append(id)
        }
        
        // 2. 尝试云端删除（在没有iCloud账户、无网络下可能失败）
        syncEngine?.delete([id],recordType: .diaryInfo)
        
        // 3. 删除附带的图片
        self.clearAllImgs(for: diaryToDel)
        
        // 4. 再本地删除，因为需要引用diary
        let predicate = NSPredicate(format: "id == %@", id)
        LWRealmManager.shared.delete(predicate: predicate)
        
        UIApplication.getMonthVC()?.reloadMonthVC()
    }
    
    ///删除一个日期的主页面和所有子页面
    public func deleteAllPage(withPageID id:String){
        guard let page = LWRealmManager.shared.queryDiaryWithID(id),
              let mainPage = LWRealmManager.shared.queryFor(dateCN: page.trueDate).first
        else {
            os_log("main page not found with id %@ for deletion.", log: self.log, type: .error, id)
            return
        }
        
        let allPages = LWRealmManager.shared.queryAllPages(ofDate: mainPage.trueDate)
        
        for page in allPages{
            print("删除页面：\(page.date)")
            delete(with: page.id)
        }
    }
    
    /// 删除一个页面时，需要手动地删除其内所有图片
    private func clearAllImgs(for page:diaryInfo){
        let siModels = page.scalableImageModels
        let uuids = siModels.map({ m in
            return m.uuid
        })
        print("删除页面： \(page.date) ...内有\(uuids.count)张图片。")
        ImageTool.shared.deleteImages(uuidsToDel: uuids)
    }
    
    /// 删除一个页面时，需要手动地删除其内所有图片
    private func clearAllImgs(for pageID:String){
        guard let page = LWRealmManager.shared.queryDiaryWithID(pageID) else{
            return
        }
        let siModels = page.scalableImageModels
        let uuids = siModels.map({ m in
            return m.uuid
        })
        print("删除页面： \(page.date) ...内有\(uuids.count)张图片。")
        ImageTool.shared.deleteImages(uuidsToDel: uuids)
    }
    
    /// 云端删除成功后，清空diary的待删除队列
    func setDeleted(recordIDs: [CKRecord.ID]?){
        if let ids = recordIDs{
            for id in ids{
                if let index = userDefaultManager.deleteBufferIDs.firstIndex(of: id.recordName){
                    userDefaultManager.deleteBufferIDs.remove(at: index)
                }
            }
            print("[日记]云端删除成功，更新删除队列，此时deleteBufferIDs剩余个数：\(userDefaultManager.deleteBufferIDs.count)")
        }
    }
    
    //MARK: :-响应云端变动
    /// 应用云端的更新到本地
    func updateAfterSync(_ diaries:[diaryInfo]){
        if diaries.isEmpty{
            //云端没有更新
            return
        }
        print("[日记]将云端获取的改变（新增/修改）到本地数据库...")
        //1.将云端变动保存到本地数据库
        diaries.forEach { updatedDiary in
            if let resolvedDiary = diaryInfo.resolveEmptyDiary(serverModel: updatedDiary){
                LWRealmManager.shared.add(resolvedDiary)
            }
        }
        //2.
        dataManager.shared.updateTags()
        
        
        print("[日记]云端更新已应用到本地数据库!")
    }
    
    /// 应用云端的删除到本地
    func updateAfterDelete(_ deletedIDs:[String]){
        if deletedIDs.isEmpty{
            //云端通知没有删除事件
            return
        }
        
        //1.删除
        for id in deletedIDs{
            // 先删除imgModel
            self.clearAllImgs(for: id)
            
            // 再删除diaryModel
            let predicate = NSPredicate(format: "id == %@", id)
            LWRealmManager.shared.delete(predicate: predicate)
            
            //假设设备A通知设备B删除x，且设备B在离线时也删除了日记x，那么设备B就把x从自己的待删除列表中移除
            if let index = userDefaultManager.deleteBufferIDs.firstIndex(of: id){
                userDefaultManager.deleteBufferIDs.remove(at: index)
            }
        }
        
        print("[日记]云端的删除已应用到本地数据库!")
    }
    
    //MARK: :-处理CloudKit发来的更新通知
    public func processSubscriptionNotification(with userInfo: [AnyHashable : Any]) {
        if userDefaultManager.iCloudEnable == false{
            return
        }
        syncEngine?.processSubscriptionNotification(with: userInfo)
    }
}
