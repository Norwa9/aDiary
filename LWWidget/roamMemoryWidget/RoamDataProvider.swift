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
//        let roamDiary = db.randomElement()
        let roamDiary = LWRealmManager.shared.queryFor(dateCN: "2022年4月30日").first
        
        if let diary = roamDiary,let dateEn = DateCNToUrl(pageDateCN: diary.trueDate){
            // date
            var dateTitle = dateEn
            let pageNum = diary.indexOfPage
            if pageNum > 0{
                dateTitle += " page.\(pageNum + 1)"//转换为yyyy-MM-d page.X
            }
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
            
            let jsonEncoder = JSONEncoder()
            if let storedData = try? jsonEncoder.encode(roamData) {
                defaults.set(storedData, forKey: WidgetKindKeys.RoamWidget)
                print("设置\(dateEn)的日记以展示:\(roamData)")
            } else {
                print("roam:Failed to save roamData")
            }
        }
    }
    
    
}
