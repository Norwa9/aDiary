//
//  diaryInfo+Todo.swift
//  日记2.0
//
//  Created by yy on 2021/7/21.
//

import Foundation
import UIKit

//MARK:-dairyInfo + todo
enum todoType:Int{
    case unchecked = 0//已完成
    case checked = 1//未完成
    case all = 2//全部
}

//MARK:-getter属性
extension diaryInfo{
    var todos:[String]{
        get {
          return realmTodos.map { $0.stringValue }
        }
        set {
            realmTodos.removeAll()
            realmTodos.append(objectsIn: newValue.map({ RealmString(value: [$0]) }))
        }
    }
    
    ///从json字符串里解析出ScalableImageModel数组
    var lwTodoModels:[LWTodoModel]{
        get{
            let jsonString = todoModelsJSON
            if let models = NSArray.yy_modelArray(with: LWTodoModel.self, json:jsonString ) as? [LWTodoModel]{
//                print("json转models，得到\(models.count)个model")
//                for model in models {
//                    print(model.createdDate)
//                }
                return models
            }else{
                return []
            }
        }
        set{
            let jsonEncoder = JSONEncoder()
            if let modelsData = try? jsonEncoder.encode(newValue) {
                todoModelsJSON = String(data: modelsData, encoding: String.Encoding.utf8)!
                // print("todoModelsJSON:\(todoModelsJSON)")
            } else {
                print("Failed to Encode models")
                todoModelsJSON = ""
            }
        }
    }
}



//MARK:-方法
extension diaryInfo{
    ///解析文本，返回所有的完成todo或者返回所有的未完成todo
    func getTodos(for type:todoType,from aString:NSAttributedString?,currentTodoAttributes:[(Int,Int)])->[String]{
        guard let attributedString = aString else {return []}
        
        var todos = [String]()
        
        let mutableAttString = NSMutableAttributedString(attributedString: attributedString)
        
        //1.恢复attribute
        for tuple in currentTodoAttributes{
            mutableAttString.addAttribute(.todo, value: tuple.1, range: NSRange(location: tuple.0, length: 1))
        }
        
        //2.将复选框attribute转换为占位符方便后续操作
        let unloadAttrString = mutableAttString.unLoadCheckboxes()
        unloadAttrString.string.enumerateLines { line, _ in
            //print("unloaded:\(line)")
            let res = TextFormatter.parseTodo(line: line)
            let hasCompletedTask = res.0
            let hasIncompletedTask = res.1
            let cleanTodo = res.2//不含占位符
            let todo = res.3//含有占位符
            
            switch type{
            case .checked:
                if hasCompletedTask{
                    todos.append(todo)
                }
            case .unchecked:
                if hasIncompletedTask{
                    todos.append(todo)
                }
            case .all:
                break
            }
        }
        return todos
    }
    
    func calculateTodosContentHeihgt()->CGFloat{
        let todos = self.todos
        let count = todos.count
        if count > 0{
            let todoListContentHeight:CGFloat = CGFloat(todos.count) * (layoutParasManager.shared.todoListItemHeight + layoutParasManager.shared.todoListLineSpacing) + layoutParasManager.shared.todoListLineSpacing
            return todoListContentHeight
        }else{
            return 0
        }
    }
}
