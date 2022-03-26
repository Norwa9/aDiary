//
//  diaryInfo+pageMetaData.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/26.
//

import Foundation
import UIKit
import YYModel

class pageMetaData:NSObject,Codable,YYModel{
    /// 页面下标
    @objc dynamic var pageIndex:Int = 0
    
    /// 页面备注名
    @objc dynamic var pageRemark:String = ""
    
    
    // in case of ' Use of unimplemented initializer 'init()' '
    override init() {
        super.init()
    }
    
    init(pageIndex:Int) {
        self.pageIndex = pageIndex
//        self.uuid = uuid
//        self.createdDate = createdDate
//        self.location = location
//        self.soundFileName = soundFileName
//        self.soundFileSize = soundFileSize
//        self.soundFileLength = soundFileLength
        super.init()
    }
    
}


//MARK:-getter属性
extension diaryInfo{
    ///从json字符串里解析出LWSoundModel数组
    var metaData:pageMetaData{
        get{
            // decode
            let jsonString = pageMetaDataJSON
            if let pageMetaData = pageMetaData.yy_model(withJSON: jsonString){
                return pageMetaData
            }else{
                // 默认初始化
                // 从date字段获取页面的id。（注意区分模板与日记）
                var pageIndex:Int
                if date.starts(with: LWTemplateHelper.shared.TemplateNamePrefix){
                    pageIndex = -1
                }else{
                    pageIndex = date.parseDateSuffix() // 否者返回0（主页面）或者>0（子页面）
                }
                print("default MetaData: 日期:\(date),pageIndex:\(pageIndex)")
                let defaultMetaData = pageMetaData(pageIndex: pageIndex)
                
                LWRealmManager.shared.update {
                    self.metaData = defaultMetaData // 第一次访问，赋默认值
                }
                
                return defaultMetaData
            }
        }
        set{
            // encode
            let jsonEncoder = JSONEncoder()
            if let modelsData = try? jsonEncoder.encode(newValue) {
                pageMetaDataJSON = String(data: modelsData, encoding: String.Encoding.utf8)!
            } else {
                print("Failed to Encode pageMetaData")
                pageMetaDataJSON = ""
            }
        }
    }
}
