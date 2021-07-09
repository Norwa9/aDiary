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
    private var diaries: [diaryInfo] = []

    private let log = OSLog(subsystem: SyncConstants.subsystemName, category: String(describing: DiaryStore.self))

    private let fileManager = FileManager()

    private let queue = DispatchQueue(label: "DiaryStore")

    private let container: CKContainer
    private let defaults: UserDefaults
    private var syncEngine: LWSyncEngine?
    
    private init(){
        self.container = CKContainer(identifier: SyncConstants.containerIdentifier)
        
        self.defaults = UserDefaults.standard
        
        self.diaries = LWRealmManager.shared.localDatabase.toArray()
        
        //创建的同时
        self.syncEngine = LWSyncEngine.init(defaults: self.defaults, initialDiaries: self.diaries)
        
        self.syncEngine?.didUpdateModels = { [weak self] diaries in
            self?.updateAfterSync(diaries)
        }

        self.syncEngine?.didDeleteModels = { [weak self] identifiers in
            self?.diaries.removeAll(where: { identifiers.contains($0.id) })
            self?.save()
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
        os_log("开始更新本地数据库...", log: log, type: .debug)
        /*
         TODO:
         1.更新diaryDict，因为它才是UI的数据源！
         2.更新UI,reloadData：DiaryStore新增一个闭包属性，用来定义更新行为
        */
        diaries.forEach { updatedDiary in
            //修改的记录同步到本地数据库
            LWRealmManager.shared.update {
                if let idx = self.diaries.firstIndex(where: { $0.date == updatedDiary.date
                }){
                    self.diaries[idx] = updatedDiary
                }
                //新增的记录同步到本地数据库
                else{
                    self.diaries.append(updatedDiary)
                }
            }
        }

        save()
    }
    
    ///提交添加或修改到云端
    ///同时更新本地数据库
    func addOrUpdate(_ diary:diaryInfo) {
        LWRealmManager.shared.update {
            if let idx = diaries.lastIndex(where: { $0.id == diary.id }) {
                //修改
                diaries[idx] = diary
            } else {
                //添加
                diaries.append(diary)
            }
        }

        syncEngine?.upload(diary)
        save()
    }
    
    ///提交删除到云端
    ///同时更新本地数据库
    public func delete(with id: String) {
        guard let diary = self.diary(with: id) else {
            os_log("diary not found with id %@ for deletion.", log: self.log, type: .error, id)
            return
        }

        syncEngine?.delete(diary)
        save()
    }
    
    func diary(with id: String) -> diaryInfo? {
        diaries.first(where: { $0.id == id })
    }
    
    private func save() {
        print("尚未实现本地数据库")
        return
        os_log("正在数据库保存到本地磁盘...", log: log, type: .debug, #function)
//
//        do {
//            let data = try PropertyListEncoder().encode(diaries)
//            try data.write(to: storeURL)
//        } catch {
//            os_log("Failed to save diaries: %{public}@", log: self.log, type: .error, String(describing: error))
//        }
        os_log("保存数据库成功！", log: log, type: .debug, #function)
    }
    
    private func load() {
        print("尚未实现本地数据库")
        return
        os_log("读取", log: log, type: .debug, #function)
        
//        do {
//            let data = try Data(contentsOf: storeURL)
//
//            guard !data.isEmpty else { return }
//
//            self.diaries = try PropertyListDecoder().decode([diaryInfo].self, from: data)
//        } catch {
//            os_log("Failed to load diaries: %{public}@", log: self.log, type: .error, String(describing: error))
//        }
    }
    
    public func processSubscriptionNotification(with userInfo: [AnyHashable : Any]) {
        syncEngine?.processSubscriptionNotification(with: userInfo)
    }
}
