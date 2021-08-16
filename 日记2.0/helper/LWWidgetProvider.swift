//
//  LWWidgetProvider.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/15.
//

import Foundation
import RealmSwift
class LWWidgetProvider{
    static let shared = LWWidgetProvider()
    private var defaults = UserDefaults.init(suiteName: "group.luowei.prefix.aDiary.content")!
    
    func setRoamData(){
        let db = LWRealmManager.shared.localDatabase
        let roamDiary = db.randomElement()
        
        if let diary = roamDiary{
            let dateEn = DateCN2En(dateCN: diary.date)
            let roamData = RoamData(date: dateEn, content: diary.content)
            let jsonEncoder = JSONEncoder()
            if let storedData = try? jsonEncoder.encode(roamData) {
                defaults.set(storedData, forKey: WidgetKindKeys.RoamWidget)
            } else {
                print("Failed to save roamData")
            }
        }
    }
    
    
}
