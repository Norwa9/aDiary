//
//  scalableImage.swift
//  日记2.0
//
//  Created by 罗威 on 2022/1/16.
//

import Foundation
import RealmSwift
import UIKit
import CloudKit

class scalableImage: Object{
    @objc dynamic var uuid:String = "" // 图像的唯一标识符
    @objc dynamic var data:Data? // 图像
    @objc dynamic var uploaded:Bool = false
    
    convenience init(image:UIImage?,uuid:String) {
        self.init()
        self.uuid = uuid
        self.data = image?.jpegData(compressionQuality: 1)
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

//MARK: - scalableImage + CloudKit
extension CKRecord.RecordType {
    static let scalableImage = "scalableImage"
}


enum scalableImageRecordKey: String {
    case uuid
    case data
    case uploaded
}
extension CKRecord {
    subscript(key: scalableImageRecordKey) -> Any? {
        get {
            return self[key.rawValue]
        }
        set {
            self[key.rawValue] = newValue as? CKRecordValue
        }
    }
}

// iCloud相关拓展
extension scalableImage {
    /// 创建CKRecord对象
    var record: CKRecord {
        let r = CKRecord(recordType: .scalableImage, recordID: recordID)

        r[.uuid] = uuid
        r[.data] = imageAsset
        r[.uploaded] = uploaded
        return r
    }
    
    /// 解码云端取回的record
    convenience init(record: CKRecord) throws {
        self.init()//RealmSwift:Please note this says 'self' and not 'super'
        
        
        ///required keys
        guard let uuid = record[.uuid] as? String else {
            throw RecordError.missingKey(.uuid)
        }
        guard let uploaded = record[.uploaded] as? Int else {
            throw RecordError.missingKey(.uploaded)
        }
        
        /*
         随着App的更新，新版本中可能会加入新的字段。
         假设一台设备使用旧版本上传record到云端，由于旧版本缺少新字段，因此上传的record对应的字段被cloudkit自动填充为nil。
         而当新版本App从云端取回这些record时，又需要这些值为nil的新字段，因此要妥善处理nil。
         这里的做法就是，如果record中没有某个key的值，则将key赋予一个初始值。
         */
        //optional keys
        var imageData:Data?
        if let asset = record[.data] as? CKAsset{
            imageData = asset.data
        }
        
//        self.uuid = record.recordID.recordName // == record[.uuid]
        self.uuid = uuid
        self.data = imageData
        self.uploaded = (uploaded != 0)
    }
    
    var recordID:CKRecord.ID{
        return CKRecord.ID(recordName: uuid, zoneID: SyncConstants.customZoneID)
    }
    
    struct  RecordError:LocalizedError {
        var localizedDescription:String
        
        static func missingKey(_ key: scalableImageRecordKey) -> RecordError {
            RecordError(localizedDescription: "Missing required key: \(key.rawValue)")
        }
    }
    
    //imageData转CKAsset
    var imageAsset:CKAsset?{
        guard let data = data else {
            return nil
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(uuid+"_imageData")
        do {
            try data.write(to: url)
        } catch {
            return nil
        }
        return CKAsset(fileURL: url)
    }
}
