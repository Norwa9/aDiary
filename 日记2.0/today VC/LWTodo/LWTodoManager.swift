//
//  LWTodoManager.swift
//  日记2.0
//
//  Created by 罗威 on 2022/3/4.
//

import Foundation


class LWTodoManager{
    static let shared = LWTodoManager()
    
    /// 获取ddl为某日的所有todo，可以选择是否按创建日期排序
    func getTodosForDDL(ddlDate:Date,needsSort:Bool) ->[LWTodoModel]{
        var models:[LWTodoModel] = []
        for diary in LWRealmManager.shared.localDatabase{
            for todo in diary.lwTodoModels{
                if todo.needRemind
                    && Calendar.current.isDate(ddlDate, inSameDayAs: todo.remindDate)
                    && !diary.date.hasPrefix(LWTemplateHelper.shared.TemplateNamePrefix) // 过滤掉模板中的todo
                {
                    models.append(todo)
                }
            }
        }
        if needsSort{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy年M月d日"
            return models.sorted { m1, m2 in
                if let d1 = dateFormatter.date(from: m1.dateBelongs),let d2 = dateFormatter.date(from: m2.dateBelongs){
                    return d1.compare(d2) == .orderedAscending
                }else{
                    return true
                }
            }
        }else{
            return models
        }
        
    }
    
    
}
