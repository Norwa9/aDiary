//
//  LWDiary.swift
//  日记2.0
//
//  Created by 罗威 on 2021/7/5.
//

import Foundation
import UIKit
import CloudKit


class diaryInfo:Codable{
    var ckData:Data? = nil
    
    var id:String
    var date:String
    var content:String
    var islike:Bool
    var tags:[String]
    var mood:moodTypes
    var containsImage:Bool
    var images:[Data?]
    var rtfd:Data?
    
    struct  RecordError:LocalizedError {
        var localizedDescription:String
        
        static func missingKey(_ key: RecordKey) -> RecordError {
            RecordError(localizedDescription: "Missing required key: \(key.rawValue)")
        }
    }
    
    var recordID:CKRecord.ID{
        return CKRecord.ID(recordName: id,zoneID: SyncConstants.customZoneID)
    }
    
    var imageAsset: [CKAsset] {
        var count = 0
        var imageAsset:[CKAsset] = []
        for data in images{
            guard let data = data else {
                continue
            }
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(id+"image\(count)")
            do {
                try data.write(to: url)
            } catch {
                continue
            }
            //注意：CloudKit的提交的文件的fileURL必须指向本地文件
            imageAsset.append(CKAsset(fileURL: url))
            count += 1
        }
        return imageAsset
    }
    
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
    
    var record: CKRecord {
        let r = CKRecord(recordType: .diaryInfo, recordID: recordID)

        r[.date] = date
        r[.content] = content
        r[.islike] = islike
        r[.tags] = tags
        r[.mood] = mood.rawValue
        r[.containsImage] = containsImage
        r[.images] = imageAsset
        r[.rtfd] = rtfdAsset

        return r
    }
    
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
        self.mood = moodTypes(rawValue: mood)!
        self.containsImage = (containsImage != 0)
        self.images = imagesData
        self.rtfd = rtfdData
    }
    
    
    init(dateString:String) {
        self.id = UUID().uuidString
        self.date = dateString
        self.content = ""
        self.islike = false
        self.tags = []
        self.mood = .calm
        self.containsImage = false
        self.images = []
        self.rtfd = nil
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
