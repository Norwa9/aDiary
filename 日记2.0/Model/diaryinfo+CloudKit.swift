//
//  diaryinfo+CloudKit.swift
//  日记2.0
//
//  Created by yy on 2021/7/7.
//

import Foundation
import CloudKit

/*
 扩展：为了配合model与iCloud的交互，对diaryInfo进行相关扩展
 */

extension CKRecord.RecordType {
    static let diaryInfo = "diaryInfo"
}

extension diaryInfo{
    
}

enum RecordKey: String {
    case date
    case year
    case month
    case day
    case content
    case islike
    case tags
    case mood
    case uuidofPictures
    case containsImage
    case rtfd
    case imageAttributesTuples
    case todoAttributesTuples
    
}
//MARK:diaryInfo+CloudKit
extension diaryInfo {
    var record: CKRecord {
        let r = CKRecord(recordType: .diaryInfo, recordID: recordID)

        r[.date] = date
        r[.year] = year
        r[.month] = month
        r[.day] = day
        r[.content] = content
        r[.islike] = islike
        r[.tags] = self.tags
        r[.mood] = mood
        r[.containsImage] = containsImage
        r[.rtfd] = rtfdAsset
        r[.imageAttributesTuples] = tuples2dictString(imageAttributesTuples)
        r[.todoAttributesTuples] = tuples2dictString(todoAttributesTuples)
        return r
    }
    
    var recordID:CKRecord.ID{
        return CKRecord.ID(recordName: id,zoneID: SyncConstants.customZoneID)
    }
    
    struct  RecordError:LocalizedError {
        var localizedDescription:String
        
        static func missingKey(_ key: RecordKey) -> RecordError {
            RecordError(localizedDescription: "Missing required key: \(key.rawValue)")
        }
    }
    
    ///解决冲突的方案：保留最新的record
    static func resolveConflict(clientRecord: CKRecord, serverRecord: CKRecord) -> CKRecord? {
        // Most recent record wins. This might not be the best solution but YOLO.

        guard let clientDate = clientRecord.modificationDate, let serverDate = serverRecord.modificationDate else {
            return clientRecord
        }

        if clientDate > serverDate {
            return clientRecord
        } else {
            return serverRecord
        }
    }
    
    ///解决冲突：离线修改的数据是新的，云端的数据是旧的。不能直接让云端覆盖本地
    //////而是保留二者中最新者。
    ///参数：云端的model
    ///返回：
    static func resolveOfflineConflict(serverModel: diaryInfo) -> diaryInfo{
        var newerModel:diaryInfo
        let date = serverModel.date
        let predicate = NSPredicate(format: "date == %@",date)
        let result = LWRealmManager.shared.query(predicate: predicate).first
        if let clientModel = result{
            //serverModel在本地存在，对比修改时间。
            if clientModel.modTime! > serverModel.modTime!{
                //说明本地model在离线期间进行了修改
                newerModel =  clientModel
                //还需要将这个新的model同步到云端，不然下次又被覆盖
                print("将该离线的最新修改上传到云端，日期:\(clientModel.date)")
                DiaryStore.shared.addOrUpdate(newerModel)
            }else{
                newerModel =  serverModel
            }
        }else{
            //serverModel在本地不存在
            newerModel =  serverModel
        }
        return newerModel
        
    }
}

//MARK:-CKAsset+
extension CKAsset {
    var data: Data? {
        guard let url = fileURL else { return nil }
        return try? Data(contentsOf: url)
    }
}

//MARK:-CKRecord+
extension CKRecord {

    var encodedSystemFields: Data {
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        encodeSystemFields(with: coder)//给record的元数据编码
        coder.finishEncoding()

        return coder.encodedData
    }

}
extension CKRecord {
    subscript(key: RecordKey) -> Any? {
        get {
            return self[key.rawValue]
        }
        set {
            self[key.rawValue] = newValue as? CKRecordValue
        }
    }
}
