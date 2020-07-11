//
//  CalendarView.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import Combine
import EventKit
import SwiftUI

struct CalendarDetailView: View {
    @EnvironmentObject var eventStore: EventStore
    var calendar: EKCalendar

    // Query
    @State private var subscriptions = Set<AnyCancellable>()
    @State private var reminders: [EKReminder] = []

    var body: some View {
        List {
            ForEach(reminders, id: \.calendarItemIdentifier) { reminder in
                ReminderRow(reminder: reminder)
            }
        }
        .onAppear {
            self.eventStore.reminders(for: self.calendar)
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { (result) in
                    self.reminders = result
                })
                .store(in: &self.subscriptions)
        }
        .navigationBarTitle(calendar.title)
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDetailView(calendar: EKCalendar())
    }
}
