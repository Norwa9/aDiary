//
//  LWSyncEngine.swift
//  日记2.0
//
//  Created by 罗威 on 2021/7/6.
//

import Foundation
import CloudKit
import os.log
import UIKit

final class LWSyncEngine{
    let log = OSLog(subsystem: SyncConstants.subsystemName, category: String(describing: LWSyncEngine.self))
    
    private let defaults:UserDefaults
    
    private(set) lazy var container:CKContainer = {
        CKContainer(identifier: SyncConstants.containerIdentifier)
    }()
    
    private(set) lazy var privateDatabase:CKDatabase = {
        container.privateCloudDatabase
    }()
    
    private(set) lazy var privateSubscriptionId:String = {
        return "\(SyncConstants.customZoneID.zoneName).subscription"
    }()
    
    private var buffer:[diaryInfo]
    
    private let workQueue = DispatchQueue(label: "SyncEngine.Work",qos: .userInitiated)
    
    private let cloudQueue = DispatchQueue(label: "SyncEngine.Cloud",qos: .userInitiated)
    
    private lazy var cloudOperationQueue:OperationQueue = {
       let q = OperationQueue()
        
        q.underlyingQueue = cloudQueue
        q.name = "SyncEngine.Cloud"
        q.maxConcurrentOperationCount = 1
        
        return q
    }()
    
    private lazy var createdCustomZoneKey:String = {
        return "CREATEDZONE-\(SyncConstants.customZoneID.zoneName)"
    }()
    private var createdCustomZone:Bool{
        get{
            return defaults.bool(forKey: createdCustomZoneKey)
        }
        set{
            defaults.set(newValue, forKey: createdCustomZoneKey)
        }
    }
    
    private var createdPrivateSubscriptionKey:String = {
       return "CREATEDSUBDB-\(SyncConstants.customZoneID.zoneName)"
    }()
    private var createdPrivateSubscription:Bool {
        get{
            return defaults.bool(forKey: createdPrivateSubscriptionKey)
        }
        set{
            defaults.set(newValue, forKey: createdPrivateSubscriptionKey)
        }
    }
    
    ///获取云端最新数据后调用，用来更新本地数据
    var didUpdateModels:([diaryInfo]) -> Void = { _ in }
    
    ///删除云端数据后调用，用来更新本地数据
    var didDeleteModels: ([String]) -> Void = { _ in }
    
    init(defaults:UserDefaults,initialDiaries:[diaryInfo]) {
        self.defaults = defaults
        self.buffer = initialDiaries
        
        start()
    }
    
    
    
    //MARK:-初始化
    func start(){
        //1.配置iCloud环境
        prepareCloudEnvironment {[weak self] in
            guard let self = self else{return}
            
            os_log("iCloud环境配置成功！", log: self.log, type: .debug)
            
            //2.同步未上传的本地数据
            self.uploadLocalDataNotUploadedYet()
            //3.获取其他设备向云端提交的变动
            self.fetchRemoteChanges()
            
        }
    }
    
    
    private func prepareCloudEnvironment(then thenBlock:@escaping ()->Void){
        workQueue.async {[weak self] in
            guard let self = self else{return}
            
            //1.创建自定义zone
            self.createCustomZoneIfNeed()
            self.cloudOperationQueue.waitUntilAllOperationsAreFinished()
            guard self.createdCustomZone else{return}
            
            //2.创建对private database的订阅。以监听数据库的变动
            self.createPrivateSubscriptionsIfNeeded()
            self.cloudOperationQueue.waitUntilAllOperationsAreFinished()
            guard self.createdPrivateSubscription else{return}
            
            DispatchQueue.main.async {
                //然后进行下一步配置
                thenBlock()
            }
            
            
        }
    }
    
    
    //MARK:-检查&创建自定义zone
    private func createCustomZoneIfNeed(){
        guard !createdCustomZone else{
            os_log("已经创建了自定义zone。跳过创建，检查zone是否确实存在", log: log, type: .debug)
            checkCustomZone()
            return
        }
        
        os_log("开始创建自定义zone:%@", log: log, type: .info, SyncConstants.customZoneID.zoneName)
        
        let zone = CKRecordZone(zoneID: SyncConstants.customZoneID)
        let operation = CKModifyRecordZonesOperation(recordZonesToSave: [zone], recordZoneIDsToDelete: nil)
        
        operation.modifyRecordZonesCompletionBlock = {[weak self] _,_,error in
            guard let self = self else { return }
            
            if let error = error{
                os_log("创建自定义zone:%{public}@失败", log: self.log, type: .error, String(describing: error))
                //重试创建zone
                error.retryCloudKitOperationIfPossible(self.log){
                    self.createCustomZoneIfNeed()
                }
            }else{
                os_log("自定义zone创建成功", log: self.log, type: .info)
                self.createdCustomZone = true
            }
        }
        
        operation.qualityOfService = .userInitiated
        operation.database = privateDatabase
        
        cloudOperationQueue.addOperation(operation)
    }
    
