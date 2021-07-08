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
    struct  RecordError:LocalizedError {
        var localizedDescription:String
        
        static func missingKey(_ key: RecordKey) -> RecordError {
            RecordError(localizedDescription: "Missing required key \(key.rawValue)")
        }
    }
    
    enum RecordKey: String {
        case date
        case content
        case islike
        case tags
        case mood
        case uuidofPictures
        case containsImage
    }
    
    var recordID:CKRecord.ID{
        return CKRecord.ID(recordName: ,zoneID: <#T##CKRecordZone.ID#>)
    }
    
    var record: CKRecord {
        let r = CKRecord(recordType: .diary, recordID: recordID)

        r[.title] = title
        r[.subtitle] = subtitle
        r[.ingredients] = ingredients
        r[.instructions] = instructions
        r[.image] = imageAsset

        return r
    }
}
