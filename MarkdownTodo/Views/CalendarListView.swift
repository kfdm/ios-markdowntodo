//
//  ListView.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import EventKit
import SwiftUI

private struct CalendarDetailView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var sortBy = SortOptions.dueDate
    @State private var showCompleted = false

    var calendar: EKCalendar

    var body: some View {
        Group {
            if showCompleted {
                PredicateFetcher(predicate: eventStore.completed(for: calendar)) { reminders in
                    SortedRemindersView(sortBy: $sortBy, reminders: reminders)
                }
            } else {
                PredicateFetcher(predicate: eventStore.reminders(for: calendar)) { reminders in
                    SortedRemindersView(sortBy: $sortBy, reminders: reminders)
                }
            }
        }
        .modifier(BackgroundColorModifier(color: self.calendar.cgColor))
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                AddTaskButton(calendar: calendar)
                EditCalendarButton(calendar: calendar)
                SortButton(sortBy: $sortBy)
            }
            ToolbarItemGroup(placement: .bottomBar) {
                Toggle("Show Completed", isOn: $showCompleted)
                PruneCompletedButton(calendar: calendar)
            }
        }
    }
}

struct EKCalendarList<ContentView: View>: View {
    let content: (EKCalendar) -> ContentView
    @EnvironmentObject var eventStore: EventStore

    var body: some View {
        List {
            ForEach(eventStore.sources) { (source) in
                Section(header: Text(source.title)) {
                    ForEach(eventStore.calendars(for: source)) { (calendar) in
                        content(calendar)
                    }
                }
            }
        }.listStyle(GroupedListStyle())
    }
}

struct CalendarListView: View {
    var body: some View {
        EKCalendarList { calendar in
            NavigationLink(destination: CalendarDetailView(calendar: calendar)) {
                Text(calendar.title)
                    .foregroundColor(calendar.color)
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarListView()
    }
}
