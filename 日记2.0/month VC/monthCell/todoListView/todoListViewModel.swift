//
//  todoListViewModel.swift
//  日记2.0
//
//  Created by 罗威 on 2022/1/27.
//

import Foundation

class todoListViewModel{
    var diaryModel:diaryInfo
    var todoListView:TodoListView
    init(diaryModel:diaryInfo, todoListView:TodoListView){
        self.diaryModel = diaryModel
        self.todoListView = todoListView
    }
    
    /// 获取LWTodoViewModel数组
    func getDataSource() -> [LWTodoViewModel]{
        let filteredModels = diaryModel.lwTodoModels.filter { model in
            switch userDefaultManager.todoListViewStyle{
            case 0: // 默认
                return true
            case 1: // 完成后消失
                return model.state == 0
            case 2: // 完成后置底
                return true
            default:
                return true
            }
        }
        //重排序
        var orderedModels = filteredModels
        if userDefaultManager.todoListViewStyle == 2{
            // 1比较完成状态
            // 2比较是否需要提醒
            // 3比较提醒时间
            orderedModels = filteredModels.sorted { m1, m2 in
                if m1.state <  m2.state{
                    return true
                }else if m1.state ==  m2.state{
                    if m1.needRemind && m2.needRemind{
                        // 都设置了提醒
                        return m1.remindDate.compare(m2.remindDate) == .orderedAscending
                    }else if m1.needRemind{
                        return true
                    }else if m2.needRemind{
                        return false
                    }else{
                        // 都没设置提醒
                        return m1.createdDate.compare(m2.createdDate) == .orderedAscending
                    }
                }else{
                    return false
                }
            }
            
            // 只比较完成状态
            orderedModels = filteredModels.sorted { m1, m2 in
                if m1.state <  m2.state{
                    return true
                }else{
                    return false
                }
            }
        }
        
        for model in filteredModels {
            print("model.content:\(model.content)")
        }
        
        let viewModels:[LWTodoViewModel] = orderedModels.map { model in
            let viewModel = LWTodoViewModel(model: model)
            viewModel.todoViewStyle = 1 // 1表示todoView在todoListView中显示
            viewModel.todoListView = todoListView
            return viewModel
        }
        return viewModels
    }
    
}
