//
//  cloudKitManager.swift
//  日记2.0
//
//  Created by 罗威 on 2021/6/22.
//

import Foundation
import CloudKit
import UIKit

class iCloudHelper{
    static let shared = iCloudHelper()
    
    var diaries:[CKRecord] = []
    let container = CKContainer.default()
    let database:CKDatabase = CKContainer.default().publicCloudDatabase
    
    //自定义的操作队列
    private let cloudQueue = DispatchQueue(label: "SyncEngine.Cloud", qos: .userInitiated)
    private lazy var cloudOperationQueue: OperationQueue = {
        let q = OperationQueue()

        q.underlyingQueue = cloudQueue
        q.name = "SyncEngine.Cloud"
        q.maxConcurrentOperationCount = 1

        return q
    }()
    
    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userAccountChanged),
                                               name: .CKAccountChanged,
                                               object: nil)
    }
    
    func fetchRecordsFromCloud(completion:@escaping (_ result:[diaryInfo])->()){
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "DiaryContent", predicate: predicate)
        database.perform(query, inZoneWith: nil, completionHandler: {
                    (results, error) -> Void in
            if error != nil {
              print("发生错误：\(error!)")
              return
            }
              
            if let results = results {
                print("Completed the download of data")
                let fetchedDiaries = results.map { (record) -> diaryInfo in
                    let date = record.object(forKey: "createdTimeCN") as! String
                    let content = record.object(forKey: "content") as? String
                    let diary = diaryInfo(dateString: date)
                    diary.content = content ?? "iCloud读取内容为空"
                    return diary
                }
                
                completion(fetchedDiaries)
                
            }
            
        })
    }
    
    ///在提供iCloud服务之间，必须检查用户的iCloud状态，以决定是否继续进行
    func checkAccountStatus(){
        container.accountStatus { status, error in
            if let error = error {
              // some error occurred (probably a failed connection, try again)
            } else {
                switch status {
                case .available:
                  // the user is logged in
                    break
                case .noAccount:
                  // the user is NOT logged in
                    break
                case .couldNotDetermine:
                  // for some reason, the status could not be determined (try again)
                    break
                case .restricted:
                  // iCloud settings are restricted by parental controls or a configuration profile
                    break
                @unknown default:
                  // ...
                    break
                }
            }
        }
    }
    
    /*
     user record是什么？
     一个用户在一个container中有一个用户字段user record，其中有多个字段，用于保存有一些关于该用户的信息。
     */
    ///获取该用户的用户记录
    func fetchUserRecord(){
        //1.先获取用户记录的ID
        container.fetchUserRecordID { (recordID, error) in
            guard let recordID = recordID,error == nil else{
                //handle error
                return
            }
            
            print("Got user record ID \(recordID.recordName).")
            
            //2.然后用这个ID取到对应的用户记录
            self.database.fetch(withRecordID: recordID) { record, error in
                guard let record = record, error == nil else {
                    // show off your error handling skills
                    return
                }
                
                
                
                print("The user record is: \(record)")
            }
            
            
        }
    }
    
    ///获取用户的全名
    func getUserFullName(recordID:CKRecord.ID){
        //弹窗：请求用户的允许
        container.requestApplicationPermission(.userDiscoverability) { status, error in
            guard status == .granted, error == nil else {
                // error handling voodoo
                return
            }

            self.container.discoverUserIdentity(withUserRecordID: recordID) { identity, error in
                guard let components = identity?.nameComponents, error == nil else {
                    // more error handling magic
                    return
                }

                DispatchQueue.main.async {
                    let fullName = PersonNameComponentsFormatter().string(from: components)
                    print("The user's full name is \(fullName)")
                }
            }
        }
    }
    
    ///发现也使用该应用程序的用户联系人，返回一个数组
    func discoverContacts(){
        container.discoverAllIdentities { identities, error in
            guard let identities = identities, error == nil else {
                // awesome error handling
                return
            }

            print("User has \(identities.count) contact(s) using the app:")
            print("\(identities)")
        }
    }
    
    ///给user record添加字段
    func updateUserRecord(_ userRecord: CKRecord, with avatarURL: URL){
        userRecord["avatar"] = CKAsset(fileURL: avatarURL)

        container.publicCloudDatabase.save(userRecord) { _, error in
            guard error == nil else {
                // top-notch error handling
                return
            }

            print("Successfully updated user record with new avatar")
        }
    }
    
    ///观察用户的iCloud账户状态变化
    @objc func userAccountChanged(){
        
    }
    
    ///创建订阅
    func createSubscription(){
        //注册显式通知
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { authorized, error in
            guard error == nil, authorized else {
                // not authorized...
                return
            }
            
            // subscription can be created now \o/
        }
        //（如果仅仅注册隐式通知，只需要registerForRemoteNotifications）
        UIApplication.shared.registerForRemoteNotifications()
        
        
        //创建一个订阅实例
        let subscription = CKQuerySubscription(recordType: "DiaryContent",
                                               predicate: NSPredicate(value: true),
                                               subscriptionID: "update",
                                               options: [.firesOnRecordCreation])
        //配置通知
        let info = CKSubscription.NotificationInfo()
        info.alertLocalizationKey = "nearby_poi_alert"//用作alert的格式:
        //例如“nearby_poi_alert” = “%@ has been added, check it out!”;
        info.alertLocalizationArgs = ["title"]//从记录中取出该key的内容填充上面alert占位符的内容
        info.soundName = "default"
        info.desiredKeys = ["title"] //desiredKey是应该随通知一起发送的记录中的keys。
        subscription.notificationInfo = info
        
        //保存订阅到云端
        //*你想订阅哪个数据库，你就必须保存该数据库上
        database.save(subscription) { (savedSubscription, error) in
            guard let savedSubscription = savedSubscription , error == nil else{
                //处理错误
                return
            }
            //成功保存订阅
            //(可能希望将subscription ID保存在User Default或其他位置)
        }
    }
    
    //获取云端的数据变化
    func fetchRemoteChanges(){
        // CKCurrentUserDefaultName is a "magic" constant provided by CloudKit which represents the currently logged in user
        let customZoneID = CKRecordZone.ID(zoneName: "myDiaries", ownerName: CKCurrentUserDefaultName)
        let operation = CKFetchRecordZoneChangesOperation()
//        let token:CKServerChangeToken? = privateChangeToken//该属性还没有实现
        let token:CKServerChangeToken? = nil
        let config = CKFetchRecordZoneChangesOperation.ZoneConfiguration(previousServerChangeToken: token,
                                                                         resultsLimit: nil,
                                                                         desiredKeys: nil)
        operation.configurationsByRecordZoneID = [customZoneID:config]
        
        operation.recordZoneIDs = [customZoneID]
        operation.fetchAllChanges = true
        
        operation.recordZoneChangeTokensUpdatedBlock = {_,changeTolen,_ in
            //存储changeToken以便在后续的提取中使用
        }
        
        operation.recordZoneFetchCompletionBlock = { [weak self] _,_,_,_,error in
            //如果有错误，处理错误
        }
        
        operation.recordChangedBlock = {record in
            //解析记录，然后存储到本地以便后续使用
        }
        
        operation.recordWithIDWasDeletedBlock = {recordID,_ in
            //删除recordID代表的本地实体
        }
        
        operation.qualityOfService = .userInitiated
        operation.database = database
        
        cloudOperationQueue.addOperation(operation)
    }
    
}
