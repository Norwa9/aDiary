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

/*
 日记存储器
 SyncEngine提供封装的服务，存储器则使用这些服务
 */
public final class DiaryStore: ObservableObject {
    static let shared:DiaryStore = DiaryStore()
    private(set) var diaries: [diaryInfo] = []

    private let log = OSLog(subsystem: SyncConstants.subsystemName, category: String(describing: DiaryStore.self))

    private let fileManager = FileManager()

    private let queue = DispatchQueue(label: "DiaryStore")

    private let container: CKContainer
    private let defaults: UserDefaults
    private var syncEngine: LWSyncEngine?
    
    private init(){
        self.container = CKContainer(identifier: SyncConstants.containerIdentifier)
        
        self.defaults = UserDefaults.standard
        
        
        let locolDiaries = Array(DataContainerSingleton.sharedDataContainer.diaryDict.values)
        
        /*
         diaryDict才是UI的数据源(DataContainerSingleton.sharedDataContainer.diaryDict)
         diaries是数据库，只充当数据源和云端数据的中介
         
         也就是说，每次diaries变动，要及时更新给diaryDict以更新UI
         为什么这么蛋疼：因为Cloudkit的代码逻辑是抄自别人的：别人用数组做数据源和数据库，而我用字典做数据源数组做数据库，需要一个中介来转换。。。
         */
        self.diaries = locolDiaries
        
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
            //修改、新增同步到数据源
            DataContainerSingleton.sharedDataContainer.diaryDict[updatedDiary.date] = updatedDiary
            
            //修改的记录同步到本地数据库
            if let idx = self.diaries.firstIndex(where: { $0.id == updatedDiary.id }){
                self.diaries[idx] = updatedDiary
            }
            //新增的记录同步到本地数据库
            else{
                self.diaries.append(updatedDiary)
            }
        }

        save()
    }
    
    ///提交添加或修改到云端
    ///同时更新本地数据库
    func addOrUpdate(_ diary:diaryInfo) {
        if let idx = diaries.lastIndex(where: { $0.id == diary.id }) {
            //修改
            diaries[idx] = diary
        } else {
            //添加
            diaries.append(diary)
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
        os_log("save()", log: log, type: .debug, #function)
        
        do {
            let data = try PropertyListEncoder().encode(diaries)
            try data.write(to: storeURL)
        } catch {
            os_log("Failed to save diaries: %{public}@", log: self.log, type: .error, String(describing: error))
        }
    }
    
    private func load() {
        os_log("读取", log: log, type: .debug, #function)
        
        do {
            let data = try Data(contentsOf: storeURL)

            guard !data.isEmpty else { return }

            self.diaries = try PropertyListDecoder().decode([diaryInfo].self, from: data)
        } catch {
            os_log("Failed to load diaries: %{public}@", log: self.log, type: .error, String(describing: error))
        }
    }
    
    public func processSubscriptionNotification(with userInfo: [AnyHashable : Any]) {
        syncEngine?.processSubscriptionNotification(with: userInfo)
    }
}
