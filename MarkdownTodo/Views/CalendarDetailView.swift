//
//  CalendarView.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import EventKit
import SwiftUI

struct CalendarDetailView: View {
    @EnvironmentObject var eventStore: EventStore
    var reminderQuery = ReminderQuery()
    @State var reminders: [EKReminder] = []
    var calendar: EKCalendar

    var body: some View {
        List {
            ForEach(reminders, id: \.calendarItemIdentifier) { reminder in
                Text(reminder.title)
            }
        }
        .onAppear {
            // TODO: Figure out proper conversion of delgate -> publisher
            self.eventStore.reminders(for: self.calendar, to: self.reminderQuery)
        }.onReceive(reminderQuery.subscribe(on: DispatchQueue.main)) { (result) in
            self.reminders = result
        }
        .navigationBarTitle(calendar.title)
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDetailView(calendar: EKCalendar())
    }
}
