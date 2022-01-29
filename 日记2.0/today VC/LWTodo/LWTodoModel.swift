//
//  LWTodoModel.swift
//  日记2.0
//
//  Created by 罗威 on 2022/1/24.
//

import Foundation
import YYModel
import AttributedString

class LWTodoModel:NSObject,Codable,YYModel{ // YYModel 必须加 @objc dynamic修饰，否则无法被解码
    /// 创建时间
    @objc dynamic var createdDate:Date = Date()
    /// 开启提醒
    @objc dynamic var needRemind:Bool = false
    /// 提醒时间
    @objc dynamic var remindDate:Date = Date()
    /// 内容
    @objc dynamic var content:String = ""
    /// 备忘
    @objc dynamic var note:String = ""
    /// 在富文本中的位置
    @objc dynamic var location:Int = -1
    /// 完成状态
    @objc dynamic var state:Int = 0 //0未完成，1已完成
    /// view的大小
    @objc dynamic var bounds:String = ""
    /// uuid，用于注册通知
    @objc dynamic var uuid:String = ""
    
    override init() {
        super.init()
    }
    
    init(location:Int,bounds:CGRect,state:Int,remindDate:Date,content:String,note:String,needRemind:Bool,uuid:String) {
        self.createdDate = Date()
        self.needRemind = needRemind
        self.remindDate = remindDate
        self.content = content
        self.note = note
        self.location = location
        self.state = state
        let boundsSring = "\(bounds.origin.x),\(bounds.origin.y),\(bounds.size.width),\(bounds.size.height)"
        self.bounds = boundsSring
        self.uuid = uuid
        super.init()
    }
    
    func modelCustomTransform(from dic: [AnyHashable : Any]) -> Bool {
        // 将model保存的时间戳转换为Date
        if let remindDateTimeStamp = dic["remindDate"] as? NSNumber,
           let createdDateTimeStamp = dic["createdDate"] as? NSNumber
        {
            
            
            self.remindDate = Date.init(timeIntervalSinceReferenceDate: TimeInterval(remindDateTimeStamp.floatValue))
            self.createdDate = Date.init(timeIntervalSinceReferenceDate: TimeInterval(createdDateTimeStamp.floatValue))
            // print("转换时间戳到Date，remindDate：\(remindDate),createdDate：\(createdDate)")
            return true
        }
        
        return false
    }
}
