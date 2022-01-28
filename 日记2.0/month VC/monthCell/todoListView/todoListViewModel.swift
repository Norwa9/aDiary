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
    
    func getDataSource() -> [LWTodoViewModel]{
        let filteredViewModel = diaryModel.lwTodoModels.filter { model in
            switch userDefaultManager.todoListViewStyle{
            case 0: // 默认
                return true
            case 1: // 完成后消失
                return model.state == 0
            case 2: // 完成后置底
                //TODO: 重排序
                return true
            default:
                return true
            }
        }
        let viewModels:[LWTodoViewModel] = filteredViewModel.map { model in
            let viewModel = LWTodoViewModel(model: model)
            viewModel.todoViewStyle = 1 // 1表示todoView在todoListView中显示
            viewModel.todoListView = todoListView
            return viewModel
        }
        return viewModels
    }
    
}
