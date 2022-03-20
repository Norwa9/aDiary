//
//  LWSound.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/19.
//

import Foundation
import RealmSwift
import UIKit
import CloudKit

class LWSound:Object{
    @objc dynamic var uuid:String = ""
    @objc dynamic var soundData:Data?
    @objc dynamic var uploaded:Bool = false
    
    convenience init(uuid:String,soundData:Data?) {
        self.init()
        self.uuid = uuid
        self.soundData = soundData
    }
    
    //索引属性
    override class func indexedProperties() -> [String] {
        return ["uuid"]
    }
    //主键
    override class func primaryKey() -> String? {
        return "uuid"
    }
}

//MARK: - LWSound + CloudKit
extension CKRecord.RecordType {
    static let LWSound = "LWSound"
}


enum LWSoundRecordKey: String {
    case uuid_sound
    case soundData
    case uploaded_sound
}
extension CKRecord {
    subscript(key: LWSoundRecordKey) -> Any? {
        get {
            return self[key.rawValue]
        }
        set {
            self[key.rawValue] = newValue as? CKRecordValue
        }
    }
}

// iCloud相关拓展
extension LWSound {
    /// 创建CKRecord对象
    var record: CKRecord {
        let r = CKRecord(recordType: .LWSound, recordID: recordID)

        r[.uuid_sound] = uuid
        r[.soundData] = soundAsset
        r[.uploaded_sound] = uploaded
        return r
    }
    
    /// 解码云端取回的record
    convenience init(record: CKRecord) throws {
        self.init()//RealmSwift:Please note this says 'self' and not 'super'
        
        
        ///required keys
        guard let uuid = record[.uuid_sound] as? String else {
            throw RecordError.missingKey(.uuid_sound)
        }
        guard let uploaded = record[.uploaded_sound] as? Int else {
            throw RecordError.missingKey(.uploaded_sound)
        }
        
        /*
         随着App的更新，新版本中可能会加入新的字段。
         假设一台设备使用旧版本上传record到云端，由于旧版本缺少新字段，因此上传的record对应的字段被cloudkit自动填充为nil。
         而当新版本App从云端取回这些record时，又需要这些值为nil的新字段，因此要妥善处理nil。
         这里的做法就是，如果record中没有某个key的值，则将key赋予一个初始值。
         */
        //optional keys
        var soundData:Data?
        if let asset = record[.soundData] as? CKAsset{
            soundData = asset.data
        }
        
//        self.uuid = record.recordID.recordName // == record[.uuid]
        self.uuid = uuid
        self.soundData = soundData
        self.uploaded = (uploaded != 0)
    }
    
    var recordID:CKRecord.ID{
        return CKRecord.ID(recordName: uuid, zoneID: SyncConstants.customZoneID)
    }
    
    struct  RecordError:LocalizedError {
        var localizedDescription:String
        
        static func missingKey(_ key: LWSoundRecordKey) -> RecordError {
            RecordError(localizedDescription: "Missing required key: \(key.rawValue)")
        }
    }
    
    //soundData转CKAsset
    var soundAsset:CKAsset?{
        guard let data = soundData else {
            return nil
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(uuid+"_soundData")
        do {
            try data.write(to: url)
        } catch {
            return nil
        }
        return CKAsset(fileURL: url)
    }
}
