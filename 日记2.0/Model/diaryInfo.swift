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
    //对于普通的swift类型，@objc dynamic必须写
    
    ///引入的目的是解决离线添加的问题
    @objc dynamic var ckData:Data? = nil
    
    @objc dynamic var id:String = ""
    @objc dynamic var date:String = ""
    @objc dynamic var year:Int = 0
    @objc dynamic var month:Int = 0
    @objc dynamic var day:Int = 0
    @objc dynamic var content:String = ""
    @objc dynamic var islike:Bool = false
    @objc dynamic var mood:String = ""
    @objc dynamic var containsImage:Bool = false
    @objc dynamic var rtfd:Data? = nil
    @objc dynamic var modTime:Date? = nil
    @objc dynamic var editedButNotUploaded:Bool = false ///引入的目的是解决离线修改的同步问题(不必上传到云端)
    
    var realmTags:List<RealmString> = List<RealmString>()
    var realmImageAttrTuples = List<RealmTuple>()
    var realmTodoAttrTuples = List<RealmTuple>()
    
    
    // 如果需要增加属性的话，只需要在 appdelegate 的版本号加 1 即可自动升级
    
    
//MARK:-init
    ///解码云端取回的record
    convenience init(record: CKRecord) throws {
        self.init()//RealmSwift:Please note this says 'self' and not 'super'
        
        
        ///required keys
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
        
        /*
         随着App的更新，新版本中可能会加入新的字段。
         假设一台设备使用旧版本上传record到云端，由于旧版本缺少新字段，因此上传的record对应的字段被cloudkit自动填充为nil。
         而当新版本App从云端取回这些record时，又需要这些值为nil的新字段，因此要妥善处理nil。
         这里的做法就是，如果record中没有某个key的值，则将key赋予一个初始值。
         */
        ///optional keys
        var rtfdData:Data?
        if let rtfdAsset = record[.rtfd] as? CKAsset{
            rtfdData = rtfdAsset.data
        }
        
        var imageAttributesTuples:[(Int,Int)]
        if let dictString = record[.imageAttributesTuples] as? String{
            imageAttributesTuples = dictString2Tuples(dictString)
        }else{
            imageAttributesTuples = []
        }
        
        var todoAttributesTuples:[(Int,Int)]
        if let dictString = record[.todoAttributesTuples] as? String{
            todoAttributesTuples = dictString2Tuples(dictString)
        }else{
            todoAttributesTuples = []
        }

        self.ckData = record.encodedSystemFields
        self.id = record.recordID.recordName
        self.date = date
        self.year = Int(date.dateComponent(for: .year))!
        self.month = Int(date.dateComponent(for: .month))!
        self.day = Int(date.dateComponent(for: .day))!
        self.content = content
        self.islike = (islike != 0)
        self.realmTags.append(objectsIn: tags.map({ RealmString(value: [$0]) }))
        self.mood = mood
        self.containsImage = (containsImage != 0)
        self.rtfd = rtfdData
        self.modTime = record.modificationDate
        self.imageAttributesTuples = imageAttributesTuples
        self.todoAttributesTuples = todoAttributesTuples
    }
    
    
    convenience init(dateString:String) {
        self.init()//RealmSwift:Please note this says 'self' and not 'super'
        
        self.id = UUID().uuidString
        self.date = dateString
        self.year = Int(date.dateComponent(for: .year))!
        self.month = Int(date.dateComponent(for: .month))!
        self.day = Int(date.dateComponent(for: .day))!
        self.content = ""
        self.islike = false
        self.mood = "calm"
        self.containsImage = false
        self.rtfd = nil
        self.realmTags = List<RealmString>()
        self.modTime = Date()
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
        return "date"
    }
}

//MARK:-Getter属性
extension diaryInfo{
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
            for diary in diries{
                if diary.date == self.date{
                    return count
                }
                count += 1
            }
            return -1
        }
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
    ///注意：里面没有自定义的attribute
    var attributedString:NSAttributedString?{
        get{
            if let rtfd = self.rtfd{
                return try? NSAttributedString(data: rtfd, options: [.documentType:NSAttributedString.DocumentType.rtfd,.characterEncoding:String.Encoding.utf8], documentAttributes: nil)
            }else{
                return NSAttributedString(string: "")
            }
        }
    }
    
    
}

//MARK:-dairyInfo + todo
extension diaryInfo{
    enum todoType:Int{
        case checked = 0//已完成
        case unchecked = 1//未完成
    }
    ///解析文本，返回所有的完成todo或者返回所有的未完成todo
    func getTodos(for type:todoType)->[String]{
        guard let attributedString = self.attributedString else {return []}
        
        var todos = [String]()
        
        let mutableAttString = NSMutableAttributedString(attributedString: attributedString)
        
        //1.恢复attribute
        for tuple in todoAttributesTuples{
            mutableAttString.addAttribute(.todo, value: tuple.1, range: NSRange(location: tuple.0, length: 1))
        }
        
        //2.将复选框attribute转换为占位符方便后续操作
        let unloadAttrString = mutableAttString.unLoadCheckboxes()
        unloadAttrString.string.enumerateLines { line, _ in
            //print("unloaded:\(line)")
            let res = TextFormatter.parseTodo(line: line)
            let hasCompletedTask = res.0
            let hasIncompletedTask = res.1
            let cleanTodo = res.2//不含占位符
            let todo = res.3//含有占位符
            
            switch type{
            case .checked:
                if hasCompletedTask{
                    todos.append(todo)
                }
            case .unchecked:
                if hasIncompletedTask{
                    todos.append(todo)
                }
            }
            
            
        }
        return todos
    }
    
    func calculateTodosContentHeihgt()->CGFloat{
        let todos = self.getTodos(for: .unchecked)
        let count = todos.count
        if count > 0{
            let todoListContentHeight:CGFloat = CGFloat(todos.count) * (kTodoListItemHeight + kTodoListLineSpacing) + kTodoListLineSpacing
            return todoListContentHeight
        }else{
            return 0
        }
    }
}


