//
//  TodoWidget.swift
//  日记2.0
//
//  Created by 罗威 on 2022/2/16.
//

import WidgetKit
import SwiftUI
import Intents

struct TodoProvider: IntentTimelineProvider {
    /// 提供一个默认的视图，当网络数据请求失败或者其他一些异常的时候，用于展示
    func placeholder(in context: Context) -> TodoEntry {
        print("todo placeholder")
        return TodoEntry(date: Date(), data: [])
    }

    /// 为了在小部件库中显示小部件，WidgetKit要求提供者提供预览快照，在组件的添加页面可以看到效果
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (TodoEntry) -> ()) {
        TodoDataLoader.load { (result) in
            let todos: [todoData]
            if case .success(let fetchedData) = result {
                todos = fetchedData
            } else {
                todos = []
            }
            let entry = TodoEntry(date: Date(), data: todos)
            completion(entry)
        }
    }

    ///getTimeline
    ///方法就是Widget在桌面显示时的刷新事件，返回的是一个Timeline实例，其中包含要显示的所有条目：预期显示的时间（条目的日期）以及时间轴“过期”的时间。
    ///因为Widget程序无法像天气应用程序那样“预测”它的未来状态，因此只能用时间轴的形式告诉它什么时间显示什么数据。
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // print("todo getTimeline")
        // 午夜12点刷新
        let currentDate = Date()
        let startOfDay = Calendar.current.startOfDay(for: currentDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)
        print("todo Widget 刷新时间：\(endOfDay)")
        
        //逃逸闭包传入匿名函数 当调用completion时调用该匿名函数刷新Widget
        TodoDataLoader.load { (result) in
            let todos: [todoData]
            if case .success(let fetchedData) = result {
                todos = fetchedData
            } else {
                todos = []
            }
            print("getTimeline:读取\(todos.count)个todo")
            for todo in todos {
                print("dataBelogns:\(todo.dateBelongs)")
            }
            let entry = TodoEntry(date: currentDate, data: todos)
            
            if let endOfDay = endOfDay {
                let timeline = Timeline(entries: [entry], policy: .after(endOfDay))
                completion(timeline)// 刷新widget
            }else{
                let timeline = Timeline(entries: [entry], policy: .never)
                completion(timeline)// 刷新widget
            }
        }
    }
}

///Widget的Model，其中的Date是TimelineEntry的属性，是保存的是显示数据的时间，不可删除，需要自定义属性在它下面添加即可
struct TodoEntry: TimelineEntry {
    ///date保存的是显示数据的时间，不可删除
    let date: Date
    
    //自定义属性
    let data: [todoData]
}

///PlaceholderView用于显示默认Widget，当Widget还没获取到数据的时候会默认显示这里的布局。
struct TodoPlaceholderView : View{
    //这里是PlaceholderView - 提醒用户选择部件功能
    var body: some View{
        Text("查看今日待办")
    }
}


///Widget显示的View，在这个View上编辑界面，显示数据，也可以自定义View之后在这里调用。而且，一个Widget是可以直接支持3个尺寸的界面的。
struct TodoEntryView : View {
    //这里是Widget的类型判断
    @Environment(\.widgetFamily) var family : WidgetFamily
    var entry: TodoProvider.Entry

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemMedium:
            todoWidgetMediumView(todos: entry.data)
        case .systemLarge:
            todoWidgetLargeView(todos: entry.data)
        default :
            todoWidgetMediumView(todos: entry.data)
        }
    }
}

///Widget的入口，这里定义了Widget的Kind、Provider、View等
struct TodoWidget: Widget {
    let kind: String = WidgetKindKeys.todoWidget

    
    public var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: TodoProvider()) { entry in
            // 系统获取数据entry，然后产生展示视图EntryView
            // 例如timeLine有60个数据entry，每秒拿出一个entry，每秒调用一次这里
            TodoEntryView(entry: entry)
        }
        .configurationDisplayName("今日待办")
        .description("显示今天写下/今天截止的待办事项")
        .supportedFamilies([.systemMedium,.systemLarge])
    }
}
