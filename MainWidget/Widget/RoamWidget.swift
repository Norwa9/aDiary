//
//  RoamWidget.swift
//  日记2.0
//
//  Created by 罗威 on 2021/8/13.
//

import WidgetKit
import SwiftUI
import Intents

@available(iOS 14.0, *)
struct RoamProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> RoamEntry {
        RoamEntry(date: Date(), data: RoamData(content: "随机浏览日记"))
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (RoamEntry) -> ()) {
        let entry = RoamEntry(date: Date(), data: RoamData(content: "随机浏览日记"))
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 60, to: currentDate)!
        
        RoamDataLoader.load { (result) in
            let roamData: RoamData
            if case .success(let fetchedData) = result {
                roamData = fetchedData
            } else {
                roamData = RoamData(content: "很遗憾本次更新失败,等待下一次更新.")
            }
            let entry = RoamEntry(date: currentDate, data: roamData)
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
    }
}

struct RoamEntry: TimelineEntry {
    let date: Date
    let data: RoamData
}

struct RoamPlaceholderView : View{
    //这里是PlaceholderView - 提醒用户选择部件功能
    var body: some View{
        Text("随机浏览日记")
    }
}

@available(iOS 14.0, *)
struct RoamEntryView : View {
    //这里是Widget的类型判断
    @Environment(\.widgetFamily) var family : WidgetFamily
    var entry: RoamProvider.Entry

    @ViewBuilder
    var body: some View {
        RoamView(content: entry.data.content)
    }
}

struct RoamWidget: Widget {
    let kind: String = "RoamWidget"

    @available(iOS 14.0, *)
    public var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: RoamProvider()) { entry in
            RoamEntryView(entry: entry)
        }
        .configurationDisplayName("回忆")
        .description("随机查看一篇日记")
    }
}
