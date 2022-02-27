//
//  todoDataProvider.swift
//  日记2.0
//
//  Created by 罗威 on 2022/2/16.
//

import Foundation
import RealmSwift

class todoDataProvider{
    static let shared = todoDataProvider()
    
    private var defaults = UserDefaults.init(suiteName: "group.luowei.prefix.aDiary.content")!
    
    func setData(){
        if let todayDiary = LWRealmManager.shared.queryFor(dateCN: GetTodayDate()).first{
            var todoDataArray:[todoData] = []
            for model in todayDiary.lwTodoModels{
                let todoData = todoData(
                    id: model.uuid,
                    state: model.state,
                    content: model.content,
                    dateBelongs: model.dateBelongs,
                    remindDate: model.remindDate,
                    needRemind: model.needRemind
                )
                todoDataArray.append(todoData)
            }
            let jsonEncoder = JSONEncoder()
            if let storedData = try? jsonEncoder.encode(todoDataArray) {
                defaults.set(storedData, forKey: WidgetKindKeys.todoWidget)
                print("设置todo以展示")
            } else {
                print("todo:Failed to save roamData")
            }
                    
        }
    }
    
    
}
