//
//  todoWidgetView.swift
//  日记2.0
//
//  Created by 罗威 on 2022/2/16.
//

import Foundation
import SwiftUI
import WidgetKit


struct todoRow: View{
    var todo:todoData
    var body: some View{
        HStack{
            Text(todo.content)
                .multilineTextAlignment(.leading)
                .font(.custom("DIN Alternate", size: 15))
                .widgetURL(URL(string: "\(todo.dateBelongs)"))
            Spacer()
        }
    }
}
struct todoWidgetView: View {
    var todos : [todoData]
    var body: some View {
        VStack{
            ForEach(todos) { todo in
                todoRow(todo: todo)
            }
        }
    }
}

let testDatas:[todoData] = [
    todoData(id: "2022", state: 0, content: "测试待办", dateBelongs: "2022"),
    todoData(id: "2022", state: 0, content: "测试待办", dateBelongs: "2022"),
    todoData(id: "2022", state: 0, content: "测试待办", dateBelongs: "2022"),
    todoData(id: "2022", state: 0, content: "测试待办", dateBelongs: "2022"),
    todoData(id: "2022", state: 0, content: "测试待办", dateBelongs: "2022"),
    todoData(id: "2022", state: 0, content: "测试待办", dateBelongs: "2022"),
    todoData(id: "2022", state: 0, content: "测试待办", dateBelongs: "2022")
]

struct todoWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        todoWidgetView(todos: testDatas)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
