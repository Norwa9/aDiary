//
//  LWTodoModel.swift
//  日记2.0
//
//  Created by 罗威 on 2022/1/24.
//

import Foundation
import YYModel
class LWTodoModel:NSObject, YYModel{
    /// 创建时间
    var createdDate:Date
    /// 开启提醒
    var needRemind:Bool = false
    /// 提醒时间
    var remindDate:Date?
    /// 内容
    var content:String = ""
    /// 备忘
    var note:String = ""
    /// 在富文本中的位置
    var location:Int = -1
    /// 完成状态
    var state:Int = 0 //0未完成，1已完成
    /// view的大小
    var bounds:String = ""
    /// uuid，用于注册通知
    var uuid:String
    
    
    init(location:Int,bounds:CGRect,state:Int,remindDate:Date?,content:String,note:String,needRemind:Bool,uuid:String) {
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
}
