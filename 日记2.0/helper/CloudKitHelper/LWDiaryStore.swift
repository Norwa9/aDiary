//
//  LWDiaryStore.swift
//  日记2.0
//
//  Created by 罗威 on 2021/7/6.
//
/*
 SyncEngine提供封装的服务，Store使用这些服务
 */
import Foundation
import Combine
import CloudKit
import os.log

public final class DiaryStore: ObservableObject {
    private(set) var diaries: [diaryInfo] = []

    private let log = OSLog(subsystem: SyncConstants.subsystemName, category: String(describing: DiaryStore.self))

    private let fileManager = FileManager()

    private let queue = DispatchQueue(label: "DiaryStore")

    private let container: CKContainer
    private let defaults: UserDefaults
    private var syncEngine: LWSyncEngine?
    
    init(diaries:[diaryInfo]){
        self.container = CKContainer(identifier: SyncConstants.containerIdentifier)
        
        self.defaults = UserDefaults.standard
        
        if(!diaries.isEmpty){
            self.diaries = diaries
            save()
        }else{
            load()
        }
        
        self.syncEngine = LWSyncEngine(defaults: self.defaults, initialDiaries: self.diaries)
        
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
        os_log("%{public}@", log: log, type: .debug, #function)

        diaries.forEach { updatedDiary in
            guard let idx = self.diaries.firstIndex(where: { $0.id == updatedDiary.id }) else { return }
            self.diaries[idx] = updatedDiary
        }

        save()
    }
    
    func addOrUpdate(_ diary:diaryInfo) {
        if let idx = diaries.lastIndex(where: { $0.id == diary.id }) {
            diaries[idx] = diary
        } else {
            diaries.append(diary)
        }

        syncEngine?.upload(diary)
        save()
    }
    
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
        os_log("%{public}@", log: log, type: .debug, #function)
        
        do {
            let data = try PropertyListEncoder().encode(diaries)
            try data.write(to: storeURL)
        } catch {
            os_log("Failed to save diaries: %{public}@", log: self.log, type: .error, String(describing: error))
        }
    }
    
    private func load() {
        os_log("%{public}@", log: log, type: .debug, #function)
        
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

//MARK:-数组转字典
extension DiaryStore{
    
}
