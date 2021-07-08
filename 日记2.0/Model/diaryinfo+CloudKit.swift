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
    case content
    case islike
    case tags
    case mood
    case uuidofPictures
    case containsImage
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
