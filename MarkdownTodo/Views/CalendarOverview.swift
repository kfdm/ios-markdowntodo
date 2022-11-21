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
    @EnvironmentObject var store: MarkdownEventStore
    @State private var reminders: [EKReminder] = []
    
    private func destination(for date: Date) -> some View {
        selectedDate = date
        return SelectedDateView(date: date)
    }
    
    var body: some View {
        CalendarView(interval: month) { date in
            NavigationLink(destination: destination(for: date)) {
                Text(String(self.calendar.component(.day, from: date)))
                    .frame(
                        minWidth: 30, idealWidth: 40, maxWidth: 40,
                        minHeight: 30, idealHeight: 40, maxHeight: 40
                    )
                    .modifier(DateHighlightModifier(selectedDate: $selectedDate, date: date))
                    .modifier(DateBorderModifier(reminders: $reminders, date: date))
            }
        }
        .task {
            reminders = await store.reminders(for: month)
        }
    }
}
