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
        // 1. 获取ddl为今日的所有todo
        let todoModels = LWTodoManager.shared.getTodosForDDL(ddlDate: Date(),needsSort: true)
        var todoDataArray:[todoData] = []
        for model in todoModels{
            let todoData = todoData(
                id: model.uuid,
                state: model.state,
                content: model.content,
                dateBelongs: DateCNToUrl(pageDateCN: model.dateBelongs) ?? "",
                remindDate: model.remindDate,
                needRemind: model.needRemind
            )
            todoDataArray.append(todoData)
        }
        
        // 2. 获取今日创建的所有todo
        for todayPage in LWRealmManager.shared.queryAllPages(ofDate: GetTodayDate()){
            for model in todayPage.lwTodoModels{
                if todoDataArray.contains(where: { todo in
                    todo.id == model.uuid
                }){
                    continue
                }
                let todoData = todoData(
                    id: model.uuid,
                    state: model.state,
                    content: model.content,
                    dateBelongs: DateCNToUrl(pageDateCN: model.dateBelongs) ?? "",
                    remindDate: model.remindDate,
                    needRemind: model.needRemind
                )
                todoDataArray.append(todoData)
            }
            
        }
        
        print("显示todo个数：\(todoDataArray.count)")
        
        
        // encode
        let jsonEncoder = JSONEncoder()
        if let storedData = try? jsonEncoder.encode(todoDataArray) {
            defaults.set(storedData, forKey: WidgetKindKeys.todoWidget)
            print("设置todo以展示")
        } else {
            print("todo:Failed to save roamData")
        }
    }
    
    
}
