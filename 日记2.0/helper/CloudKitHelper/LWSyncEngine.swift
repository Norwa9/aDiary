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
import RealmSwift

final class LWSyncEngine{
    private var accountStatus:CKAccountStatus = .couldNotDetermine
    
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

    init(defaults:UserDefaults) {
        self.defaults = defaults
        
        indicatorViewManager.shared.start(type: .checkRemoteChange)
    }
    
    
    
    //MARK: -初始化
    public func start(){
        print("开启LWSyncEngine")
        //0.最开始检查用户状态
        checkAccountStatus( {[weak self] accoutStatus,connected in
            guard let self = self else{return}
            if !connected{
                indicatorViewManager.shared.stop(withText: "网络连接不可用，暂停同步")
                return
            }
            switch accoutStatus{
            case .available:
                    //1.配置iCloud环境
                self.prepareCloudEnvironment {
                    os_log("iCloud环境配置成功！", log: self.log, type: .debug)
                    //2.同步未上传的本地数据
                    self.uploadLocalDataNotUploadedYet()
                    //3.获取其他设备向云端提交的变动
                    self.fetchRemoteChanges()
                }
            default:
                indicatorViewManager.shared.stop(withText: "iCloud账户不可用，暂停同步")
                break
            }
        })
    }
    
    //MARK:  -检查iCloud账户可用性
    typealias didReceiveStatusBlock = (_ status:CKAccountStatus,_ connected:Bool) ->Void
    ///检查账户的可用性
    func checkAccountStatus(_ completion:@escaping didReceiveStatusBlock){
        self.container.accountStatus { status, error in
            if let error = error {
                os_log("验证iCloud账户状态失败: %{public}@", log: self.log, type: .error, String(describing: error))
                DispatchQueue.main.async {
                    self.handleStatusCheckError(error: error)
                }
            } else {
                // 检查网络
                hasNetwork { connected in
                    self.accountStatus = status
                    completion(status,connected)
                }
            }
            
        }
    }
    
    func handleStatusCheckError(error:Error){
        guard let _ = error as? CKError else {
            os_log("服务器返回的不是CKError对象，放弃处理: %{public}@", log: self.log, type: .fault, String(describing: error))
            return
        }
        let result = error.retryCloudKitOperationIfPossible(self.log) {
            //重新配置环境
            self.start()
            
        }
        if !result {
            os_log("此错误不是可恢复错误: %{public}@", log: self.log, type: .error, String(describing: error))
        }
    }
    
    
    ///配置CloudKit环境
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
    
    
    
    //MARK: -检查&创建自定义zone
    ///创建自定义Zone
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
    
    ///检查自定义Zone的存在性
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
    
    //MARK: -检查&创建数据库的订阅
    ///创建私有数据库的订阅
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
        
