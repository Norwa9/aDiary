//
//  migrationHelper.swift
//  日记2.0
//
//  Created by 罗威 on 2021/7/31.
//

import Foundation
class MigrationHelper{
    ///0731,1.6->2.0
    ///从pList文件中读取diaryDict,并解析diaryDict转成模型diaryInfo
    static func parsePlistFile(){
        guard let path:String = Bundle.main.path(forResource: "ADiary", ofType:"plist"),let allDict:NSDictionary = NSDictionary(contentsOfFile: path) else{
            print("读取ADiary.plist失败")
            return
        }
        
        let num = allDict.allKeys.count
        var count = 0
        for key in allDict.allKeys{
            guard let date = key as? String,
                  let dict  = allDict[date] as? NSDictionary,
                  let content = dict["content"] as? String,
                  let tags = dict["tags"] as? [String]
            else{
                print("解析失败")
                return
            }
            
            let model = diaryInfo(dateString: date)
            model.content = content
            model.tags = tags
            LWRealmManager.shared.add(model)
            count += 1
            print("导入进度：\(count)/\(num)")
        }
        ///读取完所有数据后，更新tag
        dataManager.shared.updateTags()
    }
    
}