    private func checkCustomZone(){
        let operation = CKFetchRecordZonesOperation(recordZoneIDs: [SyncConstants.customZoneID])
        
        operation.fetchRecordZonesCompletionBlock = {[weak self] ids,error in
            guard let self = self else { return }
            
            if let error = error{
                os_log("无法检查自定义zone:%{public}@的存在性",log:self.log,type:.error,String(describing: error))
                
                //尝试重新检查自定义zone的存在性，如果服务器返回的error给出的意见是该error不可恢复，则需要执行新建自定义zone函数
                if(!error.retryCloudKitOperationIfPossible(self.log,with: self.checkCustomZone)){
                    os_log("从服务器获取自定义zone时发生不可恢复错误",log:self.log,type:.error,String(describing: error))
                    
                   DispatchQueue.main.async {
                    self.createdCustomZone = false
                    self.createCustomZoneIfNeed()
                   }
                }
            }else if (ids == nil || ids?.count == 0){
                os_log("Custom zone reported as existing, but it doesn't exist. Creating.",log:self.log,type:.error)
                self.createdCustomZone = false
                self.createCustomZoneIfNeed()
            }
        }
        
        operation.qualityOfService = .userInitiated
        operation.database = privateDatabase
        
        cloudOperationQueue.addOperation(operation)
    }
    
    //MARK:-检查&创建数据库的订阅
    private func createPrivateSubscriptionsIfNeeded(){
        guard !createdPrivateSubscription else {
            os_log("已经订阅私有数据库，跳过创建订阅，去检查该订阅是否真实存在。", log: log, type: .debug)

            checkSubscription()

            return
        }
        
        let subscription = CKRecordZoneSubscription(zoneID: SyncConstants.customZoneID,subscriptionID: privateSubscriptionId)
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        
        subscription.notificationInfo = notificationInfo
        subscription.recordType = .diaryInfo
        
        let operaion = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: nil)
        
        operaion.modifySubscriptionsCompletionBlock = {[weak self] _,_,error in
            guard let self = self else {return}
            
            if let error = error{
                os_log("Failed to create private CloudKit subscription: %{public}@",
                       log: self.log,
                       type: .error,
                       String(describing: error))
                error.retryCloudKitOperationIfPossible(self.log) { self.createPrivateSubscriptionsIfNeeded() }
            }else{
                os_log("私有数据库的订阅创建成功！", log: self.log, type: .info)
                self.createdPrivateSubscription = true
            }
        }
        
