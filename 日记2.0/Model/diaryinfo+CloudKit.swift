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
    case images
    case rtfd
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
    
    ///解决冲突的方案
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
