//
//  dataContainer.swift
//  日记2.0
//
//  Created by 罗威 on 2021/2/13.
//

import Foundation
import UIKit

//结构体用于定义保存到UserDefaults的数据的key
struct DefaultsKeys
{
    static let diaryDict  = "diaryDict3.0"
    static let hasInitialized  = "hasInitialized"
    static let tags = "tags"
    static let DiaryDictPlistKey = "ADiaryPlist.plist"
}
//单例
//它是一个用以保存app数据的类。能够在几个类之间共享。
//它设置一个观察者，当app到后台时，自动将app数据保存到UserDefaults。
//使用方法：通过语句`DataContainerSingleton.sharedDataContainer`来访问这个单例。
class DataContainerSingleton {
    static let sharedDataContainer = DataContainerSingleton()
    
    ///日记的纯文本
    var diaryDict:[String:diaryInfo] = [:]
    ///用户保存的标签
    var tags = [String]()
    
    
    var goToBackgroundObserver: AnyObject?
    init(){
        let defaults = UserDefaults.standard
        //1、读取
        tags = defaults.value(forKey: DefaultsKeys.tags) as? [String] ?? ["学习","工作","生活"]
        //TODO:-读取本地数据库，读取所有的diaryinfo到diaryDict充当数据源
        
        //2、保存
        defaults.setValue(self.tags, forKey: DefaultsKeys.tags)
        goToBackgroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification,object: nil,queue: nil){(note: Notification!) -> Void in
//            self.saveDiaryDict()
        }
    }
    
    func getTotalWordcount()->Int{
        var count = 0
        for diary in diaryDict.values{
            count += diary.content.count
        }
        return count
    }
    
//    ///持久化存储所有日记数据类的字典diaryDict
//    func saveDiaryDict(){
//        print("保存diaryDict数据")
//        let defaults = UserDefaults.standard
//        let jsonEncoder = JSONEncoder()
//        if let storedData = try? jsonEncoder.encode(self.diaryDict) {
//            defaults.set(storedData, forKey:DefaultsKeys.diaryDict)
//        } else {
//          print("Failed to save diary dict.")
//        }
//    }
    
    //如果用户修改了某个tag名称，将要更新所有使用该tag的日记中的tag名称
    func updateTags(oldTag:String,newTag:String?){
        if let newTag = newTag{//操作：更新
            for diary in DataContainerSingleton.sharedDataContainer.diaryDict.values{
                var newTags = diary.tags
                if let index = newTags.firstIndex(of: oldTag){
                    newTags[index] = newTag
                }
                
                diary.tags = newTags
            }
        }else{//操作：删除
            for diary in DataContainerSingleton.sharedDataContainer.diaryDict.values{
                var newTags = diary.tags
                if let deleteIndex = newTags.firstIndex(of: oldTag){
                    newTags.remove(at: deleteIndex)
                }
                diary.tags = newTags
            }

        }
        
    }
    
    //MARK:-导出diaryDict为plist文件
    ///存储diaryDict的plist文件。
    ///返回本地文件地址的URL
    func savePlistFile()->URL{
        let baseURL: URL
        let fileManager = FileManager.default
        baseURL = fileManager.temporaryDirectory

        let url = baseURL.appendingPathComponent("ADiary.plist")

        if !fileManager.fileExists(atPath: url.path) {
            print("Creating store file at \(url.path)")

            if !fileManager.createFile(atPath: url.path, contents: nil, attributes: nil) {
                print("Failed to create store file at \(url.path)")
            }
        }
        
        do {
            let data = try PropertyListEncoder().encode(self.diaryDict)
            try data.write(to: url)
        } catch {
            print("fail to save diaryDict")
        }
        
        return url
    }
}