        operaion.database = privateDatabase
        operaion.qualityOfService = .userInitiated
        cloudOperationQueue.addOperation(operaion)
    }
    
    private func checkSubscription() {
        let operation = CKFetchSubscriptionsOperation(subscriptionIDs: [privateSubscriptionId])

        operation.fetchSubscriptionCompletionBlock = { [weak self] ids, error in
            guard let self = self else { return }

            if let error = error {
                os_log("Failed to check for private zone subscription existence: %{public}@", log: self.log, type: .error, String(describing: error))

                if !error.retryCloudKitOperationIfPossible(self.log, with: { self.checkSubscription() }) {
                    os_log("Irrecoverable error when fetching private zone subscription, assuming it doesn't exist: %{public}@", log: self.log, type: .error, String(describing: error))

                    DispatchQueue.main.async {
                        self.createdPrivateSubscription = false
                        self.createPrivateSubscriptionsIfNeeded()
                    }
                }
            } else if ids == nil || ids?.count == 0 {
                os_log("Private subscription reported as existing, but it doesn't exist. Creating.", log: self.log, type: .error)

                DispatchQueue.main.async {
                    self.createdPrivateSubscription = false
                    self.createPrivateSubscriptionsIfNeeded()
                }
            }
        }

        operation.qualityOfService = .userInitiated
        operation.database = privateDatabase

        cloudOperationQueue.addOperation(operation)
    }
    
    //MARK:-上传
    private func uploadLocalDataNotUploadedYet(){
        //离线期间产生的数据在此上传
        os_log("检查本地未上传的日记...",log:log,type:.debug)
        
        //如果ckData未被赋值，表示该日记从未被上传到云端
        let diaries = buffer.filter({ $0.ckData == nil })
        
        guard !diaries.isEmpty else {
            os_log("本地没有未上传的日记...",log:log,type:.debug)
            return
        }
        
        os_log("发现 %d 篇本地日记未上传", log: self.log, type: .debug, diaries.count)
        
        let records = diaries.map({ $0.record })
        
        uploadRecords(records)
    }
    
    func upload(_ diray: diaryInfo) {
        os_log("开始上传...", log: log, type: .debug)

        buffer.append(diray)

        uploadRecords([diray.record])
    }
    
    private func uploadRecords(_ records: [CKRecord]) {
        guard !records.isEmpty else { return }

        os_log("开始上传 %d 个修改(或新增)的记录", log: log, type: .debug,records.count)

        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)

        operation.perRecordCompletionBlock = { [weak self] record, error in
            guard let self = self else { return }

            // We're only interested in conflict errors here
            guard let error = error, error.isCloudKitConflict else { return }

            os_log("CloudKit conflict with record of type %{public}@", log: self.log, type: .error, record.recordType)

            guard let resolvedRecord = error.resolveConflict(with: diaryInfo.resolveConflict) else {
                os_log(
                    "Resolving conflict with record of type %{public}@ returned a nil record. Giving up.",
                    log: self.log,
                    type: .error,
                    record.recordType
                )
                return
            }

            os_log("Conflict resolved, will retry upload", log: self.log, type: .info)

            self.uploadRecords([resolvedRecord])
        }

        operation.modifyRecordsCompletionBlock = { [weak self] serverRecords, _, error in
            guard let self = self else { return }

            if let error = error {
                os_log("上传记录失败: %{public}@", log: self.log, type: .error, String(describing: error))

                DispatchQueue.main.async {
                    self.handleUploadError(error, records: records)
                }
            } else {
                os_log("成功上传%d个记录！", log: self.log, type: .info, records.count)

                DispatchQueue.main.async {
                    guard let serverRecords = serverRecords else { return }
                    //运行到这里，已经确定的是serverRecords都已经上传成功
                    //因此updateLocalModelsAfterUpload的主要的作用是标记这些记录为”已上传“
                    self.updateLocalModelsAfterUpload(with: serverRecords)
                }
            }
        }

        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInitiated
        operation.database = privateDatabase

        cloudOperationQueue.addOperation(operation)
    }
    
    private func handleUploadError(_ error: Error, records: [CKRecord]) {
        guard let ckError = error as? CKError else {
            os_log("Error was not a CKError, giving up: %{public}@", log: self.log, type: .fault, String(describing: error))
            return
        }

        if ckError.code == CKError.Code.limitExceeded {
            os_log("CloudKit batch limit exceeded, sending records in chunks", log: self.log, type: .error)

            fatalError("Not implemented: batch uploads. Here we should divide the records in chunks and upload in batches instead of trying everything at once.")
        } else {
            let result = error.retryCloudKitOperationIfPossible(self.log) { self.uploadRecords(records) }

            if !result {
                os_log("Error is not recoverable: %{public}@", log: self.log, type: .error, String(describing: error))
            }
        }
    }
    
    private func updateLocalModelsAfterUpload(with records: [CKRecord]) {
        os_log("将buffer内的本地记录标记为[已上传]，并清空buffer", log: self.log, type: .error)
        for r in records{
            guard let model = buffer.first(where: { $0.id == r.recordID.recordName }) else { continue }
            //*赋值ckData，表示该日记已经在云端有副本
            LWRealmManager.shared.update {
                model.ckData = r.encodedSystemFields
            }
        }

        DispatchQueue.main.async {
            self.buffer = []
        }
    }
    
    //MARK:-删除
    func delete(_ diray: diaryInfo) {
        print("警告：还没实现删除逻辑！")
//        fatalError("Deletion not implemented")
    }
    
    //MARK:-获取云端数据库的变化
    private lazy var privateChangeTokenKey: String = {
        return "TOKEN-\(SyncConstants.customZoneID.zoneName)"
    }()
    
    ///标记record的某个特定版本的对象
    private var privateChangeToken: CKServerChangeToken? {
        //从UserDefaults取值
        get {
            guard let data = defaults.data(forKey: privateChangeTokenKey) else { return nil }
            guard !data.isEmpty else { return nil }

            do {
                let token = try NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: data)

                return token
            } catch {
                os_log("Failed to decode CKServerChangeToken from defaults key privateChangeToken", log: log, type: .error)
                return nil
            }
        }
        //存储到UserDefaults
        set {
            guard let newValue = newValue else {
                defaults.setValue(Data(), forKey: privateChangeTokenKey)
                return
            }

            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: true)

                defaults.set(data, forKey: privateChangeTokenKey)
            } catch {
                os_log("Failed to encode private change token: %{public}@", log: self.log, type: .error, String(describing: error))
            }
        }
    }
    
    ///获取云端的变动
    func fetchRemoteChanges() {
        var changedRecords: [CKRecord] = []
        var deletedRecordIDs: [CKRecord.ID] = []

        let operation = CKFetchRecordZoneChangesOperation()

        let token: CKServerChangeToken? = privateChangeToken

        let config = CKFetchRecordZoneChangesOperation.ZoneConfiguration(
            previousServerChangeToken: token,
            resultsLimit: nil,
            desiredKeys: nil
        )

        operation.configurationsByRecordZoneID = [SyncConstants.customZoneID: config]

        operation.recordZoneIDs = [SyncConstants.customZoneID]
        operation.fetchAllChanges = true

        ///？这个方法并没有回调
        operation.recordZoneChangeTokensUpdatedBlock = { [weak self] _, changeToken, _ in
            print("recordZoneChangeTokensUpdatedBlock")
            guard let self = self else { return }
            os_log("云端的更改令牌发生变动，获取并更新本地的更改令牌到最新！",log: self.log,type: .debug)
            guard let changeToken = changeToken else { return }
            
            //存储changeToken以便在后续的提取中使用
            self.privateChangeToken = changeToken
        }
        
        //当发现有改动数据需要同步
        operation.recordChangedBlock = { changedRecords.append($0) }
        //当发现有删除数据需要同步
        operation.recordWithIDWasDeletedBlock = { recordID, _ in
            // In the future we may need to use the second arg to this closure and map
            // between record types and deleted record IDs (when we need to sync more types)
            deletedRecordIDs.append(recordID)
        }
        
        //完成所有的变动获取后执行
        operation.recordZoneFetchCompletionBlock = { [weak self] _, token, _, _, error in
            guard let self = self else { return }
            //如果有错误，处理错误
            if let error = error as? CKError {
                os_log("Failed to fetch record zone changes: %{public}@",
                       log: self.log,
                       type: .error,
                       String(describing: error))

                if error.code == .changeTokenExpired {
                    os_log("Change token expired, resetting token and trying again", log: self.log, type: .error)

                    self.privateChangeToken = nil

                    DispatchQueue.main.async { self.fetchRemoteChanges() }
                } else {
                    error.retryCloudKitOperationIfPossible(self.log) { self.fetchRemoteChanges() }
                }
            } else {
                os_log("成功获取云端的最新更改令牌，存储到本地", log: self.log, type: .debug)

                self.privateChangeToken = token
            }
        }

        operation.fetchRecordZoneChangesCompletionBlock = { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                os_log("Failed to fetch record zone changes: %{public}@",
                       log: self.log,
                       type: .error,
                       String(describing: error))

                error.retryCloudKitOperationIfPossible(self.log) { self.fetchRemoteChanges() }
            } else {
                os_log("zone内所有变动情况(新增/修改/删除))获取完毕！", log: self.log, type: .info)

                DispatchQueue.main.async { self.commitServerChangesToDatabase(with: changedRecords, deletedRecordIDs: deletedRecordIDs) }
            }
        }

        operation.qualityOfService = .userInitiated
        operation.database = privateDatabase

        cloudOperationQueue.addOperation(operation)
    }
    
    ///获取云端的变化，更新本地数据库
    private func commitServerChangesToDatabase(with changedRecords: [CKRecord], deletedRecordIDs: [CKRecord.ID]) {
        guard !changedRecords.isEmpty || !deletedRecordIDs.isEmpty else {
            os_log("云端没有发生任何变动(新增/修改/删除)", log: log, type: .info)
            return
        }

        os_log("云端有%d个记录发生了新增/修改，%d个记录被删除。将这些变动同步到本地数据库...", log: log, type: .info, changedRecords.count, deletedRecordIDs.count)

        //Record解码Model
        let models: [diaryInfo] = changedRecords.compactMap { record in
            do {
                return try diaryInfo(record: record)
            } catch {
                os_log("Error decoding diary from record: %{public}@", log: self.log, type: .error, String(describing: error))
                return nil
            }
        }

        let deletedIdentifiers = deletedRecordIDs.map { $0.recordName }

        didUpdateModels(models)
        didDeleteModels(deletedIdentifiers)
    }
    
}