        operaion.database = privateDatabase
        operaion.qualityOfService = .userInitiated
        
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
        
        
        cloudOperationQueue.addOperation(operaion)
    }
    
    ///检查订阅状态
    private func checkSubscription() {
        let operation = CKFetchSubscriptionsOperation(subscriptionIDs: [privateSubscriptionId])

        //ids:[CKSubscription.ID : CKSubscription]?
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
    
    //MARK: -上传
    ///上传未上传的Model
    func uploadLocalDataNotUploadedYet(){
        print("检查本地未上传的日记...")
        
        //检查[当前的]本地数据库中：新建的但未上传、离线修改的但未上传 的数据
        let db = LWRealmManager.shared.localDatabase.toArray()
        let needsUpload = db.filter({
            return ($0.ckData == nil || $0.editedButNotUploaded)
        }).suffix(399)//cloudKit一次最多上传400个记录
        
        let needsDeleteIDs = userDefaultManager.deleteBufferIDs
        
        if needsUpload.isEmpty && needsDeleteIDs.isEmpty{
            print("本地没有需要上传的日记...")
            return
        }
        
        print("发现\(needsUpload.count)篇本地日记未上传, \(needsDeleteIDs.count)篇日记在云端未删除")
        
        let recordsNeedsUpload = needsUpload.map({ $0.record })
        
        uploadRecords(recordsNeedsUpload)
        deleteRecords(needsDeleteIDs,recordType: .diaryInfo)
    }
    
    ///统一接口：上传指定Recored
    public func upload(_ records: [CKRecord]) {
        if userDefaultManager.iCloudEnable == false{
            return
        }
        if records.isEmpty{
            return
        }
        print("开始上传\(records.count)个项目,类型是\(records.first?.recordType ?? " ")")
        uploadRecords(records)
    }
    
    ///上传指定的记录
    private func uploadRecords(_ records: [CKRecord]) {
        guard !records.isEmpty else { return }

        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)

        operation.perRecordCompletionBlock = { [weak self] record, error in
            guard let self = self else { return }

            // We're only interested in conflict errors here
            guard let error = error, error.isCloudKitConflict else { return }

            os_log("CloudKit conflict with record of type %{public}@", log: self.log, type: .error, record.recordType)

            guard let resolvedRecord = error.resolveConflict(with: CKRecord.resolveConflict) else {
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
    
    ///处理上传错误
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
    
    /// 上传云端成功后，本地需要完成的事情
    /// 主要功能：将上传成功的Model打上"已上传"的标记
    /// 以后如果新增recordType，需要新增这里的逻辑
    private func updateLocalModelsAfterUpload(with records: [CKRecord]) {
        print("cloudOperationQueue完成比例：:\(self.cloudOperationQueue.progress.fractionCompleted)")
        guard let recordType = records.first?.recordType else {return}
        if recordType == .diaryInfo{
            DiaryStore.shared.setUploaded(records: records)
        }
        else if recordType == .scalableImage{
            ImageTool.shared.setUploaded(records: records)
        }
    }
    
    //MARK: -手动删除
    ///外界的唯一删除接口
    ///删除指定id的record
    public func delete(_ ids: [String],recordType:CKRecord.RecordType) {
        if userDefaultManager.iCloudEnable == false{
            return
        }
        
        var nonEmptyIDs = [String]()
        for id in ids {
            if id != ""{
                nonEmptyIDs.append(id)
            }
        }
        if nonEmptyIDs.isEmpty{
            return
        }
        if recordType == .diaryInfo{
            indicatorViewManager.shared.start(type: .delete) // 删除图片时无需提示
        }
        print("开始删除\(ids.count)个项目,类型是\(recordType)")
        deleteRecords(nonEmptyIDs,recordType: recordType)
        
    }
    
    
    private func deleteRecords(_ ids:[String],recordType:CKRecord.RecordType){
        guard !ids.isEmpty else{
            return
        }
        
        
        let recordIDs = ids.map { (id) -> CKRecord.ID in
            return CKRecord.ID(recordName: id,zoneID: SyncConstants.customZoneID)
        }
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDs)
        
        operation.perRecordCompletionBlock = { [weak self] record, error in
            guard let self = self else { return }

            // We're only interested in conflict errors here
            guard let error = error, error.isCloudKitConflict else { return }

            os_log("CloudKit conflict with record of type %{public}@", log: self.log, type: .error, record.recordType)

            guard let resolvedRecord = error.resolveConflict(with: CKRecord.resolveConflict) else {
                os_log(
                    "Resolving conflict with record of type %{public}@ returned a nil record. Giving up.",
                    log: self.log,
                    type: .error,
                    record.recordType
                )
                indicatorViewManager.shared.stop()
                return
            }

            os_log("Conflict resolved, will retry delete", log: self.log, type: .info)

            self.deleteRecords([resolvedRecord.recordID.recordName], recordType:recordType)
        }

        operation.modifyRecordsCompletionBlock = { [weak self] _, recordIDs, error in
            guard let self = self else { return }

            if let error = error {
                os_log("删除记录失败: %{public}@", log: self.log, type: .error, String(describing: error))

                DispatchQueue.main.async {
                    self.handleDeleteError(error, recordIDs: ids,recordType: recordType)
                }
            } else {
                DispatchQueue.main.async {
                    self.updateLocalModelsAfterDelete(with: recordIDs, recordType: recordType)
                }
            }
        }

        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInitiated
        operation.database = privateDatabase

        cloudOperationQueue.addOperation(operation)
    }
    
    ///处理删除错误
    private func handleDeleteError(_ error: Error, recordIDs: [String],recordType:CKRecord.RecordType) {
        guard let ckError = error as? CKError else {
            os_log("Error was not a CKError, giving up: %{public}@", log: self.log, type: .fault, String(describing: error))
            indicatorViewManager.shared.stop()
            return
        }

        if ckError.code == CKError.Code.limitExceeded {
            os_log("CloudKit batch limit exceeded, sending records in chunks", log: self.log, type: .error)
            
            fatalError("Not implemented: batch deletes. Here we should divide the records in chunks and delete in batches instead of trying everything at once.")
        } else {
            let result = error.retryCloudKitOperationIfPossible(self.log) { self.deleteRecords(recordIDs,recordType: recordType) }

            if !result {
                os_log("Error is not recoverable: %{public}@", log: self.log, type: .error, String(describing: error))
            }
        }
    }
    
    /// 云端删除成功后，本地需要完成的事情
    /// 以后如果新增recordType，需要新增这里的逻辑
    private func updateLocalModelsAfterDelete(with recordIDs: [CKRecord.ID]?,recordType:CKRecord.RecordType) {
        if recordType == .diaryInfo{
            DiaryStore.shared.setDeleted(recordIDs: recordIDs)
        }
        else if recordType == .scalableImage{
            ImageTool.shared.setDeleted(recordIDs: recordIDs)
        }
        
        indicatorViewManager.shared.stop()
        
    }
    
    
    
    
    //MARK: -获取云端数据库的变化
    private lazy var privateChangeTokenKey: String = {
        return "TOKEN-\(SyncConstants.customZoneID.zoneName)"
    }()
    
    ///私有数据库的change Token
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
    ///目前在两个场合中使用：1、App启动时；2、接收到远程通知时
    ///能够拉取1.changed、2.deleted的records
    func fetchRemoteChanges() {
        
        var changedRecords: [CKRecord] = []
        var deletedRecords: [(CKRecord.ID,CKRecord.RecordType)] = []

        let operation = CKFetchRecordZoneChangesOperation()
        operation.name = "fetchRemoteChanges"

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
        ///In my tests, it is only called every 200 or so records that changed.
        operation.recordZoneChangeTokensUpdatedBlock = { [weak self] _, changeToken, _ in
            guard let self = self else { return }
            print("云端的更改令牌发生变动，获取并更新本地的更改令牌到最新！")
            guard let changeToken = changeToken else { return }
            
            //存储changeToken以便在后续的提取中使用
            self.privateChangeToken = changeToken
        }
        
        //当发现有改动数据需要同步
        operation.recordChangedBlock = { changedRecords.append($0) }
        //当发现有删除数据需要同步
        operation.recordWithIDWasDeletedBlock = { recordID, recordType in
            // In the future we may need to use the second arg to this closure and map
            // between record types and deleted record IDs (when we need to sync more types)
            deletedRecords.append((recordID,recordType))
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
                os_log("拉取云端变动失败: %{public}@",log: self.log,type:.error,String(describing: error))

                error.retryCloudKitOperationIfPossible(self.log) { self.fetchRemoteChanges() }
            } else {
                os_log("zone内所有变动情况(新增/修改/删除))获取完毕！", log: self.log, type: .info)

                DispatchQueue.main.async {
                    self.commitServerChangesToDatabase(with: changedRecords, deletedRecords: deletedRecords)
                }
            }
        }

        operation.qualityOfService = .userInitiated
        operation.database = privateDatabase

        cloudOperationQueue.addOperation(operation)
    }
    
    ///获取云端的变化，更新本地数据库
    private func commitServerChangesToDatabase(with changedRecords: [CKRecord], deletedRecords: [(CKRecord.ID,CKRecord.RecordType)]) {
        guard !changedRecords.isEmpty || !deletedRecords.isEmpty else {
            os_log("云端没有发生任何变动(新增/修改/删除)", log: log, type: .info)
            indicatorViewManager.shared.stop()
            return
        }
        
        var diaryRecords:[CKRecord] = []
        var imgRecords:[CKRecord] = []
        for record in changedRecords {
            if record.recordType == .diaryInfo{
                diaryRecords.append(record)
            }
            else if record.recordType == .scalableImage{
                imgRecords.append(record)
            }
        }
        print("获取到[修改]：\(diaryRecords.count)个日记修改，\(imgRecords.count)个图片修改。将这些变动同步到本地数据库...")
        
        let changedDiaryInfoModels:[diaryInfo] = diaryRecords.compactMap { record in
            do {
                return try diaryInfo(record: record)
            } catch {
                os_log("Error decoding diary from record: %{public}@", log: self.log, type: .error, String(describing: error))
                return nil
            }
        }
        DiaryStore.shared.updateAfterSync(changedDiaryInfoModels)
        
        let changedSiModels:[scalableImage] = imgRecords.compactMap { record in
            do {
                return try scalableImage(record: record)
            } catch {
                os_log("Error decoding scalableImage from record: %{public}@", log: self.log, type: .error, String(describing: error))
                return nil
            }
        }
        ImageTool.shared.updateAfterSync(changedSiModels)
        
        
        // deleted records
        var diaryInfoIDs:[String] = []
        var siIDs:[String] = []
        for (deleteID,recordType) in deletedRecords{
            if recordType == .diaryInfo{
                diaryInfoIDs.append(deleteID.recordName)
            }else if recordType == .scalableImage{
                siIDs.append(deleteID.recordName)
            }
        }
        print("获取到[删除]：\(diaryInfoIDs.count)个日记删除，\(siIDs.count)个图片删除。将这些变动同步到本地数据库...")
        DiaryStore.shared.updateAfterDelete(diaryInfoIDs)
        ImageTool.shared.updateAfterDelete(siIDs)
        
        // 统一地更新UI：以上4个函数导致的UI变化在这里更新
        // 也仅运行到这里时，菊花转才停下。
        DispatchQueue.main.async {
            indicatorViewManager.shared.stop()
            UIApplication.getMonthVC()?.reloadMonthVC()
            
        }

    }
    
}
