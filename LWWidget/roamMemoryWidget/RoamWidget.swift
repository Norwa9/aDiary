//
//  LWWidget.swift
//  LWWidget
//
//  Created by 罗威 on 2022/2/7.
//

import WidgetKit
import SwiftUI
import Intents

struct RoamProvider: IntentTimelineProvider {
    /// 提供一个默认的视图，当网络数据请求失败或者其他一些异常的时候，用于展示
    func placeholder(in context: Context) -> RoamEntry {
        RoamEntry(date: Date(), data: RoamData(date: "", content: "随机浏览日记"))
    }

    /// 为了在小部件库中显示小部件，WidgetKit要求提供者提供预览快照，在组件的添加页面可以看到效果
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (RoamEntry) -> ()) {
        RoamDataLoader.load { (result) in
            let roamData: RoamData
            if case .success(let fetchedData) = result {
                roamData = fetchedData
            } else {
                roamData = RoamData(date: "", content: "很遗憾本次更新失败,等待下一次更新.")
            }
            let entry = RoamEntry(date: Date(), data: roamData)
            completion(entry)
        }
    }

    ///getTimeline
    ///方法就是Widget在桌面显示时的刷新事件，返回的是一个Timeline实例，其中包含要显示的所有条目：预期显示的时间（条目的日期）以及时间轴“过期”的时间。
    ///因为Widget程序无法像天气应用程序那样“预测”它的未来状态，因此只能用时间轴的形式告诉它什么时间显示什么数据。
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        //每5分钟获取数据显示，之后又重新运行一次getTimeline.(getTimeline最高的刷新频率是5分钟一次)
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
        
        //逃逸闭包传入匿名函数 当调用completion时调用该匿名函数刷新Widget
        RoamDataLoader.load { (result) in
            let roamData: RoamData
            if case .success(let fetchedData) = result {
                roamData = fetchedData
            } else {
                roamData = RoamData(date: "", content: "很遗憾本次更新失败,等待下一次更新.")
            }
            let entry = RoamEntry(date: currentDate, data: roamData)
            //entries提供了下次更新的数据,policy提供了下次更新的时间。
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            // policy有: .atEnd, .after, .never
            // 当timeLine没有数据时，系统重新调用getTimeline
            // 这里，timeLine只有一个数据，且5分钟拿出一个数据，也就是过5分钟timeLine就没数据就要调用getTimeline重新获取数据了
            completion(timeline)// 刷新widget
        }
    }
}

///Widget的Model，其中的Date是TimelineEntry的属性，是保存的是显示数据的时间，不可删除，需要自定义属性在它下面添加即可
struct RoamEntry: TimelineEntry {
    ///date保存的是显示数据的时间，不可删除
    let date: Date
    
    //自定义属性
    let data: RoamData
}

///PlaceholderView用于显示默认Widget，当Widget还没获取到数据的时候会默认显示这里的布局。
struct RoamPlaceholderView : View{
    //这里是PlaceholderView - 提醒用户选择部件功能
    var body: some View{
        Text("随机浏览日记")
    }
}


///Widget显示的View，在这个View上编辑界面，显示数据，也可以自定义View之后在这里调用。而且，一个Widget是可以直接支持3个尺寸的界面的。
struct RoamEntryView : View {
    //这里是Widget的类型判断
    @Environment(\.widgetFamily) var family : WidgetFamily
    var entry: RoamProvider.Entry

    @ViewBuilder
    var body: some View {
        RoamView(roamData: RoamData(date: entry.data.date, content: entry.data.content))
    }
}

///Widget的入口，这里定义了Widget的Kind、Provider、View等
struct RoamWidget: Widget {
    let kind: String = WidgetKindKeys.RoamWidget

    
    public var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: RoamProvider()) { entry in
            // 系统获取数据entry，然后产生展示视图RoamEntryView
            // 例如timeLine有60个数据entry，每秒拿出一个entry，每秒调用一次这里
            RoamEntryView(entry: entry)
        }
        .configurationDisplayName("回忆")
        .description("显示一篇随机的日记(开发中...)")
        .supportedFamilies([.systemMedium,.systemLarge])
    }
}
