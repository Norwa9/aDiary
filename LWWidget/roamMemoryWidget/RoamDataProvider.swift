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
        let roamDiary = db.randomElement()
        
        if let diary = roamDiary,let dateEn = DateCNToUrl(pageDateCN: diary.trueDate){
            var dateTitle = dateEn
            let pageNum = diary.indexOfPage
            if pageNum > 0{
                dateTitle += " page.\(pageNum + 1)"//转换为yyyy-MM-d page.X
            }
            let roamData = RoamData(date: dateTitle, content: diary.content)
            let jsonEncoder = JSONEncoder()
            if let storedData = try? jsonEncoder.encode(roamData) {
                defaults.set(storedData, forKey: WidgetKindKeys.RoamWidget)
                print("设置\(dateEn)的日记以展示")
            } else {
                print("roam:Failed to save roamData")
            }
        }
    }
    
    
}
