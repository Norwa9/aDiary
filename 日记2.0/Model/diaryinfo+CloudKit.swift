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

enum diaryInfoRecordKey: String {
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
    case todos
    case emojis
    case todoModelsJSON
    
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
        r[.mood] = mood // imageModelsJSON
        r[.containsImage] = containsImage
        r[.rtfd] = rtfdAsset
        r[.imageAttributesTuples] = tuples2dictString(imageAttributesTuples)
        r[.todoAttributesTuples] = tuples2dictString(todoAttributesTuples)
        r[.todos] = todos
        r[.emojis] = emojis
        r[.todoModelsJSON] = todoModelsJSON
        return r
    }
    
    var recordID:CKRecord.ID{
        return CKRecord.ID(recordName: id,zoneID: SyncConstants.customZoneID)
    }
    
    struct  RecordError:LocalizedError {
        var localizedDescription:String
        
        static func missingKey(_ key: diaryInfoRecordKey) -> RecordError {
            RecordError(localizedDescription: "Missing required key: \(key.rawValue)")
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
    
    ///从云端获取日记时，甄别空日记
    ///因为空日记可能是未同步的日记，若同步到本设备会覆盖原有内容！！！
    static func resolveEmptyDiary(serverModel: diaryInfo) -> diaryInfo?{
        var resolvedDiary:diaryInfo?
        
        let date = serverModel.date
        let predicate = NSPredicate(format: "date == %@",date)
        if let _ = LWRealmManager.shared.query(predicate: predicate).first{
            //如果本地有该日期的日记
            if let rtfd = serverModel.rtfd, rtfd.count < 300{
                //且如果云端日记是空日记(观察到<235bytes是空日记)，则云端日记不能覆盖本地，即不处理。
                return nil
            }else{
                //不是空日记，则覆盖本地日记
                resolvedDiary =  serverModel
            }
        }else{
            //如果本地该日期没有日记，则直接覆盖
            resolvedDiary = serverModel
        }
        
        return resolvedDiary
        
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
    subscript(key: diaryInfoRecordKey) -> Any? {
        get {
            return self[key.rawValue]
        }
        set {
            self[key.rawValue] = newValue as? CKRecordValue
        }
    }
}
