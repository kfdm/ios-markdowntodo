//
//  TodayWidget.swift
//  TodayWidget
//
//  Created by Paul Traylor on 2021/07/25.
//  Copyright © 2021 Paul Traylor. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents
import EventKit
import Combine

struct Provider: TimelineProvider {

    @State private var subscriptions = Set<AnyCancellable>()
    let eventStore = EventStore()

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        print(eventStore.authorized)
        print("getSnapshot")
        let predicate = eventStore.upcomingReminders()
        eventStore.publisher(for: predicate)
            .map { SimpleEntry(date: Date(), reminders: $0) }
            .print()
            .sink(receiveValue: completion)
            .store(in: &subscriptions)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        print(eventStore.authorized)
        print("getTimeline")
        let now = Date()
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 1, to: now)!
        let predicate = eventStore.upcomingReminders()
        eventStore.publisher(for: predicate)
            .map { SimpleEntry(date: now, reminders: $0) }
            .map { Timeline(entries: [$0], policy: .after(nextUpdateDate)) }
            .print()
            .sink(receiveValue: completion)
            .store(in: &subscriptions)
    }

    func placeholder(in context: Context) -> SimpleEntry {
        print("placeholder")
        return SimpleEntry(date: Date(), reminders: [])
    }

}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let reminders: [EKReminder]
}

struct TodayWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        List {
            Text("Test")
            Text(entry.date, style: .time)
            ForEach(entry.reminders) { reminder in
                Text(reminder.title)
            }
        }
    }
}

@main
struct TodayWidget: Widget {
    let kind: String = "TodayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TodayWidgetEntryView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("Today View")
        .description("Today's Tasks.")
    }
}

struct TodayWidget_Previews: PreviewProvider {
    static var data = SimpleEntry(date: Date(), reminders: [])
    static var previews: some View {
        TodayWidgetEntryView(entry: data)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
