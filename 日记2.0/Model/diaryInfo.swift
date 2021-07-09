//
//  LWDiary.swift
//  日记2.0
//
//  Created by 罗威 on 2021/7/5.
//

import Foundation
import UIKit
import CloudKit
import RealmSwift

class diaryInfo:Object,Codable{
    
    //@objc dynamic **必须写
    @objc dynamic var ckData:Data? = nil
    @objc dynamic var id:String
    @objc dynamic var date:String
    @objc dynamic var content:String
    @objc dynamic var islike:Bool
    @objc dynamic var tags:[String]
    @objc dynamic var mood:String
    @objc dynamic var containsImage:Bool
    @objc dynamic var rtfd:Data?
    // 如果需要增加属性的话，只需要在 appdelegate 的版本号加 1 即可自动升级
    
//MARK:-init
    ///解码record来初始化diaryInfo类
    init(record: CKRecord) throws {
        guard let date = record[.date] as? String else {
            throw RecordError.missingKey(.date)
        }
        guard let content = record[.content] as? String else {
            throw RecordError.missingKey(.content)
        }
        guard let islike = record[.islike] as? Int else {
            throw RecordError.missingKey(.islike)
        }
        guard let tags = record[.tags] as? [String] else {
            throw RecordError.missingKey(.tags)
        }
        guard let mood = record[.mood] as? String else {
            throw RecordError.missingKey(.mood)
        }
        guard let containsImage = record[.containsImage] as? Int else {
            throw RecordError.missingKey(.containsImage)
        }
        
        var imagesData:[Data?] = []
        if let imagesAsset = record[.images] as? [CKAsset] {
            for asset in imagesAsset {
                imagesData.append(asset.data)
            }
        }
        
        var rtfdData:Data?
        if let rtfdAsset = record[.rtfd] as? CKAsset{
            rtfdData = rtfdAsset.data
        }
        

        self.ckData = record.encodedSystemFields
        self.id = record.recordID.recordName
        self.date = date
        self.content = content
        self.islike = (islike != 0)
        self.tags = tags
        self.mood = mood
        self.containsImage = (containsImage != 0)
        self.rtfd = rtfdData
    }
    
    
    init(dateString:String) {
        self.id = UUID().uuidString
        self.date = dateString
        self.content = ""
        self.islike = false
        self.tags = []
        self.mood = "calm"
        self.containsImage = false
        self.rtfd = nil
    }
    
    
}
//MARK:-diaryInfo+Realm
extension diaryInfo{
    ///索引属性
    override class func indexedProperties() -> [String] {
        return ["date"]
    }
    ///主键
    override class func primaryKey() -> String? {
        return "id"
    }
}

//MARK:-Getter属性
extension diaryInfo{
    var year:Int{
        get{
            return Int(date.dateComponent(for: .year))!
        }
    }
    var month:Int{
        get{
            return Int(date.dateComponent(for: .month))!
        }
    }
    var day:Int{
        get{
            return Int(date.dateComponent(for: .day))!
        }
    }
    
    var weekDay:String{
        get{
            let weekDay =  date.dateComponent(for: .weekday)
            return weekDaysCN[weekDay] ?? weekDay
        }
    }
    
    var row:Int{
        get{
            let diries = diariesForMonth(forYear: year, forMonth: month)
            var count = 0
            for diary in diries.reversed(){
                if let d = diary{
                    if d.date == self.date{
                        return count
                    }
                    count += 1
                }
            }
            return -1
        }
    }
    
    var record: CKRecord {
        let r = CKRecord(recordType: .diaryInfo, recordID: recordID)

        r[.date] = date
        r[.content] = content
        r[.islike] = islike
        r[.tags] = tags
        r[.mood] = mood
        r[.containsImage] = containsImage
        r[.rtfd] = rtfdAsset

        return r
    }
    
    ///富文本CKAsset
    var rtfdAsset:CKAsset?{
        guard let data = rtfd else {
            return nil
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(id+"rtfd")
        do {
            try data.write(to: url)
        } catch {
            return nil
        }
        return CKAsset(fileURL: url)
    }
    
    ///富文本NSAttributedString
    var attributedString:NSAttributedString?{
        get{
            if let rtfd = self.rtfd{
                return try? NSAttributedString(data: rtfd, options: [.documentType:NSAttributedString.DocumentType.rtfd,.characterEncoding:String.Encoding.utf8], documentAttributes: nil)
            }else{
                return nil
            }
        }
    }
}
