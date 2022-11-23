//
//  PredicateView.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import EventKit
import SwiftUI
import os.log

struct RemindersGroupDate<ReminderView>: View where ReminderView: View {
    let reminders: [Date: [EKReminder]]
    let content: (EKReminder) -> ReminderView

    func section(date: Date) -> some View {
        switch date {
        case .distantFuture:
            return AnyView(Text("No Due Date"))
        case .distantPast:
            return AnyView(Text("Overdue"))
        default:
            return AnyView(DateView(date: date, formatter: .fullDate))
        }
    }

    var body: some View {
        List {
            // Show dates oldest to newest
            ForEach(reminders.keys.sorted { $0 < $1 }, id: \.self) { date in
                Section(header: section(date: date)) {
                    ForEach(reminders[date]!.sorted { $0.dueDate < $1.dueDate }) { reminder in
                        content(reminder)
                    }
                }
            }
        }
    }

    init(
        byDueDate reminders: [EKReminder],
        @ViewBuilder content: @escaping (EKReminder) -> ReminderView
    ) {
        self.reminders = reminders.byDueDate()
        self.content = content
    }

    init(
        byCreateDate reminders: [EKReminder],
        @ViewBuilder content: @escaping (EKReminder) -> ReminderView
    ) {
        self.reminders = reminders.byCreateDate()
        self.content = content
    }

    init(
        byAgenda reminders: [EKReminder],
        @ViewBuilder content: @escaping (EKReminder) -> ReminderView
    ) {
        self.reminders = reminders.byAgenda()
        self.content = content
    }

}

struct RemindersGroupPriority<ReminderView>: View where ReminderView: View {
    let reminders: [Int: [EKReminder]]
    let content: (EKReminder) -> ReminderView

    init(reminders: [EKReminder], @ViewBuilder content: @escaping (EKReminder) -> ReminderView) {
        self.reminders = reminders.byPriority()
        self.content = content
    }

    var body: some View {
        List {
            ForEach(reminders.keys.sorted { $0 < $1 }, id: \.self) { priority in
                Section(header: Text("Priority \(priority)")) {
                    ForEach(self.reminders[priority]!.sorted { $0.dueDate < $1.dueDate }) {
                        reminder in
                        content(reminder)
                    }
                }
            }
        }
    }
}

struct RemindersGroupTitle<ReminderView>: View where ReminderView: View {
    let reminders: [EKReminder]
    let content: (EKReminder) -> ReminderView

    var body: some View {
        List {
            ForEach(reminders.sorted { $0.title > $1.title }) { reminder in
                content(reminder)
            }
        }
    }
}

struct RemindersGroupCalendar<ReminderView>: View where ReminderView: View {
    let reminders: [EKCalendar: [EKReminder]]
    let content: (EKReminder) -> ReminderView

    init(reminders: [EKReminder], @ViewBuilder content: @escaping (EKReminder) -> ReminderView) {
        self.reminders = reminders.byCalendar()
        self.content = content
    }

    var body: some View {
        List {
            ForEach(reminders.keys.sorted { $0.title < $1.title }, id: \.self) { calendar in
                Section(header: Text(calendar.title)) {
                    ForEach(self.reminders[calendar]!.sorted { $0.dueDate < $1.dueDate }) {
                        reminder in
                        content(reminder)
                    }
                }
            }
        }
    }
}

struct SortedRemindersView: View {
    @Binding var sortBy: SortOptions
    // Putting our EnvironmentObject store here seems to fix the bug with "quick date"
    // but the correct fix is to likely correctly propogate State/Binding values
    @EnvironmentObject var store: MarkdownEventStore
    @Environment(\.calendar) var calendar
    var reminders: [EKReminder]

    func content(for reminder: EKReminder) -> some View {
        NavigationLink(destination: ReminderDetail(reminder: reminder)) {
            ReminderRow(reminder: reminder)
                .contextMenu {
                    Menu("Due Date") {
                        Button("Unset") {
                            store.quickUnsetDate(reminder)
                        }
                        Button("Today") {
                            store.quickSetDate(reminder, date: .now)
                        }
                        Button("Tomorrow") {
                            store.quickSetDate(reminder, date: .now.tomorrow)
                        }
                    }
                    Divider()
                    Button("Delete", role: .destructive) {
                        store.quickDelete(reminder)
                    }
                }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button("Complete") { store.quickComplete(reminder) }
                .tint(.green)
                .tint(.cyan)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Delete", role: .destructive) { store.quickDelete(reminder) }
                .tint(.red)
            Button("Move") {}
                .tint(.blue)
        }
        .onEventStoreChanged {
            self.sortBy = sortBy
        }
    }

    var body: some View {
        Group {
            if reminders.count == 0 {
                List {
                    Text("No Reminders")
                }
            } else {
                switch sortBy {
                case .dueDate:
                    RemindersGroupDate(byDueDate: reminders, content: content)
                case .createdDate:
                    RemindersGroupDate(byCreateDate: reminders, content: content)
                case .priority:
                    RemindersGroupPriority(reminders: reminders, content: content)
                case .title:
                    RemindersGroupTitle(reminders: reminders, content: content)
                case .agenda:
                    RemindersGroupDate(byAgenda: reminders, content: content)
                case .calendar:
                    RemindersGroupCalendar(reminders: reminders, content: content)
                }
            }
        }
        // Default sort button if not overridden in the parent view
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if let defaultCalendar = store.defaultCalendar {
                    AddTaskButton(calendar: defaultCalendar)
                }
                SortButton(sortBy: $sortBy)
            }
        }
    }
}
