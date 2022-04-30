//
//  RoamDataProvider.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/15.
//

import Foundation
import RealmSwift

class RoamDataProvider{
    static let shared = RoamDataProvider()
    
    private var defaults = UserDefaults.init(suiteName: "group.luowei.prefix.aDiary.content")!
    
    func setRoamData(){
        let db = LWRealmManager.shared.localDatabase
        var randDiaries:[diaryInfo] = []
        let numPerSave = 12 // 每次保存12篇随机日记
        while(true){
            if let randDiary = db.randomElement(){
                randDiaries.append(randDiary)
            }
            if randDiaries.count == numPerSave{
                break
            }
        }
//        let roamDiary = LWRealmManager.shared.queryFor(dateCN: "2022年4月30日").first // for debug
//        print("保存12篇随机日记：")
//        print(randDiaries.count)
//        print(randDiaries)
        var roamDataArray:[RoamData] = []
        for diary in randDiaries{
            if let dateEn = DateCNToUrl(pageDateCN: diary.trueDate){
                // date
                let dateTitle = dateEn
                // image
                var imageData:Data?
                if !diary.scalableImageModels.isEmpty,let randomImageModel = diary.scalableImageModels.randomElement(){
                    let image = ImageTool.shared.loadImage(uuid: randomImageModel.uuid)
                    imageData = image?.jpegData(compressionQuality: 1.0)
                }
                // content
                let content = diary.content
                // emojis
                let emojis = diary.emojis
                // tags
                let tags = diary.tags
                
                // Model
                let roamData = RoamData(date: dateTitle, content: content, tags: tags, emojis: emojis, imageData: imageData)
                
                roamDataArray.append(roamData)
            }
        }
        let jsonEncoder = JSONEncoder()
        if let storedData = try? jsonEncoder.encode(roamDataArray) {
            defaults.set(storedData, forKey: WidgetKindKeys.RoamWidget)
            print("设置\(roamDataArray.count)篇日记以展示")
        } else {
            print("roam:Failed to save roamDataArray")
        }
        
    }
    
    
}
