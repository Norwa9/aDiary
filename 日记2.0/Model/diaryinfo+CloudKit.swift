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
    static let diary = "diary"
}

extension diaryInfo{
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
