//
//  LWSoundModel.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/19.
//

import Foundation
import UIKit
import YYModel
import AttributedString

class LWSoundModel:NSObject,Codable,YYModel{
    /// uuid
    @objc dynamic var uuid:String = ""
    /// 创建时间
    @objc dynamic var createdDate:Date = Date()
    /// 音频文件插入的位置
    @objc dynamic var location:Int = -1
    /// 音频文件名
    @objc dynamic var soundFileName:String = "新录音"
    /// 音频文件大小
    @objc dynamic var soundFileSize:String = ""
    /// 音频文件时间长度
    @objc dynamic var soundFileLength:CGFloat = 0.0
    
    // in case of ' Use of unimplemented initializer 'init()' '
    override init() {
        super.init()
    }
    
    init(uuid:String,createdDate:Date,location:Int,soundFileName:String,soundFileSize:String,soundFileLength:CGFloat) {
        self.uuid = uuid
        self.createdDate = createdDate
        self.location = location
        self.soundFileName = soundFileName
        self.soundFileSize = soundFileSize
        self.soundFileLength = soundFileLength
        super.init()
    }
    
    func modelCustomTransform(from dic: [AnyHashable : Any]) -> Bool {
        // 将model保存的时间戳转换为Date
        if let createdDateTimeStamp = dic["createdDate"] as? NSNumber
        {
            self.createdDate = Date.init(timeIntervalSinceReferenceDate: TimeInterval(createdDateTimeStamp.floatValue))
            // print("转换时间戳到Date，remindDate：\(remindDate),createdDate：\(createdDate)")
            return true
        }
        
        return false
    }
    
    /// 复制一份LWSoundModel
    func copy()->LWSoundModel{
        let newuuid = UUID().uuidString
        let model = LWSoundModel(uuid: newuuid, createdDate: createdDate,location: location, soundFileName: soundFileName, soundFileSize: soundFileSize, soundFileLength: soundFileLength)
        
        
        if let soundData = LWSoundHelper.shared.loadAudio(uuid: uuid){
            let sound = LWSound(uuid: newuuid, soundData: soundData)
            LWSoundHelper.shared.addAudios(audios: [sound])
        }
        
        return model
    }
}
