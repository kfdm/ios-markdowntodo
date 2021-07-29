//
//  TodayWidget.swift
//  TodayWidget
//
//  Created by Paul Traylor on 2021/07/29.
//  Copyright © 2021 Paul Traylor. All rights reserved.
//

import Combine
import EventKit
import SwiftUI
import WidgetKit

private var subscriptions = Set<AnyCancellable>()

struct Provider: TimelineProvider {
    let eventStore = EventStore()

    func placeholder(in context: Context) -> SimpleEntry {
        print("placeholder \(eventStore.authorized)")
        return SimpleEntry(date: Date(), reminders: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        print("getSnapshot \(eventStore.authorized)")
        let predicate = eventStore.upcomingReminders()
        eventStore.publisher(for: predicate)
            .map { SimpleEntry(date: Date(), reminders: $0) }
            .print()
            .sink(receiveValue: completion)
            .store(in: &subscriptions)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        print("getTimeline \(eventStore.authorized)")
        let now = Date()
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 1, to: now)!
        let predicate = eventStore.upcomingReminders()
        eventStore.publisher(for: predicate)
            .map { SimpleEntry(date: now, reminders: $0.sorted { $0.dueDate < $1.dueDate }) }
            .map { Timeline(entries: [$0], policy: .after(nextUpdateDate)) }
            .print()
            .sink(receiveValue: completion)
            .store(in: &subscriptions)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let reminders: [EKReminder]
}

struct TodayWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 0) {
            ForEach(entry.reminders) { reminder in
                HStack(alignment: .center) {
                    PriorityStripe(priority: reminder.priority, width: 12)
                    VStack(alignment: .leading) {
                        HStack {
                            Text(reminder.title)

                            Spacer()
                            DateView(date: reminder.dueDate, formatter: .shortDate)
                                .foregroundColor(.gray)
                        }
                        .font(.title)
                        HStack {
                            Text(reminder.calendar.title)
                                .foregroundColor(reminder.calendar.color)

                            Spacer()
                            if reminder.hasURL {
                                Image(systemName: "link")
                                    .frame(width: 8, height: 8)
                                    .scaledToFit()
                            }
                            if reminder.hasRecurrenceRules {
                                Image(systemName: "clock")
                                    .frame(width: 8, height: 8)
                                    .scaledToFit()
                            }
                        }
                        .font(.caption)
                    }
                }
                .padding(.trailing, 10)
                .minimumScaleFactor(0.01)
                Color.black.frame(width: .infinity, height: 1)
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
        for hourOffset in 0..<5 {
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
