//
//  ListView.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import EventKit
import SwiftUI
import EventKitExtensions

private struct CalendarDetailView: View {
    @EnvironmentObject var eventStore: LegacyEventStore
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
        .navigationTitle(calendar.title)
        .modifier(BackgroundColorModifier(color: self.calendar.cgColor))
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                AddTaskButton(calendar: calendar)
                SortButton(sortBy: $sortBy)
                EditCalendarButton(calendar: calendar)
            }
            ToolbarItemGroup(placement: .bottomBar) {
                Toggle("Show Completed", isOn: $showCompleted)
                PruneCompletedButton(calendar: calendar)
            }
        }
    }
}

struct CalendarListView: View {
    @EnvironmentObject var store : MarkdownEventStore
    @State var calendars = [EKCalendar]()

    var body: some View {
        SourceGroupedCalendarView(groups: calendars) { calendar in
            NavigationLink(destination: CalendarDetailView(calendar: calendar)) {
                Text(calendar.title)
                    .foregroundColor(calendar.color)
            }
        }
        .refreshable {
            store.refreshSourcesIfNecessary()
            calendars = await store.calendars()
        }
        .task {
            calendars = await store.calendars()
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarListView()
    }
}
