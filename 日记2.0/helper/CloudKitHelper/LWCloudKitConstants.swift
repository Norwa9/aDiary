//
//  LWCloudKitConstants.swift
//  日记2.0
//
//  Created by 罗威 on 2021/7/6.
//

import Foundation
import CloudKit

public struct SyncConstants{
    public static let containerIdentifier = "iCloud.com.LuoWei.aDiary"
    
    public static let subsystemName = "codes.LuoWei.aDiary"
    
    public static let customZoneName = "diaryZoom"
    
    public static let customZoneID:CKRecordZone.ID = {
        CKRecordZone.ID(zoneName: SyncConstants.customZoneName, ownerName: CKCurrentUserDefaultName)
    }()
    
    
}
