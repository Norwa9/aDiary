//
//  cloudKitManager.swift
//  日记2.0
//
//  Created by 罗威 on 2021/6/22.
//

import Foundation
import CloudKit

class iCloudHelper{
    static let shared = iCloudHelper()
    
    var diaries:[CKRecord] = []
    let container = CKContainer.default()
    let database:CKDatabase = CKContainer.default().publicCloudDatabase
    
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
}
