//
//  CalendarOverview.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/08/15.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import Combine
import EventKit
import SwiftUI

struct CalendarOverview: View {
    private var month: DateInterval {
        calendar.dateInterval(of: .month, for: Date())!
    }

    @Environment(\.calendar) var calendar
    @State var selectedDate = Date()

    // Query
    @EnvironmentObject var eventStore: EventStore
    @State private var subscriptions = Set<AnyCancellable>()
    @State private var reminders: [EKReminder] = []

    var body: some View {
        CalendarView(interval: month) { date in
            NavigationLink(
                destination: SelectedDateView(date: date).onAppear { selectedDate = date }
            ) {
                Text(String(self.calendar.component(.day, from: date)))
                    .frame(
                        minWidth: 30, idealWidth: 40, maxWidth: 40,
                        minHeight: 30, idealHeight: 40, maxHeight: 40
                    )
                    .modifier(CalendarDateModifier(selectedDate: $selectedDate, date: date))
                    .clipShape(Circle())
                    .modifier(CalendarDateAttachments(reminders: $reminders, date: date))
            }
        }.onAppear(perform: fetch)
    }

    func fetch() {
        self.eventStore.publisher(for: eventStore.reminders(for: month))
            .receive(on: DispatchQueue.main)
            .assign(to: \.reminders, on: self)
            .store(in: &self.subscriptions)
    }
}
