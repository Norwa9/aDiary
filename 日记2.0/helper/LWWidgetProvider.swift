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
            defaults.setValue(diary.content, forKey: "roam")
        }
    }
    
    
}
