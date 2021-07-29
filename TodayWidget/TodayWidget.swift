//
//  TodayWidget.swift
//  TodayWidget
//
//  Created by Paul Traylor on 2021/07/29.
//  Copyright © 2021 Paul Traylor. All rights reserved.
//

import WidgetKit
import SwiftUI
import EventKit
import Combine

struct Provider: TimelineProvider {
    @State private var subscriptions = Set<AnyCancellable>()
        let eventStore = EventStore()


    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), reminders: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), reminders: [])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, reminders: [])
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let reminders: [EKReminder]
}

struct TodayWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            ForEach(entry.reminders) { reminder in
                HStack {
                    Text(reminder.title)
                    Text("\(reminder.dueDate)")
                }

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
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("Today View")
        .description("Tasks due today.")
    }
}

struct TodayWidget_Previews: PreviewProvider {
    static var previews: some View {
        TodayWidgetEntryView(entry: SimpleEntry(date: Date(), reminders: previewEntries()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}


extension TodayWidget_Previews {
    static func previewEntries() -> [EKReminder] {
        var entries = [EKReminder]()
        let currentDate = Date()
        let eventStore = EKEventStore()
        let calendar = EKCalendar(for: .reminder, eventStore: eventStore)
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let r = EKReminder(eventStore: eventStore)
            r.calendar = calendar
            r.title = "Task \(hourOffset)"
            r.dueDateComponents = Calendar.current.dateComponents(from: entryDate)
            entries.append(r)
        }

        return entries
    }
}
