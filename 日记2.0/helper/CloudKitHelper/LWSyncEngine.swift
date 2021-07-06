//
//  LWSyncEngine.swift
//  日记2.0
//
//  Created by 罗威 on 2021/7/6.
//

import Foundation
import CloudKit
import os.log

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
            os_log("Already subscribed to private database changes, skipping subscription but checking if it really exists", log: log, type: .debug)

            checkSubscription()

            return
        }
        
        let subscription = CKRecordZoneSubscription(zoneID: SyncConstants.customZoneID,subscriptionID: privateSubscriptionId)
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        
        subscription.notificationInfo = notificationInfo
        subscription.recordType = .diary
        
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
                os_log("Private subscription created successfully", log: self.log, type: .info)
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
        
    }
}
