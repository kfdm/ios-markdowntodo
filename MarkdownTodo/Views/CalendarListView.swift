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

    var calendar: EKCalendar

    var body: some View {
        PredicateFetcher(predicate: eventStore.reminders(for: calendar)) { reminders in
            SortedRemindersView(sortBy: $sortBy, reminders: reminders)
        }
        .navigationBarTitle(calendar.title)
        .modifier(BackgroundColorModifier(color: self.calendar.cgColor))
        .navigationBarItems(
            leading: AddTaskButton(calendar: calendar),
            trailing: SortButton(sortBy: $sortBy)
        )
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
