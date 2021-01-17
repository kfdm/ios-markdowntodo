//
//  ListView.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import EventKit
import SwiftUI

struct CalendarDetailView: View {
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
            ToolbarItem(placement: .bottomBar) {
                Toggle("Show Completed", isOn: $showCompleted)
            }
        }
    }
}

struct CalendarListView: View {
    @EnvironmentObject var eventStore: EventStore

    var body: some View {
        Group {
            List {
                ForEach(eventStore.sources) { (source) in
                    Section(header: Text(source.title)) {
                        ForEach(eventStore.calendars(for: source)) { (calendar) in
                            NavigationLink(destination: CalendarDetailView(calendar: calendar)) {
                                Text(calendar.title)
                                    .foregroundColor(calendar.color)
                            }
                        }
                    }
                }
            }.listStyle(GroupedListStyle())
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarListView()
    }
}
