//
//  todoWidgetView.swift
//  日记2.0
//
//  Created by 罗威 on 2022/2/16.
//

import Foundation
import SwiftUI
import WidgetKit

// MARK: title
struct titleView: View{
    var checkedCount:Int
    var totalCount:Int
    var body: some View{
        VStack(spacing:5){
            HStack(){
                Text("今日待办")
                    .font(.custom("DIN Alternate", size: 17))
                Spacer()
                Text("完成: \(checkedCount)/\(totalCount)")
                    .font(.custom("DIN Alternate", size: 17))
                    .foregroundColor(.secondary)
            }
            Divider()
        }
        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
        .frame(width: 320, height: 30, alignment: .center)
    }
}

// MARK: -todo
struct todoListView: View{
    var todos: [todoData]
    var family: WidgetFamily
    var height:CGFloat{
        if family == .systemMedium{
            return 100
        }else{
            return 290
        }
    }
    var body: some View{
        VStack(spacing:5){
            ForEach(todos) { todo in
                Link(destination: URL(string: todo.dateBelongs)!) {
                    // URL不能有中文
                    todoRow(todo: todo)
                }
                
            }
        }
        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
        .frame(width: 320, height: height, alignment: .top)
    }
}
struct todoRow: View{
    var todo:todoData
    var body: some View{
        HStack(spacing:0){
            if todo.state == 0{
                Image("checkbox_empty", bundle: nil)
                    .resizable()
                    .frame(width: 20, height: 20, alignment: .center)
            }else{
                Image("checkbox", bundle: nil)
                    .resizable()
                    .frame(width: 20, height: 20, alignment: .center)
            }
            Text(todo.content)
                .foregroundColor((todo.state == 1) ? .secondary : nil)
                .strikethrough((todo.state == 1) ? true : false, color: .secondary)
                .multilineTextAlignment(.leading)
                .font(.custom("DIN Alternate", size: 12))
                .lineLimit(1)
            Spacer(minLength: 15)
            
            if todo.needRemind{
                Text(getDateString(date:todo.remindDate))
                    .font(.custom("DIN Alternate", size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
}



// MARK: 中号
struct todoWidgetMediumView: View {
    var todos:[todoData]
    var body: some View {
        VStack(spacing: 5){
            titleView(checkedCount: getCheckedNum(todos: todos), totalCount: todos.count)
            todoListView(todos: getOrderModels(todos: todos, family: .systemMedium), family: .systemMedium)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: 大号
struct todoWidgetLargeView: View {
    var todos:[todoData]
    var body: some View {
        VStack(spacing: 5){
            titleView(checkedCount: getCheckedNum(todos: todos), totalCount: todos.count)
            todoListView(todos: getOrderModels(todos: todos, family: .systemLarge),family: .systemLarge)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: private func
/// 处理models
private func getOrderModels(todos:[todoData],family:WidgetFamily) -> [todoData]{
    var models:[todoData] = []
    // 未完成排前
    models = todos.sorted(by: { t1, t2 in
        if t1.state < t2.state{
            return true
        }else{
            return false
        }
    })
    var max = 0
    if family == .systemMedium{
        max = 4
    }else{
        max = 12
    }
    // 最多显示max个
    if models.count > max{
        models = models.dropLast(models.count - max)
    }
    return models
}

private func getCheckedNum(todos:[todoData])->Int{
    var checkedNum = 0
    for model in todos{
        if model.state == 1{
            checkedNum += 1
        }
    }
    return checkedNum
}

private func getDateString(date:Date)->String{
    let dateFormatter = DateFormatter()
    var res = ""
    if Calendar.current.isDate(date, inSameDayAs: Date()){
        dateFormatter.dateFormat = "hh:mm"
        let datetring = dateFormatter.string(from: date)
        res = "今天 " + datetring
    }else{
        dateFormatter.dateFormat = "M/dd hh:mm"
        res = dateFormatter.string(from: date)
    }
    return res
}

//private func convertToLink(dateCN:String)->String{
//
//}


private func generateModels()->[todoData]{
    var models:[todoData] = []
    for i in 0..<6{
        models.append(todoData(id: "2022", state: 0, content: "测试待办padding(: 10))", dateBelongs: "2022",remindDate: Date(),needRemind: false))
    }
    for i in 0..<6{
        models.append(todoData(id: "2022", state: 1, content: "测试待办padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))", dateBelongs: "2022",remindDate: Date(),needRemind: false))
    }
    return models
}

struct todoWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        todoWidgetMediumView(todos: generateModels())
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        todoWidgetLargeView(todos: generateModels())
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
