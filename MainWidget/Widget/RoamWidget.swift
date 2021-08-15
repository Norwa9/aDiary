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
        RoamEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (RoamEntry) -> ()) {
        let entry = RoamEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [RoamEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = RoamEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct RoamEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
//    let data: RoamData
}

struct RoamPlaceholderView : View{
    var body: some View{
        Text("随机浏览日记")
    }
}



@available(iOS 14.0, *)
struct RoamEntryView : View {
    var entry: RoamProvider.Entry

    var body: some View {
        Text(entry.date, style: .time)
    }
}


struct RoamWidget: Widget {
    let kind: String = "RoamWidget"

    @available(iOS 14.0, *)
    public var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: RoamProvider()) { entry in
            RoamEntryView(entry: entry)
        }
        .configurationDisplayName("RoamWidget")
        .description("This is an 示例 widget.")
    }
}
