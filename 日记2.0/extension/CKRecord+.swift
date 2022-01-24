//
//  CKRecord+.swift
//  日记2.0
//
//  Created by 罗威 on 2022/1/18.
//

import Foundation
import CloudKit

extension CKRecord{
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
}
